import SwiftUI

public struct EFCard<Content: View>: View {
    let content: Content
    @Environment(\.colorScheme) private var colorScheme
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(Theme.Spacing.lg)
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
