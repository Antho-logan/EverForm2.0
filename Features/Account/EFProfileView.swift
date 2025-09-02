import SwiftUI

struct EFProfileView: View {
    var body: some View {
        List {
            Section("Account") {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                    Text("Name")
                    Spacer()
                    Text("Alex Chen").foregroundStyle(.secondary)
                }
                HStack {
                    Image(systemName: "envelope.fill")
                        .font(.title2)
                    Text("Email")
                    Spacer()
                    Text("alex@example.com").foregroundStyle(.secondary)
                }
            }
            Section("Preferences") {
                Toggle("Daily summary emails", isOn: .constant(true))
                Toggle("Coach tips", isOn: .constant(true))
            }
        }
        .navigationTitle("Profile")
    }
}

#Preview { NavigationStack { EFProfileView() } }
