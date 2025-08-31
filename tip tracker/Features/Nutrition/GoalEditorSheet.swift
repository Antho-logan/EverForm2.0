//
//  GoalEditorSheet.swift
//  EverForm
//
//  Inline goal editor for nutrition targets
//  Applied: T-UI, S-OBS2, P-ARCH, C-SIMPLE, R-LOGS
//

import SwiftUI

struct GoalEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let nutritionStore: NutritionStore
    
    @State private var calories: String
    @State private var protein: String
    @State private var carbs: String
    @State private var fat: String
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case calories, protein, carbs, fat
    }
    
    init(nutritionStore: NutritionStore) {
        self.nutritionStore = nutritionStore
        
        let goal = nutritionStore.defaultGoal
        self._calories = State(initialValue: "\(goal.kcal)")
        self._protein = State(initialValue: "\(goal.protein)")
        self._carbs = State(initialValue: "\(goal.carbs)")
        self._fat = State(initialValue: "\(goal.fat)")
    }
    
    private var isValid: Bool {
        guard let cal = Int(calories), cal > 0,
              let prot = Int(protein), prot >= 0,
              let carb = Int(carbs), carb >= 0,
              let fatVal = Int(fat), fatVal >= 0 else {
            return false
        }
        return true
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Header
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Text("Adjust Goals")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Set your daily nutrition targets")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.top, DesignSystem.Spacing.md)
                
                // Input Fields
                VStack(spacing: DesignSystem.Spacing.md) {
                    GoalInputField(
                        title: "Calories",
                        value: $calories,
                        unit: "kcal"
                    )
                    
                    GoalInputField(
                        title: "Protein",
                        value: $protein,
                        unit: "g"
                    )
                    
                    GoalInputField(
                        title: "Carbs",
                        value: $carbs,
                        unit: "g"
                    )
                    
                    GoalInputField(
                        title: "Fat",
                        value: $fat,
                        unit: "g"
                    )
                }
                
                // Presets
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Quick Presets")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        GoalPresetButton(title: "Moderate", calories: 2000, protein: 150, carbs: 250, fat: 67) {
                            applyPreset(calories: 2000, protein: 150, carbs: 250, fat: 67)
                        }
                        
                        GoalPresetButton(title: "Active", calories: 2200, protein: 165, carbs: 275, fat: 73) {
                            applyPreset(calories: 2200, protein: 165, carbs: 275, fat: 73)
                        }
                        
                        GoalPresetButton(title: "High Protein", calories: 2000, protein: 200, carbs: 200, fat: 67) {
                            applyPreset(calories: 2000, protein: 200, carbs: 200, fat: 67)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, DesignSystem.Spacing.screenPadding)
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
                        saveGoals()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isValid)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private func applyPreset(calories: Int, protein: Int, carbs: Int, fat: Int) {
        self.calories = "\(calories)"
        self.protein = "\(protein)"
        self.carbs = "\(carbs)"
        self.fat = "\(fat)"
        
        // Light haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    private func saveGoals() {
        guard let cal = Int(calories),
              let prot = Int(protein),
              let carb = Int(carbs),
              let fatVal = Int(fat) else {
            return
        }
        
        let newGoal = NutritionGoal(
            kcal: cal,
            protein: prot,
            carbs: carb,
            fat: fatVal
        )
        
        nutritionStore.updateGoal(newGoal)
        
        // Success haptic
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        dismiss()
        
        DebugLog.info("Updated nutrition goals: \(newGoal.displayString)")
    }
}

// MARK: - Goal Input Field

struct GoalInputField: View {
    let title: String
    @Binding var value: String
    let unit: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .frame(width: 80, alignment: .leading)
            
            Spacer()
            
            HStack(spacing: 8) {
                TextField("0", text: $value)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 80)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(DesignSystem.Colors.cardBackgroundElevated)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.sm))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.Radius.sm)
                            .stroke(DesignSystem.Border.outlineColor, lineWidth: 1)
                    )
                
                Text(unit)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .leading)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title) \(value) \(unit)")
    }
}

// MARK: - Goal Preset Button

struct GoalPresetButton: View {
    let title: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("\(calories) kcal")
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text("P:\(protein) C:\(carbs) F:\(fat)")
                    .font(.system(size: 9, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .background(DesignSystem.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.sm)
                    .stroke(DesignSystem.Border.outlineColor, lineWidth: DesignSystem.Border.outline)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title) preset: \(calories) calories, \(protein) grams protein, \(carbs) grams carbs, \(fat) grams fat")
    }
}

#Preview {
    GoalEditorSheet(nutritionStore: NutritionStore())
}
