import SwiftUI

public struct BasicInfoStep: View {
    @Environment(OnboardingStore.self) private var store
    @State private var useMetric = true
    @State private var feet = 5
    @State private var inches = 7
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Tell us about you")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                
                Text("We'll use this to personalize your experience")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                // Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's your name?")
                        .font(.headline)
                    
                    TextField("Enter your name", text: Binding(
                        get: { store.draft.name },
                        set: { store.draft.name = $0 }
                    ))
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)
                        .accessibilityLabel("Name")
                }
                
                // Birthday
                VStack(alignment: .leading, spacing: 8) {
                    Text("When were you born?")
                        .font(.headline)
                    
                    DatePicker(
                        "Birthday",
                        selection: Binding(
                            get: { store.draft.birthdate },
                            set: { store.draft.birthdate = $0 }
                        ),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .accessibilityLabel("Birthday")
                }
                
                // Height
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("How tall are you?")
                            .font(.headline)
                        
                        Spacer()
                        
                        Picker("Unit", selection: $useMetric) {
                            Text("cm").tag(true)
                            Text("ft/in").tag(false)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 100)
                    }
                    
                    if useMetric {
                        HStack {
                            TextField(
                                "Height",
                                value: Binding(
                                    get: { store.draft.heightCm },
                                    set: { store.draft.heightCm = $0 }
                                ),
                                format: .number.precision(.fractionLength(0))
                            )
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numberPad)
                            
                            Text("cm")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        HStack(spacing: 12) {
                            VStack {
                                Picker("Feet", selection: $feet) {
                                    ForEach(4...7, id: \.self) { ft in
                                        Text("\(ft) ft").tag(ft)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 100)
                            }
                            
                            VStack {
                                Picker("Inches", selection: $inches) {
                                    ForEach(0...11, id: \.self) { inch in
                                        Text("\(inch) in").tag(inch)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 100)
                            }
                        }
                        .onChange(of: feet) { _, _ in updateHeightFromImperial() }
                        .onChange(of: inches) { _, _ in updateHeightFromImperial() }
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Height")
                
                // Weight
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's your weight?")
                        .font(.headline)
                    
                    Toggle("I don't know", isOn: Binding(
                        get: { store.draft.weightUnknown },
                        set: { store.draft.weightUnknown = $0 }
                    ))
                        .toggleStyle(.switch)
                    
                    if !store.draft.weightUnknown {
                        HStack {
                            TextField(
                                "Weight",
                                value: Binding(
                                    get: { store.draft.weightKg ?? 70.0 },
                                    set: { store.draft.weightKg = $0 }
                                ),
                                format: .number.precision(.fractionLength(1))
                            )
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.decimalPad)
                            
                            Text("kg")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Weight")
            }
        }
        .onAppear {
            updateImperialFromHeight()
        }
        .onChange(of: useMetric) { _, newValue in
            if !newValue {
                updateImperialFromHeight()
            }
        }
        .onChange(of: store.draft.weightUnknown) { _, unknown in
            if unknown {
                store.draft.weightKg = nil
            } else if store.draft.weightKg == nil {
                store.draft.weightKg = 70.0
            }
        }
    }
    
    private func updateHeightFromImperial() {
        store.draft.heightCm = OnboardingStore.feetInchesToCm(feet: feet, inches: inches)
    }
    
    private func updateImperialFromHeight() {
        let (f, i) = OnboardingStore.cmToFeetInches(store.draft.heightCm)
        feet = f
        inches = i
    }
}
