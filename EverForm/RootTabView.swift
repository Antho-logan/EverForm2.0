import SwiftUI

struct RootTabView: View {
    @State private var selection: Int = EverFormTab.overview.rawValue
    // Non-zero fallback to avoid content rendering under the tab bar before measurement.
    @State private var tabBarHeight: CGFloat = 56
    @StateObject private var keyboard = KeyboardObserver()

    var body: some View {
        ZStack(alignment: .bottom) {
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
            // Root layout contract (deterministic):
            // - Root DOES NOT use `.safeAreaInset` for the tab bar.
            // - Root overlays the custom tab bar and reserves space via padding.
            // - Child screens can safely use `.safeAreaInset(edge: .bottom)` for composers/CTAs.
            .padding(.bottom, keyboard.isVisible ? 0 : tabBarHeight)
            .animation(.easeInOut(duration: 0.2), value: tabBarHeight)
            .animation(keyboard.animation, value: keyboard.isVisible)

            EverFormTabBar(selection: $selection)
                // Tab bar should not jump above the keyboard; hide it while typing.
                .opacity(keyboard.isVisible ? 0 : 1)
                .offset(y: keyboard.isVisible ? tabBarHeight : 0)
                .allowsHitTesting(!keyboard.isVisible)
                .animation(keyboard.animation, value: keyboard.isVisible)
                .onHeightChange { newHeight in
                    guard newHeight > 1 else { return }
                    if abs(tabBarHeight - newHeight) > 0.5 {
                        tabBarHeight = newHeight
                    }
                }
        }
    }
}
