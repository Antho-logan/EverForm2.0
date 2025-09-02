import SwiftUI

struct EFCard<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(EFTheme.surface(scheme))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(EFTheme.cardStroke(scheme))
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: scheme == .dark ? .black.opacity(0.35) : .black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

struct EFSectionHeader: View {
    @Environment(\.colorScheme) private var scheme
    let title: String
    var body: some View {
        Text(title)
            .font(.system(.title2, weight: .bold))
            .foregroundStyle(EFTheme.text(scheme))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }
}
