import SwiftUI

struct MobilityRoutineSheet: View {
    let onClose: () -> Void
    @State private var isSaving = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Mobility Routine")
                .font(.title2.weight(.bold))
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Today's Focus")
                    .font(.title3.weight(.semibold))
                
                Text("Hips & Shoulders • 8 minutes")
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Routine steps:")
                        .font(.headline)
                    Text("• Hip circles")
                    Text("• Shoulder rolls")
                    Text("• Cat-cow stretches")
                    Text("• Deep hip flexor stretch")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            
            Button("Start Mobility") {
                Task {
                    isSaving = true
                    let formatter = ISO8601DateFormatter()
                    let payload = MobilitySessionRequest(
                        routineId: "quick-mobility",
                        status: "completed",
                        performedAt: formatter.string(from: Date())
                    )
                    do {
                        let _: BackendMobilitySession = try await BackendClient.shared.post("mobility/sessions", body: payload)
                    } catch {
                        DebugLog.info("Failed to log mobility session: \(error)")
                    }
                    isSaving = false
                    onClose()
                }
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .disabled(isSaving)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Mobility")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Close", action: onClose)
            }
        }
    }
}

private struct MobilitySessionRequest: Codable {
    let routineId: String
    let status: String
    let performedAt: String?
}
