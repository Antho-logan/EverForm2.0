//
//  CoachCard.swift
//  EverForm
//
//  Coach interaction card with AI guidance prompt
//  Assumptions: Navigation to CoachView, emphasis on natural guidance
//

import SwiftUI

struct CoachCard: View {
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            onTap()
        }) {
            CardDefault {
                HStack(spacing: DesignSystem.Spacing.md) {
                    // Coach Icon
                    ZStack {
                        Circle()
                            .fill(DesignSystem.Colors.accent.opacity(0.1))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: DesignSystem.IconSize.medium, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.accent)
                    }
                    
                    // Content
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ask the Coach")
                            .font(DesignSystem.Typography.titleSmall())
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("Natural guidance with citations")
                            .font(DesignSystem.Typography.bodyMedium())
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    // Arrow
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: DesignSystem.IconSize.medium))
                        .foregroundColor(DesignSystem.Colors.accent)
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(DesignSystem.Animation.springFast, value: isPressed)
        .accessibilityLabel("Ask the Coach")
        .accessibilityHint("Get personalized guidance and advice")
    }
}

// MARK: - Insight Chips Row
struct InsightChipsRow: View {
    private let insights = [
        ("Electrolytes today", "drop.circle.fill", DesignSystem.Colors.success),
        ("Zone-2 30m", "heart.circle.fill", DesignSystem.Colors.error),
        ("Wind-down 22:30", "moon.circle.fill", DesignSystem.Colors.info),
        ("Protein focus", "leaf.circle.fill", DesignSystem.Colors.warning)
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(Array(insights.enumerated()), id: \.offset) { index, insight in
                    InsightChip(
                        text: insight.0,
                        icon: insight.1,
                        color: insight.2
                    ) {
                        TelemetryService.shared.track("insight_chip_tap_\(index)")
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.screenPadding)
        }
        .padding(.horizontal, -DesignSystem.Spacing.screenPadding)
    }
}

// MARK: - Insight Chip Component
struct InsightChip: View {
    let text: String
    let icon: String
    let color: Color
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            onTap()
        }) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)
                
                Text(text)
                    .font(DesignSystem.Typography.caption())
                    .foregroundColor(DesignSystem.Colors.textPrimary)
            }
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.full)
                    .fill(DesignSystem.Colors.cardBackgroundElevated)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.Radius.full)
                            .stroke(DesignSystem.Border.outlineColor, lineWidth: DesignSystem.Border.outline)
                    )
            )
            .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(DesignSystem.Animation.springFast, value: isPressed)
        .accessibilityLabel("Insight: \(text)")
        .accessibilityHint("Tap to learn more")
    }
}
