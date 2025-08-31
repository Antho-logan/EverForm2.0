import SwiftUI
import AVFoundation

struct ChatComposer: View {
    @Binding var text: String
    var onSend: () -> Void
    var onPlus: () -> Void
    var onMicToggle: () -> Void
    @Binding var isRecording: Bool
    
    @FocusState private var isFocused: Bool
    @State private var textHeight: CGFloat = 48
    
    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        HStack(spacing: 8) {
            // Plus button
            Button(action: onPlus) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(accentColor)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Add attachment")
            
            // Text input
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("Ask your question…")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 14)
                        .allowsHitTesting(false)
                }
                
                TextEditor(text: $text)
                    .focused($isFocused)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                    .frame(minHeight: 24, maxHeight: 68)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
            }
            .frame(minHeight: 48)
            
            // Mic button
            Button(action: onMicToggle) {
                Image(systemName: isRecording ? "mic.fill" : "mic")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(isRecording ? .red : .secondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel(isRecording ? "Stop recording" : "Start recording")
            
            // Send button
            Button(action: onSend) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(canSend ? .white : .secondary)
                    .frame(width: 32, height: 32)
                    .background(canSend ? accentColor : Color.secondary.opacity(0.3))
                    .clipShape(Circle())
            }
            .disabled(!canSend)
            .accessibilityLabel("Send message")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(surfaceElevatedColor)
                .shadow(
                    color: .black.opacity(isFocused ? 0.1 : 0.05),
                    radius: isFocused ? 8 : 4,
                    y: isFocused ? 2 : 1
                )
        )
        .padding(.horizontal, 16)
        .scaleEffect(isFocused ? 1.02 : 1.0)
        .animation(.spring(response: 0.32, dampingFraction: 0.9), value: isFocused)
    }
    
    private var accentColor: Color {
        Color.green // Fallback accent color
    }
    
    private var surfaceElevatedColor: Color {
        Color(.secondarySystemBackground)
    }
}