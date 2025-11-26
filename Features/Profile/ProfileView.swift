import SwiftUI

struct ProfileView: View {
    @Environment(ProfileStore.self) private var store
    @State private var showQuickEdit = false
    @State private var editingField: EditableField?
    
    // Local state for notifications (since it's not in UserProfile)
    @AppStorage("profile_notifications_enabled") private var notificationsEnabled = true
    
    enum EditableField: String, Identifiable, CaseIterable {
        case name, email, phone, birthday, sex, height, weight, unitSystem, steps, calories, sleep, water
        
        var id: String { rawValue }
    }
    
    var body: some View {
        // Create a bindable proxy for the store
        @Bindable var bindableStore = store
        
        NavigationStack {
            ScrollView {
                if let profile = store.profile, let targets = store.targets {
                    LazyVStack(spacing: 28) {
                        ProfileHero(profile: profile, targets: targets) {
                            showQuickEdit = true
                        }
                        .padding(.top, 8)

                        ProfileSection(title: "Personal Info", subtitle: "Keep your account info up to date") {
                            ProfileRow(
                                title: "Name",
                                value: profile.name.isEmpty ? "Not set" : profile.name,
                                icon: "person",
                                tint: .blue,
                                action: { editingField = .name }
                            )
                            Divider().padding(.leading, 56)
                            ProfileRow(
                                title: "Email",
                                value: profile.email.isEmpty ? "Not set" : profile.email,
                                icon: "envelope",
                                tint: .orange,
                                action: { editingField = .email }
                            )
                            Divider().padding(.leading, 56)
                            ProfileRow(
                                title: "Phone",
                                value: profile.phone.isEmpty ? "Not set" : profile.phone,
                                icon: "phone",
                                tint: .green,
                                action: { editingField = .phone }
                            )
                            Divider().padding(.leading, 56)
                            ProfileRow(
                                title: "Birthday",
                                value: profile.birthdate.formatted(date: .abbreviated, time: .omitted),
                                icon: "calendar",
                                tint: .purple,
                                action: { editingField = .birthday }
                            )
                            Divider().padding(.leading, 56)
                            ProfileRow(
                                title: "Sex",
                                value: profile.sex.rawValue,
                                icon: "figure",
                                tint: .pink,
                                action: { editingField = .sex }
                            )
                        }

                        ProfileSection(title: "Body Metrics", subtitle: "Measurements shown in \(profile.unitSystem.rawValue) units") {
                            ProfileRow(
                                title: "Height",
                                value: heightDisplay(profile),
                                icon: "ruler",
                                tint: .teal,
                                action: { editingField = .height }
                            )
                            Divider().padding(.leading, 56)
                            ProfileRow(
                                title: "Weight",
                                value: weightDisplay(profile),
                                icon: "scalemass",
                                tint: .indigo,
                                action: { editingField = .weight }
                            )
                            Divider().padding(.leading, 56)
                            ProfileRow(
                                title: "Units",
                                value: profile.unitSystem.rawValue,
                                icon: "gearshape",
                                tint: .gray,
                                action: { editingField = .unitSystem }
                            )
                        }

                        ProfileSection(title: "Goals", subtitle: "Targets synced with your dashboard") {
                            ProfileRow(
                                title: "Steps",
                                value: targets.steps.formatted(.number.notation(.compactName)),
                                icon: "figure.walk",
                                tint: .green,
                                action: { editingField = .steps }
                            )
                            Divider().padding(.leading, 56)
                            ProfileRow(
                                title: "Calories",
                                value: "\(targets.targetCalories) kcal",
                                icon: "flame",
                                tint: .orange,
                                action: { editingField = .calories }
                            )
                            Divider().padding(.leading, 56)
                            ProfileRow(
                                title: "Sleep",
                                value: "\(targets.sleepHours) hrs",
                                icon: "bed.double",
                                tint: .blue,
                                action: { editingField = .sleep }
                            )
                            Divider().padding(.leading, 56)
                            ProfileRow(
                                title: "Hydration",
                                value: waterDisplay(profile: profile, targets: targets),
                                icon: "drop",
                                tint: .teal,
                                action: { editingField = .water }
                            )
                        }

                        ProfileSection(title: "Preferences") {
                            Toggle(isOn: $notificationsEnabled) {
                                HStack(spacing: 16) {
                                    IconBadge(icon: "bell.fill", tint: .pink)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Notifications")
                                            .font(.headline)
                                        Text("Stay in the loop with reminders")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .pink))
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                } else {
                    ContentUnavailableView("Profile Not Loaded", systemImage: "person.crop.circle.badge.exclamationmark")
                }
            }
            .background(DesignSystem.Colors.background.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showQuickEdit) {
                if let profileBinding = Binding(item: $bindableStore.profile) {
                    NavigationStack {
                        ProfileQuickEditView(profile: profileBinding)
                    }
                }
            }
            .onChange(of: showQuickEdit) { _, newValue in
                if !newValue {
                    // On dismiss, save
                    if let p = store.profile, let t = store.targets {
                        store.save(profile: p, targets: t)
                    }
                }
            }
            .sheet(item: $editingField, onDismiss: {
                if let p = store.profile, let t = store.targets {
                    store.save(profile: p, targets: t)
                }
            }) { field in
                NavigationStack {
                    editView(for: field)
                }
            }
        }
    }
    
    @ViewBuilder
    private func editView(for field: EditableField) -> some View {
        // Safe bindings
        if var profile = store.profile, var targets = store.targets {
            let profileBinding = Binding(
                get: { store.profile ?? profile },
                set: { store.profile = $0 }
            )
            let targetsBinding = Binding(
                get: { store.targets ?? targets },
                set: { store.updateTargets($0) } // updateTargets handles internal save, but we also save on dismiss for profile
            )
            
            switch field {
            case .name:
                EditTextFieldView(title: "Name", value: profileBinding.name, keyboard: .name)
            case .email:
                EditTextFieldView(title: "Email", value: profileBinding.email, keyboard: .emailAddress)
            case .phone:
                EditTextFieldView(title: "Phone", value: profileBinding.phone, keyboard: .phonePad)
            case .birthday:
                EditDateView(title: "Birthday", date: profileBinding.birthdate)
            case .sex:
                EditPickerView(title: "Sex", selection: profileBinding.sex, options: UserProfile.Sex.allCases)
            case .height:
                EditNumberView(
                    title: "Height",
                    value: profileBinding.heightCm,
                    format: .number.precision(.fractionLength(0)),
                    step: 1.0,
                    unit: profile.unitSystem == .metric ? "cm" : "in"
                )
            case .weight:
                EditNumberView(
                    title: "Weight",
                    value: profileBinding.weightKg,
                    format: .number.precision(.fractionLength(1)),
                    step: 0.1,
                    unit: profile.unitSystem == .metric ? "kg" : "lb"
                )
            case .unitSystem:
                EditPickerView(title: "Unit System", selection: profileBinding.unitSystem, options: UserProfile.UnitSystem.allCases)
            case .steps:
                EditNumberView(
                    title: "Daily Steps Target",
                    value: Binding(
                        get: { Double(targetsBinding.wrappedValue.steps) },
                        set: { targetsBinding.wrappedValue.steps = Int($0) }
                    ),
                    format: .number.precision(.fractionLength(0)),
                    step: 100.0,
                    unit: "steps"
                )
            case .calories:
                EditNumberView(
                    title: "Daily Calories Target",
                    value: Binding(
                        get: { Double(targetsBinding.wrappedValue.targetCalories) },
                        set: { targetsBinding.wrappedValue.targetCalories = Int($0) }
                    ),
                    format: .number.precision(.fractionLength(0)),
                    step: 50.0,
                    unit: "kcal"
                )
            case .sleep:
                EditNumberView(
                    title: "Sleep Target",
                    value: targetsBinding.sleepHours,
                    format: .number.precision(.fractionLength(1)),
                    step: 0.5,
                    unit: "hours"
                )
            case .water:
                EditNumberView(
                    title: "Hydration Target",
                    value: Binding(
                        get: { Double(targetsBinding.wrappedValue.hydrationMl) },
                        set: { targetsBinding.wrappedValue.hydrationMl = Int($0) }
                    ),
                    format: .number.precision(.fractionLength(0)),
                    step: 100.0,
                    unit: profile.unitSystem == .metric ? "ml" : "oz"
                )
            }
        }
    }
    
    // Helper functions for display logic
    private func heightDisplay(_ profile: UserProfile) -> String {
        if profile.unitSystem == .metric {
            return String(format: "%.0f cm", profile.heightCm)
        } else {
            let inches = profile.heightCm * 0.393701
            let feet = Int(inches / 12)
            let remainingInches = Int(inches.truncatingRemainder(dividingBy: 12))
            return "\(feet)'\(remainingInches)\""
        }
    }
    
    private func weightDisplay(_ profile: UserProfile) -> String {
        if profile.unitSystem == .metric {
            return String(format: "%.1f kg", profile.weightKg)
        } else {
            let pounds = profile.weightKg * 2.20462
            return String(format: "%.1f lb", pounds)
        }
    }
    
    private func waterDisplay(profile: UserProfile, targets: UserTargets) -> String {
        if profile.unitSystem == .metric {
            return "\(targets.hydrationMl) ml"
        } else {
            let oz = Double(targets.hydrationMl) * 0.033814
            return String(format: "%.0f oz", oz)
        }
    }
}

// Helper for optional binding
extension Binding {
    init?(item: Binding<Value?>) {
        guard let value = item.wrappedValue else { return nil }
        self.init(
            get: { item.wrappedValue ?? value },
            set: { item.wrappedValue = $0 }
        )
    }
}
