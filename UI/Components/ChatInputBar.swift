//
//  ChatInputBar.swift
//  EverForm
//
//  Modern OpenAI-style chat input bar with mic animation
//

import SwiftUI

struct ChatInputBar: View {
    @Binding var text: String
    @State private var isRecording = false
    @State private var micScale: CGFloat = 1.0
    @State private var micOpacity: Double = 1.0
    
    let onAttach: () -> Void
    let onMicToggle: (Bool) -> Void
    let onSend: (String) -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        let palette = Theme.palette(colorScheme)

        VStack(spacing: 0) {
            // Single full-width dock
            HStack(spacing: Theme.Spacing.sm) {
                // Paperclip button (left)
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    onAttach()
                }) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(palette.textPrimary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Attach document")
                
                // Center: rounded text field that grows up to 3 lines
                TextField("Message", text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(palette.textPrimary)
                    .focused($isTextFieldFocused)
                    .lineLimit(1...3)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.sm)
                    .background(palette.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(palette.stroke, lineWidth: 1)
                    )

                // Right: mic button with pulse animation
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    toggleRecording()
                }) {
                    ZStack {
                        // Pulsing animation when recording
                        if isRecording {
                            Circle()
                                .fill(palette.accent.opacity(0.2))
                                .frame(width: 44, height: 44)
                                .scaleEffect(micScale)
                                .opacity(micOpacity)
                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isRecording)
                        }

                        Image(systemName: isRecording ? "mic.fill" : "mic")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(isRecording ? .white : palette.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(isRecording ? palette.accent : Color.clear)
                            .clipShape(Circle())
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isRecording ? "Stop recording" : "Start recording")
                .accessibilityValue(isRecording ? "Recording in progress" : "Tap and hold to record")
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.md)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.bottom, Theme.Spacing.sm)
        .background(palette.background.opacity(0.8))
    }
    
    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func toggleRecording() {
        isRecording.toggle()
        onMicToggle(isRecording)
        
        if isRecording {
            startMicAnimation()
        } else {
            stopMicAnimation()
        }
    }
    
    private func startMicAnimation() {
        // Ripple animation using TimelineView
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
            micScale = 1.5
            micOpacity = 0.3
        }
    }
    
    private func stopMicAnimation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            micScale = 1.0
            micOpacity = 1.0
        }
    }
    
    private func sendMessage() {
        let messageText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageText.isEmpty else { return }
        
        onSend(messageText)
        text = ""
        isTextFieldFocused = false
    }
}

// MARK: - Mic Ripple Animation View

private struct MicRippleView: View {
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Circle()
                .stroke(Theme.palette(.light).accent.opacity(0.3), lineWidth: 2)
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        scale = 1.5
                        opacity = 0.3
                    }
                }
        }
    }
}

#Preview {
    VStack {
        Spacer()
        
        ChatInputBar(
            text: .constant(""),
            onAttach: { print("Attach tapped") },
            onMicToggle: { isRecording in print("Mic toggled: \(isRecording)") },
            onSend: { text in print("Send: \(text)") }
        )
    }
    .background(Theme.palette(.light).background)
}
