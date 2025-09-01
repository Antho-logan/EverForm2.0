import SwiftUI

public struct EFCard<Content: View>: View {
    let content: Content
    let minHeight: CGFloat
    let corner: CGFloat
    @Environment(\.colorScheme) private var colorScheme

    public init(minHeight: CGFloat = 156,
                corner: CGFloat = 16,
                @ViewBuilder content: () -> Content) {
        self.minHeight = minHeight
        self.corner = corner
        self.content = content()
    }

    public var body: some View {
        content
            .padding(Theme.Spacing.lg)
            .frame(minHeight: minHeight)
            .efCardStyle(scheme: colorScheme)
    }
}

#Preview {
    let palette = Theme.palette(.dark)
    EFCard {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Image(systemName: "dumbbell.fill")
                    .foregroundStyle(palette.accent)
                Text("Training")
                    .font(.headline)
                    .foregroundStyle(palette.textPrimary)
                Spacer()
            }
            
            Text("Complete your workout plan")
                .font(.callout)
                .foregroundStyle(palette.textSecondary)
        }
    }
    .padding()
    .background(palette.background)
}
