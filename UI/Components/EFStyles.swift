import SwiftUI

struct EFCardStyle: ViewModifier {
  @Environment(\.colorScheme) private var scheme

  func body(content: Content) -> some View {
    content
      .background(
        RoundedRectangle(cornerRadius: EverFormTheme.Radius.card, style: .continuous)
          .fill(EverFormTheme.Colors.card)
      )
      .overlay(
        RoundedRectangle(cornerRadius: EverFormTheme.Radius.card, style: .continuous)
          .stroke(EverFormTheme.Colors.cardStroke, lineWidth: 1)
      )
      .shadow(
        color: scheme == .dark ? EverFormTheme.Shadows.dark() : EverFormTheme.Shadows.light(),
        radius: EverFormTheme.Shadows.radius, x: 0, y: EverFormTheme.Shadows.y)
  }
}

extension View {
  func efCard() -> some View {
    modifier(EFCardStyle())
  }
}

struct EFChip: View {
  let title: String

  var body: some View {
    Text(title)
      .font(EverFormTheme.Typography.label)
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(EverFormTheme.Colors.surface)
      .clipShape(Capsule())
      .overlay(Capsule().stroke(EverFormTheme.Colors.cardStroke))
  }
}
