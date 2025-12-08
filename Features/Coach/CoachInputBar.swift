import SwiftUI

struct CoachInputBar: View {
    @Binding var text: String
    var onSend: () -> Void
    
    // Green accent color (matches CoachView)
    private let coachGreen = Color(red: 48/255, green: 196/255, blue: 103/255)
    private let activeGreen = Color(red: 68/255, green: 216/255, blue: 123/255) // Slightly lighter
    
    var body: some View {
        HStack(spacing: 12) {
            // Left: Plus button
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
            }
            .frame(width: 32, height: 32)
            .buttonStyle(.plain)
            
            // Center: Text field inside a capsule/pill
            HStack(spacing: 8) {
                TextField("Ask something...", text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16))
                    .padding(.vertical, 10)
                    .padding(.leading, 12)
                
                Button(action: {
                    // Mic action placeholder
                }) {
                    Image(systemName: "mic")
                        .font(.system(size: 18))
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
                .padding(.trailing, 12)
            }
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(DesignSystem.Colors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(DesignSystem.Colors.border.opacity(0.6), lineWidth: 1)
            )
            .frame(minHeight: 40)
            
            // Right: Send button
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(hasText ? activeGreen : coachGreen)
                    )
            }
            .disabled(!hasText)
            .opacity(hasText ? 1.0 : 1.0) 
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            // Minimal background matching the screen
            DesignSystem.Colors.background
                .ignoresSafeArea(edges: .bottom)
        )
    }
    
    private var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
