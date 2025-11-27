import SwiftUI

struct RootTabView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.colorScheme) private var systemScheme
    @State private var selection: Int = EverFormTab.overview.rawValue

    var body: some View {
        let resolvedScheme = themeManager.selectedTheme.colorScheme ?? systemScheme

        TabView(selection: $selection) {
            OverviewView()
                .tag(EverFormTab.overview.rawValue)
                .toolbar(.hidden, for: .tabBar)

            CoachView()
                .tag(EverFormTab.coach.rawValue)
                .toolbar(.hidden, for: .tabBar)

            ScanView()
                .tag(EverFormTab.scan.rawValue)
                .toolbar(.hidden, for: .tabBar)

            ProgressViewEF()
                .tag(EverFormTab.progress.rawValue)
                .toolbar(.hidden, for: .tabBar)
        }
        .safeAreaInset(edge: .bottom) {
            EverFormTabBar(selection: $selection)
                .background(themeManager.beigeBackground.ignoresSafeArea(edges: .bottom))
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .environment(\.colorScheme, resolvedScheme)
    }
}
