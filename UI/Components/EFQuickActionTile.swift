import SwiftUI

struct EFQuickActionTile: View {
    let systemIcon: String
    let title: String
    var isEditing: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: systemIcon)
                .font(.system(size: 20, weight: .semibold))
                .frame(width: 36, height: 36)
                .background(Color(.systemFill))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(title)
                .font(.footnote.weight(.semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .padding(12)
        .frame(minWidth: 88, maxWidth: .infinity, minHeight: 92)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title))
    }
}


