import SwiftUI

struct WorkoutRunnerView: View {
    let onFinish: () -> Void
    let onDiscard: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Workout in Progress")
                .font(.title2.weight(.bold))
            
            Text("Upper Power Workout")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            // Mock workout content
            VStack(spacing: 16) {
                Text("Exercise 1: Bench Press")
                Text("Set 1 of 3")
                
                HStack {
                    Button("Log Set") {
                        // Handle set logging
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Skip Set") {
                        // Handle skip
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            Spacer()
            
            HStack {
                Button("Discard", action: onDiscard)
                    .buttonStyle(.bordered)
                    .foregroundStyle(.red)
                
                Button("Finish Workout", action: onFinish)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .navigationTitle("Workout")
        .navigationBarTitleDisplayMode(.inline)
    }
}