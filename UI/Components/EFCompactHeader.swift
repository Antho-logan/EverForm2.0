import SwiftUI

struct EFCompactHeader: View {
    let title: String
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            DesignSystem.Colors.background.ignoresSafeArea(edges: .top)
            Text(title)
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(EFTheme.text(scheme))
                .padding(.top, 6)
                .padding(.bottom, 10)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}