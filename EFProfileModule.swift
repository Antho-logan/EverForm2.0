import SwiftUI

// MARK: - Profile Model
class ProfileModel: ObservableObject {
    // Personal Info
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var birthday: Date = .now
    @Published var sex: Sex = .male
    
    // Body Metrics
    @Published var heightCm: Double = 170.0
    @Published var weightKg: Double = 70.0
    @Published var unitSystem: UnitSystem = .metric
    
    // Goals
    @Published var stepsTarget: Int = 10000
    @Published var caloriesTarget: Int = 2400
    @Published var sleepHoursTarget: Double = 8.0
    @Published var waterMlTarget: Int = 2000
    
    // Preferences
    @Published var notificationsEnabled: Bool = true
    
    // Enums
    enum Sex: String, CaseIterable, Hashable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
    }
    
    enum UnitSystem: String, CaseIterable, Hashable {
        case metric = "Metric"
        case imperial = "Imperial"
    }
    
    // UserDefaults Keys
    private enum Keys {
        static let name = "profile_name"
        static let email = "profile_email"
        static let phone = "profile_phone"
        static let birthday = "profile_birthday"
        static let sex = "profile_sex"
        static let heightCm = "profile_height_cm"
        static let weightKg = "profile_weight_kg"
        static let unitSystem = "profile_unit_system"
        static let stepsTarget = "profile_steps_target"
        static let caloriesTarget = "profile_calories_target"
        static let sleepHoursTarget = "profile_sleep_hours_target"
        static let waterMlTarget = "profile_water_ml_target"
        static let notificationsEnabled = "profile_notifications_enabled"
    }
    
    init() {
        load()
    }
    
    func load() {
        let defaults = UserDefaults.standard
        
        name = defaults.string(forKey: Keys.name) ?? ""
        email = defaults.string(forKey: Keys.email) ?? ""
        phone = defaults.string(forKey: Keys.phone) ?? ""
        birthday = defaults.object(forKey: Keys.birthday) as? Date ?? .now
        sex = Sex(rawValue: defaults.string(forKey: Keys.sex) ?? "") ?? .male
        heightCm = defaults.double(forKey: Keys.heightCm)
        weightKg = defaults.double(forKey: Keys.weightKg)
        unitSystem = UnitSystem(rawValue: defaults.string(forKey: Keys.unitSystem) ?? "") ?? .metric
        stepsTarget = defaults.integer(forKey: Keys.stepsTarget)
        caloriesTarget = defaults.integer(forKey: Keys.caloriesTarget)
        sleepHoursTarget = defaults.double(forKey: Keys.sleepHoursTarget)
        waterMlTarget = defaults.integer(forKey: Keys.waterMlTarget)
        notificationsEnabled = defaults.bool(forKey: Keys.notificationsEnabled)
    }
    
    func save() {
        let defaults = UserDefaults.standard
        
        defaults.set(name, forKey: Keys.name)
        defaults.set(email, forKey: Keys.email)
        defaults.set(phone, forKey: Keys.phone)
        defaults.set(birthday, forKey: Keys.birthday)
        defaults.set(sex.rawValue, forKey: Keys.sex)
        defaults.set(heightCm, forKey: Keys.heightCm)
        defaults.set(weightKg, forKey: Keys.weightKg)
        defaults.set(unitSystem.rawValue, forKey: Keys.unitSystem)
        defaults.set(stepsTarget, forKey: Keys.stepsTarget)
        defaults.set(caloriesTarget, forKey: Keys.caloriesTarget)
        defaults.set(sleepHoursTarget, forKey: Keys.sleepHoursTarget)
        defaults.set(waterMlTarget, forKey: Keys.waterMlTarget)
        defaults.set(notificationsEnabled, forKey: Keys.notificationsEnabled)
    }
    
    // Computed properties for display
    var heightDisplay: String {
        if unitSystem == .metric {
            return String(format: "%.0f cm", heightCm)
        } else {
            let inches = heightCm * 0.393701
            let feet = Int(inches / 12)
            let remainingInches = Int(inches.truncatingRemainder(dividingBy: 12))
            return "\(feet)'\(remainingInches)\""
        }
    }
    
    var weightDisplay: String {
        if unitSystem == .metric {
            return String(format: "%.1f kg", weightKg)
        } else {
            let pounds = weightKg * 2.20462
            return String(format: "%.1f lb", pounds)
        }
    }
    
    var waterDisplay: String {
        if unitSystem == .metric {
            return "\(waterMlTarget) ml"
        } else {
            let oz = Double(waterMlTarget) * 0.033814
            return String(format: "%.0f oz", oz)
        }
    }
    
    // Preview data
    static var preview: ProfileModel {
        let model = ProfileModel()
        model.name = "Alex Chen"
        model.email = "alex@example.com"
        model.phone = "+1 (555) 123-4567"
        model.birthday = Calendar.current.date(from: DateComponents(year: 1990, month: 5, day: 15)) ?? .now
        model.sex = .male
        model.heightCm = 175.0
        model.weightKg = 72.0
        model.unitSystem = .metric
        model.stepsTarget = 12000
        model.caloriesTarget = 2400
        model.sleepHoursTarget = 8.0
        model.waterMlTarget = 2500
        model.notificationsEnabled = true
        return model
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @StateObject private var model = ProfileModel()
    @State private var isEditing = false
    @State private var editingField: EditableField?
    
    enum EditableField: String, Identifiable, CaseIterable {
        case name, email, phone, birthday, sex, height, weight, steps, calories, sleep, water
        
        var id: String { rawValue }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Header Section
                Section {
                    HStack(spacing: 16) {
                        // Avatar
                        Circle()
                            .fill(.blue.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.title)
                                    .foregroundStyle(.blue)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(model.name.isEmpty ? "Your Name" : model.name)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(model.email.isEmpty ? "your.email@example.com" : model.email)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Edit") {
                            isEditing = true
                        }
                        .buttonStyle(.bordered)
                        .accessibilityLabel("Edit profile")
                    }
                    .padding(.vertical, 8)
                }
                
                // Personal Info Section
                Section("Personal Info") {
                    ProfileRow(
                        title: "Name",
                        value: model.name.isEmpty ? "Not set" : model.name,
                        icon: "person",
                        action: { editingField = .name }
                    )
                    
                    ProfileRow(
                        title: "Email",
                        value: model.email.isEmpty ? "Not set" : model.email,
                        icon: "envelope",
                        action: { editingField = .email }
                    )
                    
                    ProfileRow(
                        title: "Phone",
                        value: model.phone.isEmpty ? "Not set" : model.phone,
                        icon: "phone",
                        action: { editingField = .phone }
                    )
                    
                    ProfileRow(
                        title: "Birthday",
                        value: model.birthday.formatted(date: .abbreviated, time: .omitted),
                        icon: "calendar",
                        action: { editingField = .birthday }
                    )
                    
                    ProfileRow(
                        title: "Sex",
                        value: model.sex.rawValue,
                        icon: "figure",
                        action: { editingField = .sex }
                    )
                }
                
                // Body Metrics Section
                Section("Body Metrics") {
                    ProfileRow(
                        title: "Height",
                        value: model.heightDisplay,
                        icon: "ruler",
                        action: { editingField = .height }
                    )
                    
                    ProfileRow(
                        title: "Weight",
                        value: model.weightDisplay,
                        icon: "scalemass",
                        action: { editingField = .weight }
                    )
                    
                    ProfileRow(
                        title: "Units",
                        value: model.unitSystem.rawValue,
                        icon: "gear",
                        action: { editingField = .weight } // Reuse weight edit for units
                    )
                } footer: {
                    Text("Height and weight are displayed in \(model.unitSystem.rawValue) units")
                }
                
                // Goals Section
                Section("Goals") {
                    ProfileRow(
                        title: "Steps",
                        value: model.stepsTarget.formatted(.number.notation(.compactName)),
                        icon: "figure.walk",
                        action: { editingField = .steps }
                    )
                    
                    ProfileRow(
                        title: "Calories",
                        value: "\(model.caloriesTarget) kcal",
                        icon: "flame",
                        action: { editingField = .calories }
                    )
                    
                    ProfileRow(
                        title: "Sleep",
                        value: "\(model.sleepHoursTarget) hrs",
                        icon: "bed.double",
                        action: { editingField = .sleep }
                    )
                    
                    ProfileRow(
                        title: "Hydration",
                        value: model.waterDisplay,
                        icon: "drop",
                        action: { editingField = .water }
                    )
                } footer: {
                    Text("Daily targets: \(model.stepsTarget.formatted()) steps, \(model.caloriesTarget) kcal, \(model.sleepHoursTarget) hrs sleep, \(model.waterDisplay)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Preferences Section
                Section("Preferences") {
                    Toggle("Notifications", isOn: $model.notificationsEnabled)
                        .onChange(of: model.notificationsEnabled) { _, _ in
                            model.save()
                        }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $editingField) { field in
                NavigationStack {
                    editView(for: field)
                }
            }
        }
    }
    
    @ViewBuilder
    private func editView(for field: EditableField) -> some View {
        switch field {
        case .name:
            EditTextFieldView(
                title: "Name",
                value: $model.name,
                keyboard: .name
            )
        case .email:
            EditTextFieldView(
                title: "Email",
                value: $model.email,
                keyboard: .emailAddress
            )
        case .phone:
            EditTextFieldView(
                title: "Phone",
                value: $model.phone,
                keyboard: .phonePad
            )
        case .birthday:
            EditDateView(
                title: "Birthday",
                date: $model.birthday
            )
        case .sex:
            EditPickerView(
                title: "Sex",
                selection: $model.sex,
                options: ProfileModel.Sex.allCases
            )
        case .height:
            EditNumberView(
                title: "Height",
                value: $model.heightCm,
                format: .number.precision(.fractionLength(0)),
                step: 1.0,
                unit: model.unitSystem == .metric ? "cm" : "in"
            )
        case .weight:
            VStack {
                EditNumberView(
                    title: "Weight",
                    value: $model.weightKg,
                    format: .number.precision(.fractionLength(1)),
                    step: 0.1,
                    unit: model.unitSystem == .metric ? "kg" : "lb"
                )
                
                EditPickerView(
                    title: "Unit System",
                    selection: $model.unitSystem,
                    options: ProfileModel.UnitSystem.allCases
                )
            }
        case .steps:
            EditNumberView(
                title: "Daily Steps Target",
                value: Binding(
                    get: { Double(model.stepsTarget) },
                    set: { model.stepsTarget = Int($0) }
                ),
                format: .number.precision(.fractionLength(0)),
                step: 100.0,
                unit: "steps"
            )
        case .calories:
            EditNumberView(
                title: "Daily Calories Target",
                value: Binding(
                    get: { Double(model.caloriesTarget) },
                    set: { model.caloriesTarget = Int($0) }
                ),
                format: .number.precision(.fractionLength(0)),
                step: 50.0,
                unit: "kcal"
            )
        case .sleep:
            EditNumberView(
                title: "Sleep Target",
                value: $model.sleepHoursTarget,
                format: .number.precision(.fractionLength(1)),
                step: 0.5,
                unit: "hours"
            )
        case .water:
            EditNumberView(
                title: "Hydration Target",
                value: Binding(
                    get: { Double(model.waterMlTarget) },
                    set: { model.waterMlTarget = Int($0) }
                ),
                format: .number.precision(.fractionLength(0)),
                step: 100.0,
                unit: model.unitSystem == .metric ? "ml" : "oz"
            )
        }
    }
}

