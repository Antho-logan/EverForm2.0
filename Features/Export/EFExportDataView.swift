// TODO: Candidate for removal – appears unused in current EverForm flow.
import SwiftUI

struct EFExportDataView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Export your data as…")
                .font(.title3.bold())
            VStack(spacing: 12) {
                Button { } label: {
                    HStack { Image(systemName: "doc.text"); Text("CSV"); Spacer(); Image(systemName: "chevron.right") }
                }
                .buttonStyle(.borderedProminent)

                Button { } label: {
                    HStack { Image(systemName: "doc.richtext"); Text("JSON"); Spacer(); Image(systemName: "chevron.right") }
                }
                .buttonStyle(.bordered)

                Button { } label: {
                    HStack { Image(systemName: "square.and.arrow.up"); Text("Share to…"); Spacer(); Image(systemName: "chevron.right") }
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            Spacer()
        }
        .padding(.top, 24)
        .navigationTitle("Export Data")
    }
}

#Preview { NavigationStack { EFExportDataView() } }
