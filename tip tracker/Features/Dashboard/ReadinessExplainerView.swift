//
//  ReadinessExplainerView.swift
//  EverForm
//
//  Readiness score explanation sheet
//  Assumptions: Educational content about readiness calculation
//

import SwiftUI

struct ReadinessExplainerView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(DesignSystem.Colors.success.opacity(0.1))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "heart.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(DesignSystem.Colors.success)
                            }
                            
                            Spacer()
                        }
                        
                        Text("Readiness Score")
                            .font(DesignSystem.Typography.displayMedium())
                            .fontWeight(.bold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Your readiness score indicates how prepared your body is for training based on recovery metrics.")
                            .font(DesignSystem.Typography.bodyLarge())
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    // Metrics Explanation
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Key Metrics")
                            .font(DesignSystem.Typography.sectionHeader())
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        MetricExplanationRow(
                            icon: "heart.fill",
                            title: "Heart Rate Variability (HRV)",
                            description: "Measures the variation in time between heartbeats. Higher HRV typically indicates better recovery.",
                            color: DesignSystem.Colors.success
                        )
                        
                        MetricExplanationRow(
                            icon: "waveform.path.ecg",
                            title: "Resting Heart Rate (RHR)",
                            description: "Your heart rate when at complete rest. Lower RHR often indicates better cardiovascular fitness.",
                            color: DesignSystem.Colors.error
                        )
                        
                        MetricExplanationRow(
                            icon: "moon.fill",
                            title: "Sleep Quality",
                            description: "Duration and quality of sleep affects recovery and readiness for training.",
                            color: DesignSystem.Colors.info
                        )
                    }
                    
                    // Score Ranges
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Score Ranges")
                            .font(DesignSystem.Typography.sectionHeader())
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            ScoreRangeRow(range: "80-100", description: "Excellent - Ready for intense training", color: .green)
                            ScoreRangeRow(range: "60-79", description: "Good - Moderate training recommended", color: .yellow)
                            ScoreRangeRow(range: "40-59", description: "Fair - Light training or active recovery", color: .orange)
                            ScoreRangeRow(range: "0-39", description: "Poor - Focus on recovery and rest", color: .red)
                        }
                    }
                    
                    // Tips
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Improving Your Score")
                            .font(DesignSystem.Typography.sectionHeader())
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            TipRow(text: "Maintain consistent sleep schedule")
                            TipRow(text: "Stay hydrated throughout the day")
                            TipRow(text: "Manage stress through meditation or breathwork")
                            TipRow(text: "Allow adequate recovery between intense sessions")
                        }
                    }
                }
                .padding(DesignSystem.Spacing.screenPadding)
            }
            .navigationTitle("Readiness")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            TelemetryService.shared.track("readiness_explainer_viewed")
        }
    }
}

// MARK: - Supporting Components
struct MetricExplanationRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: DesignSystem.IconSize.small, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(DesignSystem.Typography.titleSmall())
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text(description)
                    .font(DesignSystem.Typography.bodyMedium())
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
    }
}

struct ScoreRangeRow: View {
    let range: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(range)
                .font(DesignSystem.Typography.monospacedNumber(size: 14, relativeTo: .callout))
                .fontWeight(.semibold)
                .foregroundColor(color)
                .frame(width: 60, alignment: .leading)
            
            Text(description)
                .font(DesignSystem.Typography.bodyMedium())
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

struct TipRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            Text("•")
                .font(DesignSystem.Typography.bodyMedium())
                .foregroundColor(DesignSystem.Colors.accent)
            
            Text(text)
                .font(DesignSystem.Typography.bodyMedium())
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
    }
}

#Preview {
    ReadinessExplainerView()
}

