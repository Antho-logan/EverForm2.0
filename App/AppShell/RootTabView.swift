import SwiftUI

// Simple router for tab switching or opening sheets from anywhere.
enum EFRoute: String { case coach, profile, display, security, export, help, bug }
extension Notification.Name { static let efRoute = Notification.Name("efRoute") }

struct RootTabView: View {
    @StateObject private var theme = EFTheme()
    @State private var tab: Int = 0
    @State private var settingsRoute: EFRoute?

    var body: some View {
        TabView(selection: $tab) {
            OverviewView(settingsRoute: $settingsRoute)
                .tabItem { Label("Overview", systemImage: "house.fill") }
                .tag(0)

            CoachView()
                .tabItem { Label("Coach", systemImage: "brain.head.profile") }
                .tag(1)

            ScanView()
                .tabItem { Label("Scan", systemImage: "camera.viewfinder") }
                .tag(2)

            ProgressViewScreen()
                .tabItem { Label("Progress", systemImage: "chart.bar.fill") }
                .tag(3)
        }
        // Override color scheme if user chose Light/Dark in Display
        .environment(\.colorScheme, theme.colorSchemeOverride)
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
                case .coach: EmptyView() // never shown as sheet
                }
            }
            .environmentObject(theme)
        }
    }
}

// Allow EFRoute in .sheet(item:)
extension EFRoute: Identifiable { var id: String { rawValue } }
