//
//  MetricTile.swift
//  EverForm
//
//  Progress metric tiles for 2x2 grid display
//  Assumptions: Shows current value with unit, loading states, tap navigation
//

import SwiftUI

struct MetricTile: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    let isLoading: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var isVisible = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            onTap()
        }) {
            CardDefault {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    // Header with icon
                    HStack {
                        Image(systemName: icon)
                            .font(.system(size: DesignSystem.IconSize.small, weight: .semibold))
                            .foregroundColor(color)
                        
                        Spacer()
                        
                        Text(title)
                            .font(DesignSystem.Typography.labelMedium())
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Value display
                    if isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            
                            Text("Loading...")
                                .font(DesignSystem.Typography.caption())
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                    } else {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text(value)
                                .font(DesignSystem.Typography.monospacedNumber(size: 24, relativeTo: .title2))
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                                .contentTransition(.numericText())
                            
                            Text(unit)
                                .font(DesignSystem.Typography.caption())
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                }
                .frame(height: 80)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: isVisible ? 0 : 20)
        .animation(DesignSystem.Animation.spring, value: isPressed)
        .animation(DesignSystem.Animation.springSlow, value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
        .accessibilityLabel("\(title): \(value) \(unit)")
        .accessibilityHint("Tap to view details")
    }
}

