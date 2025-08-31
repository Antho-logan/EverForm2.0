import SwiftUI

struct LogMealSheet: View {
    let onScanCalories: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Log Meal")
                .font(.title2.weight(.bold))
            
            VStack(spacing: 16) {
                Button("Scan Calories") {
                    onScanCalories()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                
                Button("Quick Add") {
                    // Handle quick add
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Log Meal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Close", action: onClose)
            }
        }
    }
}