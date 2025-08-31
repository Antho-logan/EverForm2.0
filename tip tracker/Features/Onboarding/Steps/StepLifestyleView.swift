import SwiftUI

struct StepLifestyleView: View {
    @Binding var draft: OnboardingDraft
    @Binding var isValid: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @State private var newAllergy = ""
    @FocusState private var allergyFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Your lifestyle")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                
                Text("Help us understand your goals and habits")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 28) {
                // Goal
                VStack(alignment: .leading, spacing: 12) {
                    Text("What's your main goal?")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 1), spacing: 8) {
                        ForEach(UserProfile.Goal.allCases, id: \.self) { goal in
                            ChipButton(
                                goal.rawValue,
                                isSelected: draft.goal == goal
                            ) {
                                UX.Haptic.light()
                                let animation = UX.Anim.adaptive(UX.Anim.snappy(0.2), reduceMotion: reduceMotion)
                                withAnimation(animation) {
                                    draft.goal = goal
                                    validateForm()
                                }
                            }
                        }
                    }
                }
                
                // Activity Level
                VStack(alignment: .leading, spacing: 12) {
                    Text("How active are you?")
                        .font(.headline)
                    
                    Picker("Activity Level", selection: $draft.activity) {
                        ForEach(UserProfile.Activity.allCases, id: \.self) { activity in
                            Text(activity.rawValue.capitalized).tag(activity)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: draft.activity) { _, _ in
                        UX.Haptic.light()
                        validateForm()
                    }
                }
                
                // Diet Approach
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("What's your dietary approach?")
                            .font(.headline)
                        Text("Pick one (or skip)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(UserProfile.Diet.allCases, id: \.self) { diet in
                            ChipButton(
                                diet.rawValue,
                                isSelected: draft.diet == diet
                            ) {
                                UX.Haptic.light()
                                let animation = UX.Anim.adaptive(UX.Anim.snappy(0.2), reduceMotion: reduceMotion)
                                withAnimation(animation) {
                                    draft.diet = diet
                                    validateForm()
                                }
                            }
                        }
                    }
                }
                
                // Allergies/Intolerances
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Any food allergies or intolerances?")
                            .font(.headline)
                        Text("Type and press return to add")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Add new allergy
                    HStack {
                        TextField("Add allergy or intolerance", text: $newAllergy)
                            .textFieldStyle(.roundedBorder)
                            .focused($allergyFieldFocused)
                            .submitLabel(.done)
                            .onSubmit {
                                addAllergy()
                            }
                        
                        Button("Add") {
                            UX.Haptic.light()
                            addAllergy()
                        }
                        .buttonStyle(.bordered)
                        .disabled(newAllergy.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .accessibilityLabel("Add allergy or intolerance")
                    }
                    
                    // Current allergies
                    if !draft.allergies.isEmpty {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(draft.allergies, id: \.self) { allergy in
                                HStack {
                                    Text(allergy)
                                        .font(.caption)
                                    Spacer()
                                    Button {
                                        UX.Haptic.light()
                                        removeAllergy(allergy)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                    .accessibilityLabel("Remove \(allergy)")
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.gray.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
            }
        }
        .onAppear { validateForm() }
    }
    
    private func addAllergy() {
        let trimmed = newAllergy.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !draft.allergies.contains(trimmed) {
            let animation = UX.Anim.adaptive(UX.Anim.snappy(0.2), reduceMotion: reduceMotion)
            withAnimation(animation) {
                draft.allergies.append(trimmed)
                newAllergy = ""
                validateForm()
            }
            
            UX.Haptic.light()
            UX.A11y.announce("Added \(trimmed) to allergies")
        }
    }
    
    private func removeAllergy(_ allergy: String) {
        let animation = UX.Anim.adaptive(UX.Anim.snappy(0.2), reduceMotion: reduceMotion)
        withAnimation(animation) {
            draft.allergies.removeAll { $0 == allergy }
            validateForm()
        }
        UX.A11y.announce("Removed \(allergy) from allergies")
    }
    
    private func validateForm() {
        // Lifestyle step is always valid since we have defaults
        isValid = true
    }
}



#Preview {
    @Previewable @State var draft = OnboardingDraft()
    @Previewable @State var isValid = false
    
    StepLifestyleView(draft: $draft, isValid: $isValid)
        .padding()
}