// MARK: - Profile Row Component
struct ProfileRow: View {
    let title: String
    let value: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 30)
                
                Text(title)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text(value)
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
        .accessibilityHint("Double tap to edit")
    }
}

// MARK: - Edit Form Components

struct EditTextFieldView: View {
    let title: String
    @Binding var value: String
    let keyboardType: KeyboardType
    @Environment(\.dismiss) private var dismiss
    
    init(title: String, value: Binding<String>, keyboard: KeyboardType) {
        self.title = title
        self._value = value
        self.keyboardType = keyboard
    }
    
    enum KeyboardType {
        case `default`
        case emailAddress
        case phonePad
        case name
    }
    
    var body: some View {
        Form {
            Section {
                TextField(title, text: $value)
                    .submitLabel(.done)
            } header: {
                Text(title)
            } footer: {
                if keyboardType == .emailAddress && !value.isEmpty && !isValidEmail(value) {
                    Text("Please enter a valid email address")
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Edit \(title)")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if isValidInput {
                        // Save will be handled by parent view
                        dismiss()
                    }
                }
                .disabled(!isValidInput)
            }
        }
    }
    
    private var isValidInput: Bool {
        if value.isEmpty { return false }
        
        switch keyboardType {
        case .emailAddress:
            return isValidEmail(value)
        case .name:
            return value.count >= 2
        default:
            return !value.isEmpty
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
    }
}

