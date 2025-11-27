// TODO: Candidate for removal – appears unused in current EverForm flow.
import SwiftUI

struct EFReportBugView: View {
    @State private var topic = "UI"
    @State private var description = ""

    var body: some View {
        Form {
            Picker("Topic", selection: $topic) {
                Text("UI").tag("UI")
                Text("Sync").tag("Sync")
                Text("Performance").tag("Performance")
                Text("Other").tag("Other")
            }
            Section("Description") {
                TextEditor(text: $description)
                    .frame(minHeight: 160)
            }
            Section {
                Button {
                    // placeholder submit
                } label: {
                    HStack { Spacer(); Text("Submit"); Spacer() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle("Report a Bug")
    }
}

#Preview { NavigationStack { EFReportBugView() } }
