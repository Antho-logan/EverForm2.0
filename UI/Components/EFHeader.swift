import SwiftUI

public struct EFHeader: View {
    @Environment(\.dismiss) private var dismiss
    private let title: String
    private let showBack: Bool
    private let extraTop: CGFloat = 6

    public init(title: String, showBack: Bool = false) {
        self.title = title
        self.showBack = showBack
    }

    public var body: some View {
        HStack(spacing: 0) {
            if showBack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                        .padding(.trailing, 8)
                }
                .buttonStyle(.plain)
            }
            
            Text(title)
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .kerning(-0.5)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
            
            Spacer()
        }
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
