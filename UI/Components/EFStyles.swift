import SwiftUI

struct EFCardStyle: ViewModifier {
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        let p = EFPalette.current(scheme)
        return content
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(p.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(p.stroke, lineWidth: scheme == .light ? 1 : 0)
            )
            .shadow(color: p.shadow, radius: scheme == .light ? 16 : 8, x: 0, y: 8)
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
            .font(.footnote.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Theme.Colors.surface)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Theme.Colors.border))
    }
}
