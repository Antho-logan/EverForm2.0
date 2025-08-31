import SwiftUI

struct TodaysPlanSection: View {
    let onOpenTraining: () -> Void
    let onOpenNutrition: () -> Void
    let onOpenSleep: () -> Void
    let onOpenMobility: () -> Void

    let onExplainTraining: () -> Void
    let onExplainNutrition: () -> Void
    let onExplainSleep: () -> Void
    let onExplainMobility: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Today's Plan")
                .font(DesignSystem.Typography.titleMedium())
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.textPrimary)

            VStack(spacing: DesignSystem.Spacing.sm) {
                PlanCard(
                    title: "Training",
                    subtitle: "Upper Power",
                    actionTitle: "Start Workout",
                    icon: "dumbbell.fill",
                    accentColor: DesignSystem.Colors.accent,
                    explain: onExplainTraining,
                    action: onOpenTraining
                )

                PlanCard(
                    title: "Nutrition",
                    subtitle: "2400 kcal target",
                    actionTitle: "Log Meal",
                    icon: "fork.knife",
                    accentColor: DesignSystem.Colors.success,
                    explain: onExplainNutrition,
                    action: onOpenNutrition
                )

                PlanCard(
                    title: "Sleep & Recovery",
                    subtitle: "Bedtime 22:30",
                    actionTitle: "Open",
                    icon: "moon.fill",
                    accentColor: DesignSystem.Colors.info,
                    explain: onExplainSleep,
                    action: onOpenSleep
                )

                PlanCard(
                    title: "Mobility",
                    subtitle: "Hips & Shoulders • 8 minutes",
                    actionTitle: "Start Mobility",
                    icon: "figure.flexibility",
                    accentColor: DesignSystem.Colors.warning,
                    explain: onExplainMobility,
                    action: onOpenMobility
                )
            }
        }
    }
}

private struct PlanCard: View {
    let title: String
    let subtitle: String
    let actionTitle: String
    let icon: String
    let accentColor: Color
    let explain: () -> Void
    let action: () -> Void
    
    @State private var isPressed = false

    var body: some View {
        CardDefault(onTap: action) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: DesignSystem.IconSize.medium, weight: .semibold))
                        .foregroundColor(accentColor)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(DesignSystem.Typography.titleSmall())
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Spacer()
                        
                        Button(action: explain) {
                            Text("Explain")
                                .font(DesignSystem.Typography.caption())
                                .foregroundColor(accentColor)
                                .padding(.horizontal, DesignSystem.Spacing.sm)
                                .padding(.vertical, DesignSystem.Spacing.xs)
                                .background(
                                    RoundedRectangle(cornerRadius: DesignSystem.Radius.sm)
                                        .fill(accentColor.opacity(0.1))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Text(subtitle)
                        .font(DesignSystem.Typography.bodyMedium())
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Action Button
                    HStack {
                        Spacer()
                        
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Text(actionTitle)
                                .font(DesignSystem.Typography.bodyMedium())
                                .fontWeight(.medium)
                                .foregroundColor(accentColor)
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(accentColor)
                        }
                    }
                }
            }
            .frame(minHeight: 80)
        }
    }
}