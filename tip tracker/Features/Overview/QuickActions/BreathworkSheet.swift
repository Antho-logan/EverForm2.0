import SwiftUI

struct BreathworkSheet: View {
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Breathwork")
                .font(.title2.weight(.bold))
            
            VStack(spacing: 16) {
                Text("4-7-8 Breathing")
                    .font(.title3.weight(.semibold))
                
                Text("Inhale for 4, hold for 7, exhale for 8")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Start Session") {
                    // Handle breathwork start
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            Spacer()
        }
        .padding()
        .navigationTitle("Breathwork")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Close", action: onClose)
            }
        }
    }
}