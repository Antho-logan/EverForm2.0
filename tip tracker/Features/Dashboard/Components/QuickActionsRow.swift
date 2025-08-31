import SwiftUI

struct QuickActionsRow: View {
    let onBreathwork: () -> Void
    let onMobility: () -> Void
    let onFixPain: () -> Void
    let onLogWater: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Quick Actions")
                .font(DesignSystem.Typography.titleMedium())
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    QuickActionChip(icon: "wind", title: "Breathwork", action: onBreathwork)
                    QuickActionChip(icon: "figure.walk", title: "Mobility", action: onMobility)
                    QuickActionChip(icon: "cross.case", title: "Fix Pain", action: onFixPain)
                    QuickActionChip(icon: "drop.fill", title: "Log Water", action: onLogWater)
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
        }
    }
}

