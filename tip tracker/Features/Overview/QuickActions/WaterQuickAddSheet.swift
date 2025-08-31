import SwiftUI

struct WaterQuickAddSheet: View {
    let onClose: () -> Void
    @State private var glasses: Int = 1
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Log Water")
                .font(.title2.weight(.bold))
            
            VStack(spacing: 16) {
                Text("How many glasses?")
                    .font(.title3)
                
                HStack {
                    Button("-") {
                        if glasses > 1 { glasses -= 1 }
                    }
                    .buttonStyle(.bordered)
                    .disabled(glasses <= 1)
                    
                    Text("\(glasses)")
                        .font(.title.weight(.bold))
                        .frame(minWidth: 60)
                    
                    Button("+") {
                        if glasses < 10 { glasses += 1 }
                    }
                    .buttonStyle(.bordered)
                }
                
                Button("Log \(glasses) glass\(glasses == 1 ? "" : "es")") {
                    // Handle water logging
                    onClose()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Water")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Close", action: onClose)
            }
        }
    }
}