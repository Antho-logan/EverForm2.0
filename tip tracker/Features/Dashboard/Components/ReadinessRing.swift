//
//  ReadinessRing.swift
//  EverForm
//
//  Animated readiness ring with color mapping and monospaced digits
//  Assumptions: 0-100 scale, color transitions from neutral to green
//

import SwiftUI

struct ReadinessRing: View {
    let score: Int
    let rhr: Int
    let hrv: Int
    let onTap: () -> Void
    
    @State private var animatedScore: Double = 0
    @State private var isPressed = false
    
    private var ringColor: Color {
        switch score {
        case 0..<40: return .red
        case 40..<60: return .orange
        case 60..<80: return .yellow
        case 80...100: return .green
        default: return .gray
        }
    }
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            onTap()
        }) {
            VStack(spacing: DesignSystem.Spacing.md) {
                // Animated Ring
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(DesignSystem.Colors.neutral200, lineWidth: 8)
                        .frame(width: 120, height: 120)
                    
                    // Progress ring
                    Circle()
                        .trim(from: 0, to: animatedScore / 100)
                        .stroke(
                            ringColor,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 1.0, dampingFraction: 0.8), value: animatedScore)
                    
                    // Score text
                    VStack(spacing: 2) {
                        Text("\(score)")
                            .font(DesignSystem.Typography.monospacedNumber(size: 32, relativeTo: .largeTitle))
                            .fontWeight(.bold)
                            .foregroundColor(ringColor)
                            .contentTransition(.numericText())
                        
                        Text("Readiness")
                            .font(DesignSystem.Typography.caption())
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
                
                // Mini stats
                HStack(spacing: DesignSystem.Spacing.lg) {
                    VStack(spacing: 2) {
                        Text("\(rhr)")
                            .font(DesignSystem.Typography.monospacedNumber(size: 16, relativeTo: .callout))
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("RHR")
                            .font(DesignSystem.Typography.caption())
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    VStack(spacing: 2) {
                        Text("\(hrv)")
                            .font(DesignSystem.Typography.monospacedNumber(size: 16, relativeTo: .callout))
                            .fontWeight(.semibold)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        Text("HRV")
                            .font(DesignSystem.Typography.caption())
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(DesignSystem.Animation.springFast, value: isPressed)
        .onAppear {
            animatedScore = Double(score)
        }
        .accessibilityLabel("Readiness score \(score) out of 100")
        .accessibilityHint("Tap to learn more about your readiness")
    }
}
