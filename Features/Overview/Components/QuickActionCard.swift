import SwiftUI

struct QuickActionItem: Identifiable {
  let id = UUID()
  let icon: String
  let title: String
  let tint: Color

  static let mock: [QuickActionItem] = [
    .init(icon: "drop.fill", title: "Add Water", tint: .cyan),
    .init(icon: "wind", title: "Breathwork", tint: .green),
    .init(icon: "cross.case.fill", title: "Fix Pain", tint: .red),
    .init(icon: "sparkles", title: "Look Maxing", tint: .purple),
  ]
}

struct QuickActionCard: View {
  let item: QuickActionItem
  var action: (() -> Void)? = nil

  var body: some View {
    Button(action: { action?() }) {
      EFCard(style: .tinted(item.tint)) {
        VStack(spacing: 8) {
          Image(systemName: item.icon)
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(item.tint)

          Text(item.title)
            .font(EverFont.label)
            .multilineTextAlignment(.center)
            .foregroundStyle(.primary)
        }
        .frame(width: 96, height: 78)
      }
    }
    .buttonStyle(.plain)
  }
}
