import SwiftUI

// Simple settings pages opened from avatar menu.
// Display controls Light/Dark/System through EFTheme (@AppStorage).

struct ProfileSettingsView: View {
    var body: some View {
        Form {
            Section("Profile") {
                TextField("First name", text: .constant("Alex"))
                TextField("Last name", text: .constant("Chen"))
                TextField("Email", text: .constant("alex@example.com"))
            }
        }
        .navigationTitle("Profile")
    }
}

struct DisplaySettingsView: View {
    @StateObject private var themeManager = EFThemeManager()

    var body: some View {
        Form {
            Section("Appearance") {
                Picker("Mode", selection: $themeManager.stored) {
                    Text("System").tag(EFAppearance.system.rawValue)
                    Text("Light").tag(EFAppearance.light.rawValue)
                    Text("Dark").tag(EFAppearance.dark.rawValue)
                }
                .pickerStyle(.segmented)
                Text("This overrides the app's appearance immediately.").font(.footnote).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Display")
    }
}

struct SecuritySettingsView: View {
    var body: some View {
        Form {
            Section("Privacy") {
                Toggle("Face ID to unlock", isOn: .constant(true))
                Toggle("Mask sensitive data", isOn: .constant(false))
            }
        }
        .navigationTitle("Security")
    }
}

struct ExportDataView: View {
    var body: some View {
        Form {
            Section("Export") {
                Button("Export JSON") {}
                Button("Export CSV") {}
            }
        }
        .navigationTitle("Export Data")
    }
}

struct HelpCenterView: View {
    var body: some View {
        List {
            Link("FAQ", destination: URL(string: "https://example.com/faq")!)
            Link("Contact support", destination: URL(string: "https://example.com/support")!)
        }
        .navigationTitle("Help")
    }
}

struct ReportBugView: View {
    @State private var text = ""
    var body: some View {
        VStack(spacing: 12) {
            TextEditor(text: $text)
                .frame(minHeight: 220)
                .padding(8)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.3)))
            Button("Send") { /* submit bug */ }
                .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding()
        .navigationTitle("Report a Bug")
    }
}
