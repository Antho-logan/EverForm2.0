import SwiftUI

struct MobilityRoutineSheet: View {
    let onClose: () -> Void
    
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
                // Handle mobility start
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            
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