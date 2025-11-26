import SwiftUI

// Simple router for tab switching or opening sheets from anywhere.
enum EFRoute: String { case coach, profile, display, security, export, help, bug }
extension Notification.Name { static let efRoute = Notification.Name("efRoute") }

struct RootTabView: View {
  // ThemeManager handles the app-wide appearance (Light/Dark/System)
  // Using @State instead of @StateObject because ThemeManager is @Observable
  @State private var themeManager = ThemeManager()

  @State private var tab: Int = 0
  @State private var settingsRoute: EFRoute?

  var body: some View {
    // Main Content
    TabView(selection: $tab) {
      OverviewView(settingsRoute: $settingsRoute)
        .tag(0)
        .toolbar(.hidden, for: .tabBar)  // Hide native tab bar

      CoachView()
        .tag(1)
        .toolbar(.hidden, for: .tabBar)

      ScanView()
        .tag(2)
        .toolbar(.hidden, for: .tabBar)

      ProgressViewScreen()
        .tag(3)
        .toolbar(.hidden, for: .tabBar)
    }
    // Anchor custom tab bar to the bottom using safeAreaInset
    // This ensures content is padded correctly and the bar sits flush
    .safeAreaInset(edge: .bottom) {
      EverFormTabBar(selection: $tab)
    }
    .ignoresSafeArea(.keyboard)  // Keep tab bar pinned to bottom when keyboard appears

    // Apply the preferred color scheme (Light/Dark/System) from ThemeManager
    // Assuming preferredColorScheme property exists on the Observable ThemeManager
    .preferredColorScheme(themeManager.selectedTheme.colorScheme)

    // Provide ThemeManager to the view hierarchy
    .environment(themeManager)  // For views using @Environment(ThemeManager.self)

    .onReceive(NotificationCenter.default.publisher(for: .efRoute)) { n in
      guard let route = n.object as? EFRoute else { return }
      switch route {
      case .coach: tab = 1
      default: settingsRoute = route
      }
    }
    // Settings sheets
    .sheet(item: $settingsRoute) { route in
      NavigationStack {
        switch route {
        case .profile: ProfileSettingsView()
        case .display: DisplaySettingsView()
        case .security: SecuritySettingsView()
        case .export: ExportDataView()
        case .help: HelpCenterView()
        case .bug: ReportBugView()
        case .coach: EmptyView()  // never shown as sheet
        }
      }
      .environment(themeManager)
      .preferredColorScheme(themeManager.selectedTheme.colorScheme)
    }
  }
}

// Allow EFRoute in .sheet(item:)
extension EFRoute: Identifiable { var id: String { rawValue } }
