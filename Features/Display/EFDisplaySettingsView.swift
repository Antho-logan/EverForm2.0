// TODO: Candidate for removal – appears unused in current EverForm flow.
import SwiftUI

struct EFDisplaySettingsView: View {
    @StateObject private var themeManager = EFThemeManager()
    @State private var color = 0 // 0 green, 1 teal, 2 orange

    var body: some View {
        Form {
            Section(header: Text("Appearance")) {
                Picker("Theme", selection: $themeManager.stored) {
                    Text("System").tag(EFAppearance.system.rawValue)
                    Text("Light").tag(EFAppearance.light.rawValue)
                    Text("Dark").tag(EFAppearance.dark.rawValue)
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 6)
                Text("Applies across the entire app.").foregroundColor(.secondary)

                Picker("Accent", selection: $color) {
                    Text("Green").tag(0)
                    Text("Teal").tag(1)
                    Text("Orange").tag(2)
                }
            }
            Section("Density") {
                Picker("Card Density", selection: .constant(1)) {
                    Text("Compact").tag(0)
                    Text("Comfortable").tag(1)
                    Text("Roomy").tag(2)
                }
            }
        }
        .navigationTitle("Display")
        .background(Theme.Colors.efBackground.ignoresSafeArea())
    }
}

#Preview { NavigationStack { EFDisplaySettingsView() } }
