//
//  ComposerBar.swift
//  EverForm
//
//  Modern chat composer bar with paperclip, text field, mic, and send
//

import SwiftUI

struct ComposerBar: View {
    @Binding var text: String
    let onAttach: () -> Void
    let onSend: (String) -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var isRecording = false
    @State private var waveformScale: CGFloat = 1.0
    @FocusState private var isTextFieldFocused: Bool
    
    var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        let palette = Theme.palette(colorScheme)
        
        HStack(spacing: 12) {
            // Paperclip button
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                onAttach()
            }) {
                Image(systemName: "paperclip")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(palette.textPrimary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Attach file")
            
            // Text field container
            HStack(spacing: 8) {
                // Multiline text field
                TextField("Message", text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(palette.textPrimary)
                    .focused($isTextFieldFocused)
                    .lineLimit(1...4)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                
                // Recording indicator or send button
                if isRecording {
                    recordingIndicator
                } else if canSend {
                    sendButton
                } else {
                    micButton
                }
            }
            .background(palette.surfaceElevated)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(palette.stroke, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .background(.ultraThinMaterial)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.06), radius: 8, x: 0, y: -2)
    }
    
    // MARK: - Recording Indicator
    
    private var recordingIndicator: some View {
        HStack(spacing: 8) {
            // Compact waveform animation
            HStack(spacing: 2) {
                ForEach(0..<4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Theme.semantic(colorScheme).danger)
                        .frame(width: 2, height: 12)
                        .scaleEffect(y: waveformScale)
                        .animation(
                            .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1),
                            value: waveformScale
                        )
                }
            }
            
            Text("Recording…")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.semantic(colorScheme).danger)
            
            Button(action: stopRecording) {
                Image(systemName: "stop.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(Theme.semantic(colorScheme).danger)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Stop recording")
        }
        .onAppear {
            waveformScale = 1.5
        }
        .onDisappear {
            waveformScale = 1.0
        }
    }
    
    // MARK: - Mic Button
    
    private var micButton: some View {
        Button(action: startRecording) {
            Image(systemName: "mic")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Theme.palette(colorScheme).textSecondary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Start recording")
    }
    
    // MARK: - Send Button
    
    private var sendButton: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
            let messageText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if !messageText.isEmpty {
                onSend(messageText)
                text = ""
            }
        }) {
            Image(systemName: "arrow.up")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(Theme.palette(colorScheme).accent)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Send message")
    }
    
    // MARK: - Recording Actions
    
    private func startRecording() {
        isRecording = true
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Simulate recording for 3 seconds, then transcribe
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            stopRecording()
            simulateTranscription()
        }
    }
    
    private func stopRecording() {
        isRecording = false
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    private func simulateTranscription() {
        // Simulate transcription delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            text = "How can I improve my recovery after workouts?"
            isTextFieldFocused = true
            
            let success = UINotificationFeedbackGenerator()
            success.notificationOccurred(.success)
        }
    }
}

#Preview {
    @Previewable @State var text = ""

    return VStack {
        Spacer()
        ComposerBar(
            text: $text,
            onAttach: {},
            onSend: { _ in }
        )
    }
    .background(Theme.palette(.light).background)
}
