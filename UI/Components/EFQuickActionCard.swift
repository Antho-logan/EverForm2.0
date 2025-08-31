import SwiftUI

struct EFQuickActionCard: View {
    let systemIcon: String
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemIcon)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 36, height: 36)
                    .background(Color(.systemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
                    )
                    .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title))
    }
}


