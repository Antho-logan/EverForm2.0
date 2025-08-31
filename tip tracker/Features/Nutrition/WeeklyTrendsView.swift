//
//  WeeklyTrendsView.swift
//  EverForm
//
//  Weekly nutrition trends with simple charts
//  Applied: T-UI, S-OBS2, P-ARCH, C-SIMPLE, R-LOGS
//

import SwiftUI
import Charts

struct WeeklyTrendsView: View {
    let onClose: () -> Void
    @Environment(NutritionStore.self) private var nutritionStore
    
    private var weekSummary: WeekNutritionSummary {
        nutritionStore.weekSummary
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Header
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Text("Weekly Trends")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(weekSummary.formattedWeekRange)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, DesignSystem.Spacing.md)
                    
                    // Summary Stats
                    WeeklySummaryStats(weekSummary: weekSummary)
                    
                    // Calories Chart
                    CaloriesChartSection(weekSummary: weekSummary)
                    
                    // Macros Chart
                    MacrosChartSection(weekSummary: weekSummary)
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        onClose()
                    }
                }
            }
        }
        .presentationDetents([.large])
        .onAppear {
            TelemetryService.shared.track("nutrition_trends_viewed")
        }
    }
}

// MARK: - Weekly Summary Stats

struct WeeklySummaryStats: View {
    let weekSummary: WeekNutritionSummary
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Text("This Week")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: DesignSystem.Spacing.md) {
                NutritionStatCard(
                    title: "Active Days",
                    value: "\(weekSummary.activeDays)",
                    subtitle: "of 7 days",
                    color: DesignSystem.Colors.accent
                )
                
                NutritionStatCard(
                    title: "Avg Calories",
                    value: "\(weekSummary.dailyAverages.kcal)",
                    subtitle: "per day",
                    color: DesignSystem.Colors.success
                )
                
                NutritionStatCard(
                    title: "Total Volume",
                    value: NutritionChartsService.formatCalories(weekSummary.weeklyTotals.kcal),
                    subtitle: "kcal",
                    color: DesignSystem.Colors.info
                )
            }
        }
    }
}

// MARK: - Nutrition Stat Card

struct NutritionStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text(subtitle)
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                .stroke(DesignSystem.Border.outlineColor, lineWidth: DesignSystem.Border.outline)
        )
    }
}

// MARK: - Calories Chart Section

struct CaloriesChartSection: View {
    let weekSummary: WeekNutritionSummary
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Daily Calories")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Chart(weekSummary.dailyCaloriesData, id: \.day) { item in
                BarMark(
                    x: .value("Day", item.day),
                    y: .value("Calories", item.calories)
                )
                .foregroundStyle(DesignSystem.Colors.accent.gradient)
                .cornerRadius(4)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let calories = value.as(Int.self) {
                            Text(NutritionChartsService.formatCalories(calories))
                                .font(.system(size: 10, design: .rounded))
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let day = value.as(String.self) {
                            Text(day)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                        }
                    }
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                    .stroke(DesignSystem.Border.outlineColor, lineWidth: DesignSystem.Border.outline)
            )
        }
    }
}

// MARK: - Macros Chart Section

struct MacrosChartSection: View {
    let weekSummary: WeekNutritionSummary
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Daily Macros")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Legend
                HStack(spacing: DesignSystem.Spacing.sm) {
                    LegendItem(color: DesignSystem.Colors.info, label: "P")
                    LegendItem(color: DesignSystem.Colors.warning, label: "C")
                    LegendItem(color: DesignSystem.Colors.error, label: "F")
                }
            }
            
            Chart(weekSummary.dailyMacrosData, id: \.day) { item in
                BarMark(
                    x: .value("Day", item.day),
                    y: .value("Protein", item.protein)
                )
                .foregroundStyle(DesignSystem.Colors.info.gradient)
                .cornerRadius(2)
                
                BarMark(
                    x: .value("Day", item.day),
                    y: .value("Carbs", item.carbs)
                )
                .foregroundStyle(DesignSystem.Colors.warning.gradient)
                .cornerRadius(2)
                
                BarMark(
                    x: .value("Day", item.day),
                    y: .value("Fat", item.fat)
                )
                .foregroundStyle(DesignSystem.Colors.error.gradient)
                .cornerRadius(2)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let grams = value.as(Double.self) {
                            Text("\(Int(grams))g")
                                .font(.system(size: 10, design: .rounded))
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let day = value.as(String.self) {
                            Text(day)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                        }
                    }
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                    .stroke(DesignSystem.Border.outlineColor, lineWidth: DesignSystem.Border.outline)
            )
        }
    }
}

// MARK: - Legend Item

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    WeeklyTrendsView(onClose: { print("Close") })
        .environment(NutritionStore())
}
