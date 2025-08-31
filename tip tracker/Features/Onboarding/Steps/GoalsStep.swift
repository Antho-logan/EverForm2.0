import SwiftUI

public struct GoalsStep: View {
    @Environment(OnboardingStore.self) private var store
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Your goals")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                
                Text("Anything specific you'd like to work on? (Optional)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Tell us more about your goals")
                    .font(.headline)
                
                TextField(
                    "I want to improve my energy levels, sleep better, and build a sustainable routine...",
                    text: Binding(
                        get: { store.draft.notes },
                        set: { store.draft.notes = $0 }
                    ),
                    axis: .vertical
                )
                .textFieldStyle(.roundedBorder)
                .lineLimit(4...8)
                .textContentType(.none)
                .accessibilityLabel("Goals and notes")
            }
            
            // Info box
            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.orange)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pro tip")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text("The more specific you are, the better we can personalize your experience.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(16)
            .background(.orange.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
