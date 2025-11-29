import Combine
import SwiftUI

struct CoachMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
}

struct CoachView: View {
  @Environment(\.colorScheme) private var scheme
  @Environment(ThemeManager.self) private var themeManager

  // State
  @State private var message: String = ""
  @State private var keyboardHeight: CGFloat = 0
  @State private var messages: [CoachMessage] = [
      CoachMessage(text: "Hi! I'm your EverForm coach. How can I help you today?", isUser: false, timestamp: Date())
  ]
  @State private var isLoading: Bool = false

  var body: some View {
    EFScreenContainer {
      GeometryReader { geo in
        VStack(spacing: 0) {
          EFHeader(title: "Coach")

          ScrollViewReader { scrollProxy in
            ScrollView {
              VStack(alignment: .leading, spacing: 16) {
                  ForEach(messages) { msg in
                      HStack(alignment: .top) {
                          if msg.isUser {
                              Spacer()
                              Text(msg.text)
                                  .foregroundStyle(DesignSystem.Colors.textPrimary)
                                  .padding(12)
                                  .background(DesignSystem.Colors.cardBackground)
                                  .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                  .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                          } else {
                              Text(msg.text)
                                  .foregroundStyle(.white)
                                  .padding(12)
                                  .background(DesignSystem.Colors.accent)
                                  .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                              Spacer()
                          }
                      }
                      .padding(.horizontal, 20)
                  }
                  
                  if isLoading {
                      HStack {
                          ProgressView()
                              .padding(12)
                              .background(DesignSystem.Colors.cardBackground)
                              .clipShape(Circle())
                          Spacer()
                      }
                      .padding(.horizontal, 20)
                  }
                  
                  Spacer(minLength: 12).id("Bottom")
              }
              .padding(.top, 16)
            }
            .onTapGesture {
              // Dismiss keyboard on tap
              UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .onChange(of: messages.count) { _, _ in
                withAnimation {
                    scrollProxy.scrollTo("Bottom", anchor: .bottom)
                }
            }
          }

          // Composer
          EFChatComposer(
            text: $message, 
            placeholder: "Ask something…", 
            tint: DesignSystem.Colors.accent,
            onSend: sendMessage
          )
          .padding(.vertical, 8)
          .background(themeManager.beigeBackground)
          // Dynamic bottom padding for keyboard
          // We calculate how much the keyboard overlaps with this view
          .padding(.bottom, calculateBottomPadding(geo: geo))
        }
      }
    }
    .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: keyboardHeight)
  }

  private func sendMessage() {
      let text = message.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !text.isEmpty else { return }
      
      let userMsg = CoachMessage(text: text, isUser: true, timestamp: Date())
      messages.append(userMsg)
      message = ""
      isLoading = true
      
      Task {
          do {
              let response = try await AIService.shared.sendMessage(message: text)
              await MainActor.run {
                  let coachMsg = CoachMessage(text: response.reply, isUser: false, timestamp: Date())
                  messages.append(coachMsg)
                  isLoading = false
              }
          } catch {
              await MainActor.run {
                  let errorMsg = CoachMessage(text: "I'm having trouble connecting right now, please try again.", isUser: false, timestamp: Date())
                  messages.append(errorMsg)
                  isLoading = false
              }
          }
      }
  }

  private func calculateBottomPadding(geo: GeometryProxy) -> CGFloat {
    // When keyboard is visible, use its height.
    // When hidden, use the TabBar height (approx 90pt including safe area) so the input isn't covered.
    return keyboardHeight > 0 ? keyboardHeight : 90
  }
}

// MARK: - Keyboard Helper
extension Publishers {
  static var keyboardHeight: AnyPublisher<CGFloat, Never> {
    Publishers.Merge(
      NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
        .map { notification in
          (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
        },
      NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
        .map { _ in CGFloat(0) }
    )
    .eraseToAnyPublisher()
  }
}
