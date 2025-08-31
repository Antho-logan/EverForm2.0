import SwiftUI

public struct LifestyleStep: View {
    @Environment(OnboardingStore.self) private var store
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Your lifestyle")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                
                Text("Help us understand your goals and habits")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 28) {
                // Goal Focus (multi-select)
                ChipGroup<GoalFocus>(
                    "What do you want to focus on?",
                    selection: Binding(
                        get: { store.draft.goalFocus },
                        set: { store.draft.goalFocus = $0 }
                    )
                )
                
                // Activity Level (single-select)
                SingleChipGroup<UserProfile.Activity>(
                    "How active are you?",
                    selection: Binding(
                        get: { store.draft.activity },
                        set: { store.draft.activity = $0 }
                    )
                )
                
                // Diet Approach (single-select)
                SingleChipGroup<UserProfile.Diet>(
                    "What's your diet approach?",
                    selection: Binding(
                        get: { store.draft.diet },
                        set: { store.draft.diet = $0 }
                    )
                )
            }
        }
    }
}
