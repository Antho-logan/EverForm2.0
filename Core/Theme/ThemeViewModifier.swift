import SwiftUI

/// Apply global background + optional color scheme. Attach to your root.
struct ThemeApplier: ViewModifier {
    @EnvironmentObject var theme: ThemeManager

    func body(content: Content) -> some View {
        Group {
            if let cs = theme.preferredColorScheme {
                content
                    .preferredColorScheme(cs)
            } else {
                content
            }
        }
        .background(theme.palette.appBackground.ignoresSafeArea())
    }
}

extension View {
    func applyAppTheme() -> some View { 
        self.modifier(ThemeApplier()) 
    }
}
