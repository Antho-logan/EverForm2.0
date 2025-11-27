// TODO: Candidate for removal – appears unused in current EverForm flow.
import SwiftUI

struct EFSecurityView: View {
    @State private var faceId = true
    @State private var twoFA = false

    var body: some View {
        Form {
            Section("Sign-in & Auth") {
                Toggle("Face ID / Touch ID", isOn: $faceId)
                Toggle("Two-factor Authentication", isOn: $twoFA)
                NavigationLink("Change Password") { Text("Change Password").navigationTitle("Change Password") }
            }
            Section("Privacy") {
                Toggle("Share anonymized analytics", isOn: .constant(true))
                Toggle("Crash reports", isOn: .constant(true))
            }
        }
        .navigationTitle("Security")
    }
}

#Preview { NavigationStack { EFSecurityView() } }
