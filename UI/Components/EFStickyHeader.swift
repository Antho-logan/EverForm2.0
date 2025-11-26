import SwiftUI

public struct EFStickyHeader: View {
    public let title: String
    @Environment(\.colorScheme) private var scheme

    // Use the app's existing background color from EFTheme
    private var background: Color { EFTheme.background(scheme) }

    public init(title: String) { self.title = title }

    public var body: some View {
        GeometryReader { proxy in
            let top = proxy.safeAreaInsets.top   // status-bar/Dynamic Island height

            VStack(alignment: .leading, spacing: 0) {
                Color.clear.frame(height: top)   // exactly the safe-area top
                Text(title)
                    .font(.system(size: 30, weight: .bold)) // compact title
                    .foregroundStyle(EFTheme.text(scheme))    // match existing text color
                    .tracking(0.2)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background.ignoresSafeArea(edges: .top))
            .shadow(color: .black.opacity(scheme == .dark ? 0.18 : 0.06), radius: 6, y: 2)
        }
        // Height = status bar + compact title row
        .frame(height:  (UIApplication.shared.connectedScenes
                            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.safeAreaInsets.top }
                            .first ?? 0) + 42)
    }
}

private extension UIWindowScene {
    var keyWindow: UIWindow? { windows.first(where: { $0.isKeyWindow }) }
}