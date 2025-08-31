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
            HStack(spacing: Theme.Spacing.sm) {
                // Attach button
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    onAttach()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(palette.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(palette.surface)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Attach document")
                
                // Text input area
                HStack(spacing: Theme.Spacing.xs) {
                    TextField("Message", text: $text, axis: .vertical)
                        .textFieldStyle(.plain)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(palette.textPrimary)
                        .focused($isTextFieldFocused)
                        .lineLimit(1...3)
                        .padding(.horizontal, Theme.Spacing.sm)
                        .padding(.vertical, Theme.Spacing.xs)
                    
                    // Mic button with animation
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        toggleRecording()
                    }) {
                        ZStack {
                            // Ripple effect when recording
                            if isRecording {
                                Circle()
                                    .stroke(palette.accent.opacity(0.3), lineWidth: 2)
                                    .scaleEffect(micScale)
                                    .opacity(micOpacity)
                            }
                            
                            Image(systemName: isRecording ? "mic.fill" : "mic")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(isRecording ? palette.accent : palette.textSecondary)
                                .frame(width: 32, height: 32)
                                .background(isRecording ? palette.accent.opacity(0.1) : palette.surface)
                                .clipShape(Circle())
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isRecording ? "Stop recording" : "Start recording")
                }
                .background(palette.surface)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.card)
                        .stroke(palette.stroke, lineWidth: 1)
                )
                
                // Send button
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    sendMessage()
                }) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(canSend ? palette.accent : palette.textSecondary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .disabled(!canSend)
                .accessibilityLabel("Send message")
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
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
