import SwiftUI

public struct EFPlanCard: View {
    public enum Accent {
        case green, orange, blue, purple
        var color: Color {
            switch self {
            case .green:  return Color.green
            case .orange: return Color.orange
            case .blue:   return Color.blue
            case .purple: return Color.purple
            }
        }
    }

    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String
    let accent: Accent
    let action: () -> Void

    public init(
        icon: String,
        title: String,
        subtitle: String,
        actionTitle: String,
        accent: Accent,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.accent = accent
        self.action = action
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(accent.color)
                    .frame(width: 28, height: 28)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
                Spacer(minLength: 0)
            }

            Button(action: {
                action()
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }) {
                Text(actionTitle)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule().fill(accent.color.opacity(0.22))
                    )
                    .overlay(
                        Capsule().stroke(accent.color.opacity(0.55), lineWidth: 1)
                    )
                    .foregroundStyle(accent.color)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(actionTitle) for \(title)")
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 168, alignment: .topLeading)
        .efCard()
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
