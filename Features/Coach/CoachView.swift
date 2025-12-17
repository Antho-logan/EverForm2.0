import SwiftUI

struct CoachMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
}

struct CoachView: View {
  // State
  @State private var message: String = ""
  @State private var voiceState: EFVoiceState = .idle
  @State private var messages: [CoachMessage] = [
      CoachMessage(text: "Hi! I'm your EverForm coach. How can I help you today?", isUser: false, timestamp: Date())
  ]
  @State private var isLoading: Bool = false
  private let bottomAnchorID = "CoachBottom"
  @FocusState private var isComposerFocused: Bool

  var body: some View {
    EFScreenContainer {
      VStack(spacing: 0) {
        EFHeader(title: "Coach")

        ScrollViewReader { scrollProxy in
          ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
              ForEach(messages) { msg in
                CoachBubbleRow(message: msg)
                  .padding(.horizontal, 20)
              }

              if isLoading {
                CoachThinkingRow()
                  .padding(.horizontal, 20)
              }

              Spacer(minLength: 8).id(bottomAnchorID)
            }
            .padding(.top, 16)
          }
          .scrollDismissesKeyboard(.interactively)
          // Critical: claim vertical space so the scroll area doesn't collapse on tab switches.
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
          .contentShape(Rectangle())
          .onTapGesture {
            isComposerFocused = false
          }
          .onChange(of: messages.count) { _, _ in
            withAnimation(.easeInOut(duration: 0.2)) {
              scrollProxy.scrollTo(bottomAnchorID, anchor: .bottom)
            }
          }
          .onChange(of: isLoading) { _, _ in
            withAnimation(.easeInOut(duration: 0.2)) {
              scrollProxy.scrollTo(bottomAnchorID, anchor: .bottom)
            }
          }
          .onChange(of: isComposerFocused) { _, focused in
            guard focused else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
              withAnimation(.easeInOut(duration: 0.2)) {
                scrollProxy.scrollTo(bottomAnchorID, anchor: .bottom)
              }
            }
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    // Screen-owned composer:
    // RootTabView reserves tab bar space via padding (not safeAreaInset),
    // so this `.safeAreaInset(edge: .bottom)` is stable and keyboard-safe.
    .safeAreaInset(edge: .bottom, spacing: 0) {
      CoachComposerBar(
        text: $message,
        voiceState: $voiceState,
        isFocused: $isComposerFocused,
        isLoading: isLoading,
        onSend: sendMessage
      )
    }
  }

  private func sendMessage() {
      let text = message.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !text.isEmpty else { return }

      voiceState = .idle
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
}

// MARK: - Subviews

private struct CoachBubbleRow: View {
  let message: CoachMessage

  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      if message.isUser {
        Spacer(minLength: 24)
        Text(message.text)
          .foregroundStyle(DesignSystem.Colors.textPrimary)
          .padding(12)
          .background(DesignSystem.Colors.cardBackground)
          .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
          .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
              .stroke(DesignSystem.Colors.border.opacity(0.7), lineWidth: 1)
          )
      } else {
        Text(message.text)
          .foregroundStyle(.white)
          .padding(12)
          .background(DesignSystem.Colors.accent)
          .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        Spacer(minLength: 24)
      }
    }
  }
}

private struct CoachThinkingRow: View {
  var body: some View {
    HStack(spacing: 8) {
      Text("Thinking…")
        .font(DesignSystem.Typography.bodyMedium())
        .foregroundStyle(AppTheme.Colors.textSecondary)
      ThinkingDots(color: AppTheme.Colors.textSecondary)
        .padding(.top, 1)
      Spacer(minLength: 0)
    }
    .padding(.vertical, 6)
  }
}

private struct ThinkingDots: View {
  let color: Color

  var body: some View {
    TimelineView(.animation) { timeline in
      let t = timeline.date.timeIntervalSinceReferenceDate
      HStack(spacing: 4) {
        ForEach(0..<3, id: \.self) { i in
          let phase = (t * 3.0) + (Double(i) * 0.8)
          Circle()
            .fill(color)
            .frame(width: 5, height: 5)
            .opacity(0.25 + 0.75 * (0.5 + 0.5 * sin(phase)))
        }
      }
    }
    .accessibilityHidden(true)
  }
}

private struct CoachComposerBar: View {
  @Binding var text: String
  @Binding var voiceState: EFVoiceState
  let isFocused: FocusState<Bool>.Binding
  let isLoading: Bool
  let onSend: () -> Void

  var body: some View {
    EFChatComposer(
      text: $text,
      placeholder: "Ask something…",
      tint: DesignSystem.Colors.accent,
      voiceState: $voiceState,
      onSend: onSend,
      onStartRecording: startRecording,
      onStopRecording: stopRecording,
      isFocused: isFocused,
      isDisabled: isLoading
    )
    .frame(maxWidth: .infinity)
    .padding(.vertical, 2)
  }

  private func startRecording() {
    guard !isLoading else { return }
    withAnimation(.spring(response: 0.22, dampingFraction: 0.9)) {
      voiceState = .recording
    }
  }

  private func stopRecording() {
    guard !isLoading else { return }
    text = ""
    withAnimation(.spring(response: 0.22, dampingFraction: 0.9)) {
      voiceState = .transcribing
    }

    Task {
      try? await Task.sleep(nanoseconds: 800_000_000)
      await MainActor.run {
        guard voiceState == .transcribing else { return }
        // TODO: Replace this simulated text with the real transcription callback.
        text = "I want to improve my nutrition this week—can you suggest a simple meal plan?"
        withAnimation(.spring(response: 0.22, dampingFraction: 0.9)) {
          voiceState = .idle
        }
      }
    }
  }
}
