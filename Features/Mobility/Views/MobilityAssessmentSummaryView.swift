//
//  MobilityAssessmentSummaryView.swift
//  EverForm
//
//  Created by Assistant on 07/12/2025.
//

import SwiftUI

struct MobilityAssessmentSummaryView: View {
    let summary: MobilityAssessmentSummaryDTO
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Text("AI Mobility Coach")
                        .font(DesignSystem.Typography.displaySmall())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    // Score Ring
                    ZStack {
                        // Background circle
                        Circle()
                            .stroke(DesignSystem.Colors.neutral200, lineWidth: 8)
                            .frame(width: 120, height: 120)
                        
                        // Progress circle
                        Circle()
                            .trim(from: 0, to: CGFloat(summary.profile.overallScore) / 100.0)
                            .stroke(
                                scoreColor(summary.profile.overallScore),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 120, height: 120)
                        
                        VStack(spacing: 4) {
                            Text("\(summary.profile.overallScore)")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(DesignSystem.Colors.textPrimary)
                            
                            Text("Mobility Score")
                                .font(DesignSystem.Typography.caption())
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    // Focus Tags
                    if !summary.focusTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(summary.focusTags, id: \.self) { tag in
                                    Text(tag)
                                        .font(DesignSystem.Typography.labelSmall())
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(DesignSystem.Colors.accent.opacity(0.1))
                                        .foregroundStyle(DesignSystem.Colors.accent)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.top, 24)
                
                // AI Summary Text
                VStack(alignment: .leading, spacing: 12) {
                    Text("Coach's Assessment")
                        .font(DesignSystem.Typography.titleSmall())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    Text(summary.aiSummaryText)
                        .font(DesignSystem.Typography.bodyMedium())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .lineSpacing(4)
                }
                .padding(16)
                .background(DesignSystem.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                
                // Recommended Routines
                if !summary.recommendedRoutines.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recommended Routines")
                            .font(DesignSystem.Typography.titleSmall())
                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                            .padding(.horizontal)
                        
                        ForEach(summary.recommendedRoutines) { routine in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(routine.name)
                                        .font(DesignSystem.Typography.bodyMedium())
                                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                                    
                                    if let freq = routine.frequencyPerWeek {
                                        Text("Recommended: \(freq)x / week")
                                            .font(DesignSystem.Typography.caption())
                                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                                    }
                                }
                                
                                Spacer()
                                
                                Text(routine.priority.capitalized)
                                    .font(DesignSystem.Typography.labelSmall())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(priorityColor(routine.priority).opacity(0.1))
                                    .foregroundStyle(priorityColor(routine.priority))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                            .padding(16)
                            .background(DesignSystem.Colors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer(minLength: 40)
                
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(DesignSystem.Typography.buttonLarge())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(DesignSystem.Colors.accent)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .background(DesignSystem.Colors.background.ignoresSafeArea())
    }
    
    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 80...100: return DesignSystem.Colors.success
        case 50..<80: return DesignSystem.Colors.warning
        default: return DesignSystem.Colors.error
        }
    }
    
    private func priorityColor(_ priority: String) -> Color {
        switch priority.lowercased() {
        case "high": return DesignSystem.Colors.error
        case "medium": return DesignSystem.Colors.warning
        default: return DesignSystem.Colors.success
        }
    }
}

