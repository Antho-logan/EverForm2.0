//
//  MobilityLevelSheet.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

import SwiftUI

struct MobilityLevelSheet: View {
    let scoreSummary: MobilityScoreSummary
    let sport: MobilitySport
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 8) {
                Text("Your Mobility Profile")
                    .font(DesignSystem.Typography.displaySmall())
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                
                Text("Based on your assessments for \(sport.rawValue)")
                    .font(DesignSystem.Typography.bodyMedium())
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
            .padding(.top, 40)
            
            // Main Score
            ZStack {
                Circle()
                    .fill(scoreSummary.level.color.opacity(0.2))
                    .frame(width: 160, height: 160)
                
                VStack(spacing: 4) {
                    Text("\(scoreSummary.overallScore)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(scoreSummary.level.color)
                    
                    Text(scoreSummary.level.rawValue)
                        .font(DesignSystem.Typography.titleMedium())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                }
            }
            
            // Explanation
            VStack(alignment: .leading, spacing: 16) {
                Text("Why it matters")
                    .font(DesignSystem.Typography.titleSmall())
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                
                Text("Good mobility is crucial for \(sport.rawValue) to ensure you can move through full ranges of motion safely and efficiently. Your current level indicates \(scoreSummary.level.rawValue.lowercased()) capacity.")
                    .font(DesignSystem.Typography.bodyMedium())
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .lineSpacing(4)
            }
            .padding(24)
            .background(DesignSystem.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text("Close")
                    .font(DesignSystem.Typography.buttonLarge())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(DesignSystem.Colors.backgroundSecondary)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(DesignSystem.Colors.border, lineWidth: 1)
                    )
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(DesignSystem.Colors.background.ignoresSafeArea())
    }
}

