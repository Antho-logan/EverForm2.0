//
//  FixPainView.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import SwiftUI

struct FixPainView: View {
    @State private var viewModel = FixPainViewModel()
    @State private var showAssessment = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    
                    // Hero Card
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Fix Pain")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(.white)
                            
                            Text("Identify your issue and get a personalized recovery plan in minutes.")
                                .font(.system(size: 17))
                                .foregroundStyle(.white.opacity(0.9))
                                .lineLimit(2)
                        }
                        
                        Button {
                            viewModel.startNewAssessment()
                            showAssessment = true
                        } label: {
                            HStack {
                                Text("Start Assessment")
                                    .font(.system(size: 17, weight: .semibold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundStyle(FixPainTheme.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(24)
                    .background(FixPainTheme.primaryGradient())
                    .clipShape(RoundedRectangle(cornerRadius: FixPainTheme.radiusLarge))
                    .shadow(color: FixPainTheme.primary.opacity(0.3), radius: FixPainTheme.shadowRadius, x: 0, y: FixPainTheme.shadowY)
                    
                    // Recent Section
                    if !viewModel.recentAssessments.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Recent Checks")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(FixPainTheme.textPrimary)
                            
                            ForEach(viewModel.recentAssessments) { assessment in
                                RecentAssessmentRow(assessment: assessment)
                            }
                        }
                    } else {
                        // Placeholder or Education
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Common Issues")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(FixPainTheme.textPrimary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    CommonIssueCard(title: "Knee Pain", icon: "figure.walk")
                                    CommonIssueCard(title: "Lower Back", icon: "figure.core.training")
                                    CommonIssueCard(title: "Shoulder", icon: "figure.cooldown")
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(FixPainTheme.background)
            .fullScreenCover(isPresented: $showAssessment) {
                FixPainAssessmentFlowView(viewModel: viewModel, isPresented: $showAssessment)
            }
        }
    }
}

struct RecentAssessmentRow: View {
    let assessment: FixPainAssessment
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(FixPainTheme.cardBackgroundSecondary)
                    .frame(width: 48, height: 48)
                
                Image(systemName: "cross.case.fill")
                    .foregroundStyle(FixPainTheme.primary)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(assessment.region?.rawValue ?? "Unknown Region")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(FixPainTheme.textPrimary)
                
                Text(assessment.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(FixPainTheme.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(FixPainTheme.textSecondary)
        }
        .padding()
        .background(FixPainTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: FixPainTheme.radiusMedium))
        .shadow(color: FixPainTheme.shadowColor.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct CommonIssueCard: View {
    let title: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(FixPainTheme.primary)
                .frame(width: 40, height: 40)
                .background(FixPainTheme.cardBackgroundSecondary)
                .clipShape(Circle())
            
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(FixPainTheme.textPrimary)
        }
        .padding(16)
        .frame(width: 120, height: 120)
        .background(FixPainTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: FixPainTheme.radiusMedium))
        .shadow(color: FixPainTheme.shadowColor.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
