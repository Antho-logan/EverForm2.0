import SwiftUI

struct EFChatComposer: View {
    @Binding var text: String
    var placeholder: String = "Message"
    var tint: Color = Color(red: 48/255, green: 196/255, blue: 103/255)
    var onSend: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 44, height: 44)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
            }

            HStack(spacing: 12) {
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundStyle(.secondary)
                    }
                    TextField("", text: $text)
                        .foregroundStyle(.primary)
                        .textInputAutocapitalization(.sentences)
                        .disableAutocorrection(true)
                        .onSubmit {
                            if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                onSend?()
                            }
                        }
                }

                Button(action: {}) {
                    Image(systemName: "mic.fill")
                        .foregroundStyle(tint)
                        .font(.system(size: 18))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 18)
            .background(Color.white)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)

            Button(action: {
                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    onSend?()
                }
            }) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.5) : tint)
                    .clipShape(Circle())
                    .shadow(color: tint.opacity(0.4), radius: 8, x: 0, y: 3)
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    EFChatComposer(text: .constant(""))
        .background(DesignSystem.Colors.background)
}
