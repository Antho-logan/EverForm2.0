//
//  MobilityPlanView.swift
//  EverForm
//
//  Created by Assistant on 27/11/2025.
//

import SwiftUI

struct MobilityPlanView: View {
    @ObservedObject var store: MobilityStore
    @StateObject private var aiViewModel = MobilityAiViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        EFScreenContainer {
            VStack(spacing: 0) {
                navigationHeader
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Greeting Header (Moved from Landing)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Hi, \(store.userName)")
                                .font(DesignSystem.Typography.displaySmall())
                                .foregroundStyle(DesignSystem.Colors.textPrimary)
                            
                            HStack {
                                Label(store.primaryGoal.rawValue, systemImage: "target")
                                Text("•")
                                Label(store.primarySport.rawValue, systemImage: "figure.run")
                            }
                            .font(DesignSystem.Typography.caption())
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Hero Routines Pager
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(store.routines) { routine in
                                    NavigationLink(destination: MobilityRoutineDetailView(routine: routine)) {
                                        MobilityRoutineCard(routine: routine)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Dashboard Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Dashboard")
                                .font(DesignSystem.Typography.titleMedium())
                                .foregroundStyle(DesignSystem.Colors.textPrimary)
                                .padding(.horizontal, 20)
                            
                            MobilityDashboardView(store: store)
                                .padding(.horizontal, 20)
                            
                            // AI Coach Card
                            if case .loaded(let summary) = aiViewModel.assessmentState {
                                NavigationLink(destination: MobilityAssessmentSummaryView(summary: summary)) {
                                    AICoachCard(summary: summary)
                                }
                                .padding(.horizontal, 20)
                            } else if case .empty = aiViewModel.assessmentState {
                                EmptyStateAICard()
                                    .padding(.horizontal, 20)
                            }
                            
                            // AI Weekly Focus Card
                            if case .loaded(let focus) = aiViewModel.weeklyFocusState {
                                AIWeeklyFocusCard(focus: focus)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await aiViewModel.loadLatestAssessment()
            await aiViewModel.loadWeeklyFocus()
        }
    }
    
    private var navigationHeader: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    Text("Back")
                    .font(.app(.body))
                }
                .foregroundStyle(DesignSystem.Colors.accent)
            }
            
            Spacer()
            
            Text("Mobility Plan")
                .font(.app(.heading))
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                
            Spacer()
            
            Button { } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
            }
            .hidden()
        }
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
        .padding(.vertical, 12)
        .background(DesignSystem.Colors.background)
    }
}

// MARK: - Subviews

struct AICoachCard: View {
    let summary: MobilityAssessmentSummaryDTO
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Ring
            ZStack {
                Circle()
                    .stroke(DesignSystem.Colors.neutral200, lineWidth: 4)
                    .frame(width: 56, height: 56)
                
                Circle()
                    .trim(from: 0, to: CGFloat(summary.profile.overallScore) / 100.0)
                    .stroke(
                        scoreColor(summary.profile.overallScore),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 56, height: 56)
                
                Text("\(summary.profile.overallScore)")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("AI Mobility Coach")
                    .font(DesignSystem.Typography.titleSmall())
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                
                Text(subtitleText)
                    .font(DesignSystem.Typography.caption())
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                
                // Tags
                if !summary.focusTags.isEmpty {
                    HStack {
                        ForEach(summary.focusTags.prefix(2), id: \.self) { tag in
                            Text(tag)
                                .font(DesignSystem.Typography.labelSmall())
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(DesignSystem.Colors.accent.opacity(0.1))
                                .foregroundStyle(DesignSystem.Colors.accent)
                                .clipShape(Capsule())
                        }
                        if summary.focusTags.count > 2 {
                            Text("+\(summary.focusTags.count - 2)")
                                .font(DesignSystem.Typography.caption())
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                        }
                    }
                }
                
                Text(summary.weeklyPlanText)
                    .font(DesignSystem.Typography.bodyMedium())
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("View assessment details →")
                    .font(DesignSystem.Typography.buttonMedium())
                    .foregroundStyle(DesignSystem.Colors.accent)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var subtitleText: String {
        "Baseline established – focus on \(summary.profile.focusAreas.first ?? "maintenance")"
    }
    
    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 80...100: return DesignSystem.Colors.success
        case 50..<80: return DesignSystem.Colors.warning
        default: return DesignSystem.Colors.error
        }
    }
}

struct EmptyStateAICard: View {
    var body: some View {
        NavigationLink(destination: MobilityTestsOverviewView(store: MobilityStore.shared)) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.neutral100.opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 24))
                        .foregroundStyle(DesignSystem.Colors.accent)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Mobility Coach")
                        .font(DesignSystem.Typography.titleSmall())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    Text("Complete your mobility test to unlock personalized guidance.")
                        .font(DesignSystem.Typography.caption())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                    
                    Text("Test your mobility →")
                        .font(DesignSystem.Typography.buttonMedium())
                        .foregroundStyle(DesignSystem.Colors.accent)
                        .padding(.top, 4)
                }
                Spacer()
            }
            .padding(16)
            .background(DesignSystem.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct AIWeeklyFocusCard: View {
    let focus: MobilityWeeklyFocusDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AI Weekly Focus")
                    .font(DesignSystem.Typography.titleSmall())
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                Spacer()
                
                if let avg = focus.averageScore {
                    HStack(spacing: 4) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("\(avg)")
                    }
                    .font(DesignSystem.Typography.caption())
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
            }
            
            Text(focus.focusTitle)
                .font(DesignSystem.Typography.bodyMedium())
                .fontWeight(.medium)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
            
            if !focus.focusTags.isEmpty {
                HStack {
                    ForEach(focus.focusTags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(DesignSystem.Typography.labelSmall())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(DesignSystem.Colors.neutral100.opacity(0.1))
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                            .clipShape(Capsule())
                    }
                }
            }
            
            if let warning = focus.warnings.first {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(DesignSystem.Colors.warning)
                        .font(.system(size: 14))
                        .padding(.top, 2)
                    
                    Text(warning)
                        .font(DesignSystem.Typography.caption())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
                .padding(8)
                .background(DesignSystem.Colors.warning.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("COACH'S INSIGHT")
                    .font(DesignSystem.Typography.labelSmall())
                    .foregroundStyle(DesignSystem.Colors.textTertiary)
                    .tracking(1)
                
                Text(focus.coachInsight)
                    .font(DesignSystem.Typography.bodyMedium())
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .lineSpacing(4)
            }
            .padding(.top, 8)
        }
        .padding(16)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

