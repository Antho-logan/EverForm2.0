import SwiftUI

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

struct EditPickerView<T: Hashable & CaseIterable & RawRepresentable>: View where T.AllCases: RandomAccessCollection, T.RawValue == String {
    let title: String
    @Binding var selection: T
    let options: T.AllCases
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section {
                Picker(title, selection: $selection) {
                    ForEach(options, id: \.self) { option in
                        Text(option.rawValue).tag(option)
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
                        .keyboardType(.decimalPad)
                    
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
        case "cm": return 50...250
        case "in": return 20...100
        case "kg": return 20...300
        case "lb": return 40...660
        case "steps": return 1000...100000
        case "kcal": return 500...10000
        case "hours": return 0...24
        case "ml": return 0...10000
        case "oz": return 0...350
        default: return 0...Double.greatestFiniteMagnitude
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
