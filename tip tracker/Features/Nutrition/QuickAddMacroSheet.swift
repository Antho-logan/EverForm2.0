//
//  QuickAddMacroSheet.swift
//  EverForm
//
//  Quick add sheet for manual macro entry
//  Applied: T-UI, S-OBS2, P-ARCH, C-SIMPLE, R-LOGS
//

import SwiftUI

struct QuickAddMacroSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NutritionStore.self) private var nutritionStore
    
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fat: String = ""
    @State private var selectedTime = Date()
    @State private var showToast = false
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case calories, protein, carbs, fat
    }
    
    private var isValid: Bool {
        guard let cal = Int(calories), cal > 0 else { return false }
        return true
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Header
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Text("Quick Add")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Enter calories and optional macros")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, DesignSystem.Spacing.md)
                    
                    // Input Fields
                    VStack(spacing: DesignSystem.Spacing.md) {
                        // Calories (Required)
                        MacroInputField(
                            title: "Calories",
                            subtitle: "Required",
                            value: $calories,
                            placeholder: "0",
                            isRequired: true
                        )
                        
                        // Protein (Optional)
                        MacroInputField(
                            title: "Protein",
                            subtitle: "grams (optional)",
                            value: $protein,
                            placeholder: "0"
                        )
                        
                        // Carbs (Optional)
                        MacroInputField(
                            title: "Carbs",
                            subtitle: "grams (optional)",
                            value: $carbs,
                            placeholder: "0"
                        )
                        
                        // Fat (Optional)
                        MacroInputField(
                            title: "Fat",
                            subtitle: "grams (optional)",
                            value: $fat,
                            placeholder: "0"
                        )
                    }
                    
                    // Time Selection
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Time")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
            .overlay(
                // Toast Overlay
                VStack {
                    Spacer()
                    if showToast {
                        Text("Added to nutrition diary")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.black.opacity(0.8))
                            .clipShape(Capsule())
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showToast)
                    }
                }
                .padding(.bottom, 20),
                alignment: .bottom
            )
        }
        .presentationDetents([.large])
        .onAppear {
            TelemetryService.shared.track("nutrition_quick_add_opened")
        }
    }
    
    private func saveEntry() {
        guard let cal = Int(calories), cal > 0 else { return }
        
        let proteinValue = Double(protein) ?? 0
        let carbsValue = Double(carbs) ?? 0
        let fatValue = Double(fat) ?? 0
        
        // Create entry with selected time
        var entryTime = selectedTime
        
        // If time is in the future, use current time instead
        if entryTime > Date() {
            entryTime = Date()
        }
        
        let entry = MealEntry.quickAdd(
            kcal: cal,
            protein: proteinValue > 0 ? proteinValue : nil,
            carbs: carbsValue > 0 ? carbsValue : nil,
            fat: fatValue > 0 ? fatValue : nil,
            time: entryTime
        )
        
        nutritionStore.addEntry(entry)
        
        // Auto-open the diary after a successful Quick Add
        NotificationCenter.default.post(name: .nutritionOpenDiary, object: nil)
        
        // Success haptic
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        // Show toast
        showToast = true
        
        // Dismiss after showing toast
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
        
        DebugLog.info("Quick add saved: \(cal) kcal, P: \(proteinValue)g, C: \(carbsValue)g, F: \(fatValue)g")
    }
}

// MARK: - Macro Input Field

struct MacroInputField: View {
    let title: String
    let subtitle: String
    @Binding var value: String
    let placeholder: String
    var isRequired: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                if isRequired {
                    Text("*")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            TextField(placeholder, text: $value)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .keyboardType(.numberPad)
                .padding(DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.cardBackgroundElevated)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.sm))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.sm)
                        .stroke(DesignSystem.Border.outlineColor, lineWidth: 1)
                )
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) \(subtitle)")
    }
}

#Preview {
    QuickAddMacroSheet()
        .environment(NutritionStore())
}
