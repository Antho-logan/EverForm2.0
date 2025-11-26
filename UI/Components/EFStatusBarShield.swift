import SwiftUI

public struct EFStatusBarShield: View {
    @Environment(\.colorScheme) private var scheme
    public init() {}

    public var body: some View {
        GeometryReader { geo in
            // Dynamic height = status bar inset + 8pt cushion
            let h = geo.safeAreaInsets.top + 8

            // Material background + subtle bottom divider
            Color.clear
                .background(.ultraThinMaterial)
                .overlay(
                    Divider()
                        .opacity(scheme == .dark ? 0.35 : 0.15),
                    alignment: .bottom
                )
                .frame(height: h)
                .ignoresSafeArea(edges: .top)
        }
        // We only care about the overlay height; don't occupy layout space
        .frame(height: 0)
    }
}