struct EditPickerView<T: Hashable & CaseIterable>: View where T.AllCases: RandomAccessCollection {
    let title: String
    @Binding var selection: T
    let options: T.AllCases
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section {
                Picker(title, selection: $selection) {
                    ForEach(options, id: \.self) { option in
                        Text(String(describing: option)).tag(option)
                    }
                }
                .pickerStyle(.inline)
            }
        }
        .navigationTitle("Edit \(title)")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    dismiss()
                }
            }
        }
    }
}

struct EditNumberView: View {
    let title: String
    @Binding var value: Double
    let format: FloatingPointFormatStyle<Double>
    let step: Double
    let unit: String
    @Environment(\.dismiss) private var dismiss
    
    init(title: String, value: Binding<Double>, format: FloatingPointFormatStyle<Double>, step: Double, unit: String) {
        self.title = title
        self._value = value
        self.format = format
        self.step = step
        self.unit = unit
    }
    
    var body: some View {
        Form {
            Section {
                HStack {
                    TextField(title, value: $value, format: format)
                    
                    Text(unit)
                        .foregroundStyle(.secondary)
                }
                
                Stepper("Adjust", value: $value, in: range, step: step)
            } header: {
                Text(title)
            } footer: {
                if !isValidRange {
                    Text("Please enter a value between \(range.lowerBound) and \(range.upperBound)")
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Edit \(title)")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if isValidRange {
                        dismiss()
                    }
                }
                .disabled(!isValidRange)
            }
        }
    }
    
    private var range: ClosedRange<Double> {
        switch unit {
        case "cm":
            return 100...250
        case "in":
            return 39...98
        case "kg":
            return 30...200
        case "lb":
            return 66...441
        case "steps":
            return 1000...50000
        case "kcal":
            return 1000...5000
        case "hours":
            return 4...12
        case "ml":
            return 500...5000
        case "oz":
            return 17...169
        default:
            return 0...Double.greatestFiniteMagnitude
        }
    }
    
    private var isValidRange: Bool {
        range.contains(value)
    }
}

struct EditDateView: View {
    let title: String
    @Binding var date: Date
    @Environment(\.dismiss) private var dismiss
    
    init(title: String, date: Binding<Date>) {
        self.title = title
        self._date = date
    }
    
    var body: some View {
        Form {
            Section {
                DatePicker(title, selection: $date, in: ...Date.now, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }
        }
        .navigationTitle("Edit \(title)")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ProfileView()
    }
}
