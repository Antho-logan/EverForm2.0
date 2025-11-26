import SwiftUI

public struct EFHeader: View {
    private let title: String
    private let extraTop: CGFloat = 6

    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        Text(title)
            .font(.system(.largeTitle, design: .rounded).weight(.bold))
            .kerning(-0.5)
            .foregroundStyle(DesignSystem.Colors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, extraTop)
            .accessibilityAddTraits(.isHeader)
            .safeAreaPadding(.top)
    }
}

#Preview {
    EFHeader(title: "Overview")
        .background(DesignSystem.Colors.background)
}
