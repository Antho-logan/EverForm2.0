import SwiftUI

struct TodayPlanSheet: View {
    let onStartWorkout: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Today's Training")
                .font(.title2.weight(.bold))
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Upper Power")
                    .font(.title3.weight(.semibold))
                
                Text("Duration: 75 minutes")
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Main Exercises:")
                        .font(.headline)
                    Text("• Bench Press")
                    Text("• Pull-ups")
                    Text("• Overhead Press")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            
            Button("Start Workout", action: onStartWorkout)
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Training Plan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Close", action: onClose)
            }
        }
    }
}