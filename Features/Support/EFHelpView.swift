import SwiftUI

struct EFHelpView: View {
    var body: some View {
        List {
            Section("Guides") {
                NavigationLink("Getting Started") { Text("Getting Started").padding() }
                NavigationLink("Connect wearables") { Text("Connect devices").padding() }
                NavigationLink("Troubleshooting") { Text("Troubleshooting").padding() }
            }
            Section("Contact") {
                HStack {
                    Image(systemName: "envelope")
                    Text("support@everform.app")
                }
                HStack {
                    Image(systemName: "globe")
                    Text("everform.app/help")
                }
            }
        }
        .navigationTitle("Help")
    }
}

#Preview { NavigationStack { EFHelpView() } }
