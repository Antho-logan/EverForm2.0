import SwiftUI

struct StepGoalsView: View {
    @Binding var draft: OnboardingDraftState
    @Binding var isValid: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @State private var newGoal = ""
    @FocusState private var goalFieldFocused: Bool
    
    private let goalSuggestions = [
        "Lose 10 pounds",
        "Build muscle",
        "Sleep better",
        "Increase energy",
        "Reduce stress",
        "Eat more vegetables",
        "Stay consistent with workouts"
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Your goals (optional)")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                
                Text("What would you like to achieve?")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tell us up to 3 specific goals")
                        .font(.headline)
                    Text("Short, specific outcomes for the next 30–90 days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Add new goal
                VStack(spacing: 12) {
                    TextField(
                        "e.g., Lose 10 pounds, Build muscle, Sleep better...",
                        text: $newGoal,
                        axis: .vertical
                    )
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)
                    .focused($goalFieldFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        addGoal()
                    }
                    
                    HStack {
                        Spacer()
                        
                        Button("Add Goal") {
                            UX.Haptic.light()
                            addGoal()
                        }
                        .buttonStyle(.bordered)
                        .disabled(newGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || draft.goals.count >= 3)
                        .accessibilityLabel("Add goal to your list")
                        .accessibilityHint(draft.goals.count >= 3 ? "Maximum 3 goals reached" : "Add this goal to your list")
                    }
                }
                
                // Current goals
                if !draft.goals.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Goals (\(draft.goals.count)/3)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        ForEach(Array(draft.goals.enumerated()), id: \.offset) { index, goal in
                            HStack {
                                Text("\(index + 1). \(goal)")
                                    .font(.body)
                                Spacer()
                                Button {
                                    UX.Haptic.light()
                                    removeGoal(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                                .accessibilityLabel("Remove goal: \(goal)")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                
                // Suggestions
                if draft.goals.count < 3 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Popular goals")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 8) {
                            ForEach(goalSuggestions, id: \.self) { suggestion in
                                Button(suggestion) {
                                    if !draft.goals.contains(suggestion) && draft.goals.count < 3 {
                                        UX.Haptic.light()
                                        let animation = UX.Anim.adaptive(UX.Anim.snappy(0.2), reduceMotion: reduceMotion)
                                        withAnimation(animation) {
                                            draft.goals.append(suggestion)
                                            validateForm()
                                        }
                                        UX.A11y.announce("Added \(suggestion) to your goals")
                                    }
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.small)
                                .disabled(draft.goals.contains(suggestion))
                            }
                        }
                    }
                }
            }
        }
        .onAppear { validateForm() }
    }
    
    private func addGoal() {
        let trimmed = newGoal.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !draft.goals.contains(trimmed) && draft.goals.count < 3 {
            let animation = UX.Anim.adaptive(UX.Anim.snappy(0.2), reduceMotion: reduceMotion)
            withAnimation(animation) {
                draft.goals.append(trimmed)
                newGoal = ""
                validateForm()
            }
            
            UX.Haptic.light()
            UX.A11y.announce("Added \(trimmed) to your goals")
        }
    }
    
    private func removeGoal(at index: Int) {
        let goal = draft.goals[index]
        let animation = UX.Anim.adaptive(UX.Anim.snappy(0.2), reduceMotion: reduceMotion)
        withAnimation(animation) {
            draft.goals.remove(at: index)
            validateForm()
        }
        UX.A11y.announce("Removed \(goal) from your goals")
    }
    
    private func validateForm() {
        // Goals step is always valid since it's optional
        isValid = true
    }
}

#Preview {
    @Previewable @State var draft = OnboardingDraftState()
    @Previewable @State var isValid = false
    
    StepGoalsView(draft: $draft, isValid: $isValid)
        .padding()
}
