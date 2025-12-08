//
//  RecoveryAiCoachSection.swift
//  EverForm
//
//  Created by Assistant on 07/12/2025.
//

import SwiftUI

struct RecoveryAiCoachSection: View {
    @ObservedObject var viewModel: RecoveryDashboardViewModel
    var isWeekly: Bool = false
    
    var state: RecoveryDashboardViewModel.LoadState<RecoveryDailyInsights> {
        isWeekly ? viewModel.weeklyInsightsState : viewModel.todayInsightsState
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Header
            HStack {
                Label(isWeekly ? "AI Weekly Focus" : "AI Recovery Coach", systemImage: "sparkles")
                    .font(.app(.heading))
                    .foregroundStyle(DesignSystem.Colors.accent)
                Spacer()
            }
            
            content
        }
        .padding(16)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .onAppear {
            if !isWeekly, case .idle = viewModel.todayInsightsState {
                Task { await viewModel.loadTodayInsights() }
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch state {
        case .idle, .loading:
            loadingView
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            
        case .loaded(let insights):
            loadedView(insights)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            
        case .failed:
            errorView
                .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            Text(isWeekly ? "Analyzing weekly trends..." : "Analyzing your recent sleep and recovery data...")
                .font(.app(.body))
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
            ProgressView()
                .scaleEffect(0.8)
            
            Text("This can take a few seconds")
                .font(.app(.caption))
                .foregroundStyle(DesignSystem.Colors.textTertiary)
        }
        .padding(.vertical, 12)
    }
    
    private func loadedView(_ insights: RecoveryDailyInsights) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Score and Headline
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(insights.headline)
                        .font(.app(.heading))
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(isWeekly ? "Avg Recovery Score: \(insights.recoveryScore)" : "Recovery Score: \(insights.recoveryScore)")
                        .font(.app(.caption))
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                // Score Ring or simple badge
                ZStack {
                    Circle()
                        .stroke(DesignSystem.Colors.neutral200, lineWidth: 4)
                        .frame(width: 44, height: 44)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(insights.recoveryScore) / 100.0)
                        .stroke(
                            insights.recoveryScore > 70 ? Color.green : (insights.recoveryScore > 40 ? Color.orange : Color.red),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 44, height: 44)
                    
                    Text("\(insights.recoveryScore)")
                        .font(.app(.caption).bold())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                }
            }
            
            // Focus Tags
            if !insights.todayFocusTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(insights.todayFocusTags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.app(.caption))
                                .fontWeight(.medium)
                                .foregroundStyle(DesignSystem.Colors.accent)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(DesignSystem.Colors.accent.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            
            Divider()
            
            // Recommendations / Key Issues
            VStack(alignment: .leading, spacing: 8) {
                ForEach(insights.keyIssues.prefix(2), id: \.self) { issue in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.orange)
                            .offset(y: 2)
                        
                        Text(issue)
                            .font(.app(.body))
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                if insights.keyIssues.isEmpty || insights.keyIssues == ["None"] {
                    Text(insights.summary)
                        .font(.app(.body))
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            // Action Button
            Button {
                if isWeekly {
                    viewModel.isShowingWeeklyPlanSheet = true
                } else {
                    viewModel.isShowingPlanSheet = true
                }
            } label: {
                HStack {
                    Text(isWeekly ? "View Weekly Focus Plan" : "View Smart Plan")
                    Image(systemName: "arrow.right")
                }
                .font(.app(.body).weight(.medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(DesignSystem.Colors.accent)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
    
    private var errorView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 24))
                .foregroundStyle(.red)
            
            Text("We could not load your \(isWeekly ? "weekly" : "daily") insights right now.")
                .font(.app(.body))
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                Task { await viewModel.reloadTodayInsights() }
            }
            .font(.app(.body).weight(.medium))
            .foregroundStyle(DesignSystem.Colors.accent)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
    }
}
