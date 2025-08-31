//
//  QuickMealSheet.swift
//  EverForm
//
//  Manual nutrition entry with macro fields
//  Assumptions: Simple form validation, UserDefaults persistence
//

import SwiftUI

struct QuickMealSheet: View {
    @Environment(\.dismiss) private var dismiss
    let nutritionService: NutritionLogService
    let onMealAdded: () -> Void
    
    @State private var mealName = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var showingValidationError = false
    @State private var validationMessage = ""
    
    private var isValid: Bool {
        !calories.isEmpty && Int(calories) != nil && Int(calories) ?? 0 > 0
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quick Add Meal")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Manually log your nutrition")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    // Form
                    VStack(spacing: 20) {
                        // Meal Name (Optional)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Meal Name (Optional)")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.secondary)
                            
                            TextField("e.g., Chicken & Rice", text: $mealName)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Calories (Required)
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Calories")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.secondary)
                                
                                Text("*")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(.red)
                            }
                            
                            TextField("0", text: $calories)
                                .keyboardType(.numberPad)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Macros (Optional)
                        Text("Macronutrients (Optional)")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Protein (g)")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                                
                                TextField("0", text: $protein)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Carbs (g)")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                                
                                TextField("0", text: $carbs)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Fat (g)")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                                
                                TextField("0", text: $fat)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                        }
                        
                        // Quick Presets
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick Presets")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                PresetButton(title: "Protein Shake", calories: 150, protein: 25, carbs: 5, fat: 2) {
                                    applyPreset(name: "Protein Shake", calories: 150, protein: 25, carbs: 5, fat: 2)
                                }
                                
                                PresetButton(title: "Banana", calories: 105, protein: 1, carbs: 27, fat: 0) {
                                    applyPreset(name: "Banana", calories: 105, protein: 1, carbs: 27, fat: 0)
                                }
                                
                                PresetButton(title: "Almonds (28g)", calories: 160, protein: 6, carbs: 6, fat: 14) {
                                    applyPreset(name: "Almonds (28g)", calories: 160, protein: 6, carbs: 6, fat: 14)
                                }
                                
                                PresetButton(title: "Greek Yogurt", calories: 130, protein: 15, carbs: 9, fat: 4) {
                                    applyPreset(name: "Greek Yogurt", calories: 130, protein: 15, carbs: 9, fat: 4)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Spacer(minLength: 20)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button {
                            saveMeal()
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Add to Log")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(isValid ? .white : .secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(isValid ? .blue : .gray.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .disabled(!isValid)
                        
                        Button("Cancel") {
                            dismiss()
                        }
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .alert("Validation Error", isPresented: $showingValidationError) {
            Button("OK") { }
        } message: {
            Text(validationMessage)
        }
    }
    
    private func applyPreset(name: String, calories: Int, protein: Double, carbs: Double, fat: Double) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        mealName = name
        self.calories = "\(calories)"
        self.protein = "\(Int(protein))"
        self.carbs = "\(Int(carbs))"
        self.fat = "\(Int(fat))"
    }
    
    private func saveMeal() {
        guard let caloriesInt = Int(calories), caloriesInt > 0 else {
            validationMessage = "Please enter valid calories"
            showingValidationError = true
            return
        }
        
        let proteinDouble = Double(protein) ?? 0
        let carbsDouble = Double(carbs) ?? 0
        let fatDouble = Double(fat) ?? 0
        
        let entry = QuickNutritionEntry(
            name: mealName.isEmpty ? nil : mealName,
            calories: caloriesInt,
            protein: proteinDouble,
            carbs: carbsDouble,
            fat: fatDouble
        )
        
        nutritionService.add(entry: entry)
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        dismiss()
        onMealAdded()
    }
}

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Preset Button
struct PresetButton: View {
    let title: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Text("\(calories) kcal")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.blue.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Meal Choice Action Sheet
struct MealChoiceSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onScanCalories: () -> Void
    let onQuickAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Handle
            RoundedRectangle(cornerRadius: 2)
                .fill(.secondary)
                .frame(width: 36, height: 4)
                .padding(.top, 8)
            
            // Title
            Text("Log Meal")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .padding(.top, 8)
            
            // Options
            VStack(spacing: 16) {
                Button {
                    dismiss()
                    onScanCalories()
                } label: {
                    HStack {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Scan Calories")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Use camera to scan barcode or label")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                
                Button {
                    dismiss()
                    onQuickAdd()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Quick Add")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Manually enter calories and macros")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            
            Spacer(minLength: 20)
        }
        .padding(20)
        .presentationDetents([.height(280)])
    }
}

// MARK: - Preview
#Preview {
    QuickMealSheet(
        nutritionService: NutritionLogService(),
        onMealAdded: {}
    )
}

