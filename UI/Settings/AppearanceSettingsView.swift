import SwiftUI

struct AppearanceSettingsView: View {
    @AppStorage("themeMode") private var themeMode: String = Theme.Mode.system.rawValue

    var body: some View {
        NavigationStack {
            Form {
                Section("Theme") {
                    Picker("Appearance", selection: $themeMode) {
                        ForEach(Theme.Mode.allCases, id: \.rawValue) { mode in
                            Text(mode.displayName).tag(mode.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Display")
        }
    }
}

#Preview {
    AppearanceSettingsView()
}
