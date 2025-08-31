import SwiftUI

struct StepBasicView: View {
    @Binding var draft: OnboardingDraft
    @Binding var isValid: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    @State private var useMetric = true
    @State private var feet = 5
    @State private var inches = 7
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case name, weight
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Tell us about you")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .accessibilityAddTraits(.isHeader)
                
                Text("We'll use this to create your personalized plan")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                // Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("First Name")
                        .font(.headline)
                    
                    TextField("Enter your name", text: $draft.name)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.givenName)
                        .focused($focusedField, equals: .name)
                        .submitLabel(.next)
                        .accessibilityLabel("First name")
                        .accessibilityHint("Enter your first name to personalize your experience")
                        .onSubmit {
                            UX.Haptic.light()
                            focusedField = .weight
                        }
                }
                
                // Sex
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sex")
                        .font(.headline)
                    
                    Picker("Sex", selection: $draft.sex) {
                        ForEach(UserProfile.Sex.allCases, id: \.self) { sex in
                            Text(sex.rawValue.capitalized).tag(sex)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: draft.sex) { _, _ in
                        UX.Haptic.light()
                        validateForm()
                    }
                }
                
                // Birthday
                VStack(alignment: .leading, spacing: 8) {
                    Text("Birthday")
                        .font(.headline)
                    
                    DatePicker("Birthday", selection: $draft.birthdate, displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .onChange(of: draft.birthdate) { _, _ in
                            validateForm()
                        }
                }
                
                // Height
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Height")
                                .font(.headline)
                            Spacer()
                            Button(useMetric ? "cm" : "ft/in") {
                                UX.Haptic.light()
                                let animation = UX.Anim.adaptive(UX.Anim.snappy(0.3), reduceMotion: reduceMotion)
                                withAnimation(animation) {
                                    useMetric.toggle()
                                    convertHeight()
                                }
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            .accessibilityLabel("Toggle height units")
                            .accessibilityValue(useMetric ? "Centimeters" : "Feet and inches")
                        }
                        
                        Text("You can switch units anytime")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if useMetric {
                        HStack {
                            TextField(
                                "Height",
                                value: $draft.heightCm,
                                format: .number.precision(.fractionLength(0))
                            )
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            .onChange(of: draft.heightCm) { _, _ in
                                validateForm()
                            }
                            
                            Text("cm")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        HStack(spacing: 12) {
                            VStack {
                                Picker("Feet", selection: $feet) {
                                    ForEach(4...7, id: \.self) { ft in
                                        Text("\(ft)").tag(ft)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 60)
                                Text("ft")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            VStack {
                                Picker("Inches", selection: $inches) {
                                    ForEach(0...11, id: \.self) { inch in
                                        Text("\(inch)").tag(inch)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 60)
                                Text("in")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(height: 120)
                        .onChange(of: feet) { _, _ in convertHeightFromImperial() }
                        .onChange(of: inches) { _, _ in convertHeightFromImperial() }
                    }
                }
                
                // Weight
                VStack(alignment: .leading, spacing: 8) {
                    Text("Weight")
                        .font(.headline)
                    
                    if !draft.weightUnknown {
                        HStack {
                            TextField(
                                "Weight",
                                value: $draft.weightKg,
                                format: .number.precision(.fractionLength(1))
                            )
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .weight)
                            .submitLabel(.done)
                            .onSubmit {
                                UX.Haptic.light()
                                focusedField = nil
                            }
                            .onChange(of: draft.weightKg) { _, _ in
                                validateForm()
                            }
                            
                            Text("kg")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Toggle("I don't know my weight", isOn: $draft.weightUnknown)
                        .onChange(of: draft.weightUnknown) { _, newValue in
                            UX.Haptic.light()
                            let animation = UX.Anim.adaptive(UX.Anim.snappy(0.3), reduceMotion: reduceMotion)
                            withAnimation(animation) {
                                if newValue {
                                    draft.weightKg = 70.0 // Default estimate
                                    focusedField = nil // Dismiss keyboard
                                }
                                validateForm()
                            }
                        }
                        .accessibilityHint("Toggle if you don't know your current weight")
                }
            }
        }
        .onAppear {
            updateHeightFromMetric()
            validateForm()
        }
    }
    
    private func convertHeight() {
        if useMetric {
            // Convert from ft/in to cm
            let totalInches = Double(feet * 12 + inches)
            draft.heightCm = totalInches * 2.54
        } else {
            // Convert from cm to ft/in
            updateHeightFromMetric()
        }
    }
    
    private func updateHeightFromMetric() {
        let totalInches = draft.heightCm / 2.54
        feet = Int(totalInches / 12)
        inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
    }
    
    private func convertHeightFromImperial() {
        let totalInches = Double(feet * 12 + inches)
        draft.heightCm = totalInches * 2.54
        validateForm()
    }
    
    private func validateForm() {
        isValid = !draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

#Preview {
    @Previewable @State var draft = OnboardingDraft()
    @Previewable @State var isValid = false
    
    StepBasicView(draft: $draft, isValid: $isValid)
        .padding()
}