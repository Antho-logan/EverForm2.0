//
//  TodaysProgressGrid.swift
//  EverForm
//
//  2x2 grid of today's progress metrics
//  Assumptions: Steps, Calories, Sleep, Hydration with navigation
//

import SwiftUI

struct TodaysProgressGrid: View {
    let viewModel: DashboardViewModel
    let targets: UserTargets?
    @Environment(NutritionStore.self) private var nutritionStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Today's Progress")
                .font(DesignSystem.Typography.sectionHeader())
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.md)
            ], spacing: DesignSystem.Spacing.md) {
                
                MetricTile(
                    title: "Steps",
                    value: formatNumber(viewModel.todaySteps),
                    unit: "",
                    icon: "figure.walk",
                    color: DesignSystem.Colors.accent,
                    isLoading: viewModel.isLoadingProgress
                ) {
                    viewModel.logTap("progress_steps_tap")
                }
                
                MetricTile(
                    title: "Calories",
                    value: targets != nil ? 
                        "\(nutritionStore.todayCalories) / \(targets!.targetCalories)" :
                        "\(nutritionStore.todayCalories)",
                    unit: targets != nil ? "" : "kcal",
                    icon: "flame.fill",
                    color: DesignSystem.Colors.warning,
                    isLoading: viewModel.isLoadingProgress
                ) {
                    viewModel.logTap("progress_calories_tap")
                }
                
                MetricTile(
                    title: "Sleep",
                    value: targets != nil ? 
                        String(format: "%.1f / %.1f", viewModel.todaySleepHours, targets!.sleepHours) :
                        String(format: "%.1f", viewModel.todaySleepHours),
                    unit: "hrs",
                    icon: "moon.fill",
                    color: DesignSystem.Colors.info,
                    isLoading: viewModel.isLoadingProgress
                ) {
                    viewModel.logTap("progress_sleep_tap")
                }
                
                MetricTile(
                    title: "Hydration",
                    value: targets != nil ? 
                        "\(viewModel.todayHydrationMl) / \(targets!.hydrationMl)" :
                        "\(viewModel.todayHydrationMl / 250)",
                    unit: targets != nil ? "ml" : "glasses",
                    icon: "drop.fill",
                    color: DesignSystem.Colors.success,
                    isLoading: viewModel.isLoadingProgress
                ) {
                    viewModel.logTap("progress_hydration_tap")
                }
            }
        }
    }
    
    private func formatNumber(_ number: Int) -> String {
        if number >= 1000 {
            return String(format: "%.1fk", Double(number) / 1000.0)
        }
        return "\(number)"
    }
}

