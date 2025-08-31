//
// MealLogView.swift
// EverForm
//
// Meal logging interface accessed from nutrition tab context menu
// Assumptions: Simple stub for manual meal entry, can route to scanner
//

import SwiftUI

struct MealLogView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var mealName = ""
    @State private var calories = ""
    @State private var showingScanner = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Header
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(DesignSystem.Colors.accent)
                        
                        Text("Log Meal")
                            .font(DesignSystem.Typography.displaySmall())
                            .fontWeight(.bold)
                        
                        Text("Add nutrition info manually or use the scanner")
                            .font(DesignSystem.Typography.bodyMedium())
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    // Manual Entry Form
                    VStack(spacing: DesignSystem.Spacing.md) {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text("Meal Name")
                                .font(DesignSystem.Typography.labelMedium())
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            TextField("e.g., Chicken Salad", text: $mealName)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            Text("Calories")
                                .font(DesignSystem.Typography.labelMedium())
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            TextField("e.g., 350", text: $calories)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                        }
                    }
                    .padding()
                    .background(DesignSystem.Colors.cardBackgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
                    
                    // Scanner Option
                    Button("Use Scanner Instead") {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        
                        DebugLog.d("Scanner from meal log tapped")
                        TelemetryService.shared.track("scan_open_from_meal_log")
                        
                        showingScanner = true
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(DesignSystem.Colors.accent.opacity(0.1))
                    .foregroundColor(DesignSystem.Colors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
                    .font(DesignSystem.Typography.buttonLarge())
                    
                    Spacer()
                    
                    // Save Button
                    Button("Save Meal") {
                        handleSave()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(mealName.isEmpty ? DesignSystem.Colors.textTertiary : DesignSystem.Colors.accent)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
                    .font(DesignSystem.Typography.buttonLarge())
                    .disabled(mealName.isEmpty)
                }
                .padding(DesignSystem.Spacing.screenPadding)
                .padding(.bottom, 48) // Extra bottom padding
            }
            .navigationTitle("Log Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingScanner) {
            ScanSheetView(initialMode: .calorie)
        }
        .onAppear {
            DebugLog.d("MealLogView appeared")
            TelemetryService.shared.track("meal_log_opened")
        }
    }
    
    private func handleSave() {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        
        DebugLog.d("Meal saved: \(mealName), \(calories) cal")
        TelemetryService.shared.track("meal_saved_manual")
        
        // TODO: Save to nutrition service
        dismiss()
    }
}
