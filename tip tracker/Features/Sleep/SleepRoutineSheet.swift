import SwiftUI

struct SleepRoutineSheet: View {
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Sleep & Recovery")
                .font(.title2.weight(.bold))
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Tonight's Plan")
                    .font(.title3.weight(.semibold))
                
                Text("Bedtime: 22:30")
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Wind-down routine:")
                        .font(.headline)
                    Text("• Dim the lights")
                    Text("• Put devices away")
                    Text("• Practice deep breathing")
                    Text("• Light stretching")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            
            Button("Start Wind-Down") {
                // Handle wind-down start
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sleep Routine")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Close", action: onClose)
            }
        }
    }
}