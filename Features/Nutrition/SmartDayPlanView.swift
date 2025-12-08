//
//  SmartDayPlanView.swift
//  EverForm
//
//  Displays AI-generated meal suggestions for the day.
//

import SwiftUI

struct SmartDayPlanView: View {
    @Environment(\.dismiss) private var dismiss
    let plan: SmartDayPlan?
    let isLoading: Bool
    let error: String?
    let onRefresh: () -> Void
    
    var body: some View {
        EFScreenContainer {
            VStack(spacing: 0) {
                // Custom Sheet Header
                HStack {
                    Text("Smart Suggestions")
                        .font(.app(.heading))
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    Spacer()
                    if !isLoading {
                        Button {
                            onRefresh()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                                .padding(8)
                                .background(DesignSystem.Colors.cardBackground)
                                .clipShape(Circle())
                        }
                    }
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                            .padding(8)
                            .background(DesignSystem.Colors.cardBackground)
                            .clipShape(Circle())
                    }
                }
                .padding()
                .background(DesignSystem.Colors.background)
                
                if isLoading {
                    VStack(spacing: 16) {
                        Spacer()
                        ProgressView()
                            .tint(DesignSystem.Colors.accent)
                            .scaleEffect(1.2)
                        Text("Analyzing your intake...")
                            .font(.app(.bodySecondary))
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                        Spacer()
                    }
                } else if let error = error {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundStyle(DesignSystem.Colors.error)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .font(.app(.body))
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                        Button("Try Again") {
                            onRefresh()
                        }
                        .font(.app(.button))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(DesignSystem.Colors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12).stroke(DesignSystem.Colors.border, lineWidth: 1)
                        )
                        Spacer()
                    }
                } else if let plan = plan {
                    ScrollView {
                        VStack(spacing: 24) {
                            headerSection(plan: plan)
                            
                            VStack(spacing: 16) {
                                ForEach(plan.meals) { meal in
                                    SuggestedMealCard(meal: meal)
                                }
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                        .padding(.bottom, 32)
                    }
                } else {
                     VStack {
                         Spacer()
                         Text("No suggestions available")
                             .font(.app(.bodySecondary))
                             .foregroundStyle(DesignSystem.Colors.textSecondary)
                         Spacer()
                     }
                }
            }
        }
    }
    
    private func headerSection(plan: SmartDayPlan) -> some View {
        VStack(spacing: 12) {
            Text("Based on your goals and today's logs, here are some ways to hit your targets.")
                .font(.app(.bodySecondary))
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            HStack(spacing: 12) {
                MacroBadge(label: "Remaining", value: "\(plan.remaining.kcal) kcal", color: .secondary)
                MacroBadge(label: "Protein Gap", value: "\(Int(plan.remaining.proteinG))g", color: .blue)
            }
        }
        .padding(.top, 8)
    }
}

struct SuggestedMealCard: View {
    let meal: SuggestedMeal
    
    var body: some View {
        EFCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(meal.slot.capitalized)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(DesignSystem.Colors.accent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(DesignSystem.Colors.accent.opacity(0.1))
                                .clipShape(Capsule())
                            
                            Spacer()
                            
                            Label("AI Generated", systemImage: "sparkles")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.purple)
                        }
                        
                        Text(meal.name)
                            .font(.app(.heading))
                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                if let notes = meal.notes {
                    Text(notes)
                        .font(.app(.bodySecondary))
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Divider()
                    .overlay(DesignSystem.Colors.border)
                
                HStack(spacing: 16) {
                    MacroValue(label: "Calories", value: "\(meal.macros.kcal)")
                    MacroValue(label: "Protein", value: "\(Int(meal.macros.proteinG))g")
                    MacroValue(label: "Carbs", value: "\(Int(meal.macros.carbsG))g")
                    MacroValue(label: "Fat", value: "\(Int(meal.macros.fatG))g")
                }
                
                if let ingredients = meal.ingredients, !ingredients.isEmpty {
                    Divider()
                        .overlay(DesignSystem.Colors.border)
                    Text("Ingredients: " + ingredients.joined(separator: ", "))
                        .font(.caption)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
            }
        }
    }
}

struct MacroBadge: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label.uppercased())
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(DesignSystem.Colors.textPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12).stroke(DesignSystem.Colors.border, lineWidth: 1)
        )
    }
}

struct MacroValue: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
        }
    }
}
