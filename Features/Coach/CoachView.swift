import Combine
import SwiftUI

struct CoachView: View {
  @Environment(\.colorScheme) private var scheme
  @Environment(ThemeManager.self) private var themeManager

  // State
  @State private var message: String = ""
  @State private var keyboardHeight: CGFloat = 0

  var body: some View {
    EFScreenContainer {
      GeometryReader { geo in
        VStack(spacing: 0) {
          EFHeader(title: "Coach")

          ScrollViewReader { scrollProxy in
            ScrollView {
              VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                  Text("Hi! I'm your EverForm coach. How can I help you today?")
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(DesignSystem.Colors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                  Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                .id("Bottom")
              }
            }
            .onTapGesture {
              // Dismiss keyboard on tap
              UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
          }

          // Composer
          EFChatComposer(
            text: $message, placeholder: "Ask something…", tint: DesignSystem.Colors.accent
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

  private func calculateBottomPadding(geo: GeometryProxy) -> CGFloat {
    // Distance from bottom of this view to bottom of screen
    // Since this view is inset by the TabBar (via safeAreaInset in RootTabView),
    // this distance is roughly the TabBar height.
    let viewBottomToScreenBottom = UIScreen.main.bounds.height - geo.frame(in: .global).maxY

    // We only need to pad if the keyboard is taller than the gap below us (the tab bar)
    let overlap = keyboardHeight - viewBottomToScreenBottom
    return max(0, overlap)
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
