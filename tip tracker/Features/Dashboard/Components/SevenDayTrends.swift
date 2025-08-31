//
//  SevenDayTrends.swift
//  EverForm
//
//  7-day mini charts with Apple Charts integration
//  Assumptions: HRV, RHR, Steps, Weight trends with accessibility
//

import SwiftUI
import Charts

struct SevenDayTrends: View {
    let viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("7-Day Trends")
                .font(DesignSystem.Typography.sectionHeader())
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.md)
            ], spacing: DesignSystem.Spacing.md) {
                
                MetricMiniChart(
                    title: "HRV",
                    unit: "ms",
                    currentValue: viewModel.hrv,
                    data: Array(zip(viewModel.metrics7d.dates, viewModel.metrics7d.hrv)),
                    color: DesignSystem.Colors.success
                ) {
                    viewModel.logTap("chart_tap_hrv")
                }
                
                MetricMiniChart(
                    title: "RHR",
                    unit: "bpm",
                    currentValue: viewModel.rhr,
                    data: Array(zip(viewModel.metrics7d.dates, viewModel.metrics7d.rhr)),
                    color: DesignSystem.Colors.error
                ) {
                    viewModel.logTap("chart_tap_rhr")
                }
                
                MetricMiniChart(
                    title: "Steps",
                    unit: "",
                    currentValue: viewModel.todaySteps,
                    data: Array(zip(viewModel.metrics7d.dates, viewModel.metrics7d.steps.map(Double.init))),
                    color: DesignSystem.Colors.accent
                ) {
                    viewModel.logTap("chart_tap_steps")
                }
                
                if let weightData = viewModel.metrics7d.weight {
                    MetricMiniChart(
                        title: "Weight",
                        unit: "kg",
                        currentValue: Int(weightData.last ?? 0),
                        data: Array(zip(viewModel.metrics7d.dates, weightData)),
                        color: DesignSystem.Colors.warning
                    ) {
                        viewModel.logTap("chart_tap_weight")
                    }
                }
            }
        }
    }
}

// MARK: - Metric Mini Chart Component
struct MetricMiniChart: View {
    let title: String
    let unit: String
    let currentValue: Int
    let data: [(Date, Double)]
    let color: Color
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    private var accessibilityDescription: String {
        let values = data.map { $0.1 }
        let min = values.min() ?? 0
        let max = values.max() ?? 0
        let avg = values.reduce(0, +) / Double(values.count)
        
        return "\(title) trend over 7 days. Current: \(currentValue) \(unit). Range: \(Int(min)) to \(Int(max)). Average: \(Int(avg))."
    }
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            onTap()
        }) {
            CardDefault {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    // Header
                    HStack {
                        Text(title)
                            .font(DesignSystem.Typography.labelMedium())
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        
                        Spacer()
                        
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text("\(currentValue)")
                                .font(DesignSystem.Typography.monospacedNumber(size: 16, relativeTo: .callout))
                                .fontWeight(.semibold)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            if !unit.isEmpty {
                                Text(unit)
                                    .font(DesignSystem.Typography.caption())
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                        }
                    }
                    
                    // Chart
                    Chart {
                        ForEach(Array(data.enumerated()), id: \.offset) { index, point in
                            LineMark(
                                x: .value("Day", index),
                                y: .value("Value", point.1)
                            )
                            .foregroundStyle(color)
                            .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))
                            
                            AreaMark(
                                x: .value("Day", index),
                                y: .value("Value", point.1)
                            )
                            .foregroundStyle(color.opacity(0.1))
                        }
                    }
                    .frame(height: 40)
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .chartLegend(.hidden)
                }
                .frame(height: 80)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(DesignSystem.Animation.springFast, value: isPressed)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("Tap to view detailed chart")
    }
}

