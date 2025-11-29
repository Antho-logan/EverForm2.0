//
//  RecoveryDashboardView.swift
//  EverForm
//
//  Created by Assistant on 27/11/2025.
//

import SwiftUI

struct RecoveryDashboardView: View {
  @Environment(\.dismiss) private var dismiss
  @ObservedObject var viewModel: RecoveryDashboardViewModel
  
  var body: some View {
    EFScreenContainer {
      VStack(spacing: 0) {
        navigationHeader
        
        ScrollView {
          VStack(spacing: 24) {
            
            // Header Controls (Goal + Range Picker)
            HStack {
                Label("Goal: Optimal", systemImage: "target")
                  .font(.app(.caption))
                  .foregroundStyle(DesignSystem.Colors.accent)
                  .padding(.horizontal, 10)
                  .padding(.vertical, 4)
                  .background(DesignSystem.Colors.accent.opacity(0.1))
                  .clipShape(Capsule())

                Spacer()

                Picker("Range", selection: $viewModel.selectedRange) {
                  ForEach(RecoveryTimeRange.allCases) { range in
                    Text(range.rawValue).tag(range)
                  }
                }
                .pickerStyle(.segmented)
                .frame(width: 140)
            }
            .padding(.horizontal, DesignSystem.Spacing.screenPadding)
            .padding(.top, 16)

            // Main Summary Card
            Group {
              if viewModel.selectedRange == .today {
                RecoverySummaryCard(log: viewModel.todayLog)
              } else {
                WeeklyRecoverySummaryCard(weekLogs: viewModel.weekLogs)
              }
            }
            .padding(.horizontal, DesignSystem.Spacing.screenPadding)

            // Sleep Analysis
            Group {
              if viewModel.selectedRange == .today {
                SleepStagesCard(stages: viewModel.todayLog.sleepStages)
              } else {
                WeeklySleepChart(weekLogs: viewModel.weekLogs)
              }
            }
            .padding(.horizontal, DesignSystem.Spacing.screenPadding)

            // Active Recovery (Always for Today)
            VStack(alignment: .leading, spacing: 16) {
              Text("Active Recovery")
                .font(.app(.title))
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)

              ActiveRecoveryGrid(completedActions: viewModel.todayLog.completedActions) { action in
                viewModel.toggleAction(action)
              }
              .padding(.horizontal, DesignSystem.Spacing.screenPadding)
            }

            // Guidance
            Group {
                if viewModel.selectedRange == .today {
                    RecoveryGuidanceCard(message: viewModel.todayLog.coachInsight)
                } else {
                    RecoveryGuidanceCard(message: viewModel.weeklyInsight)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.screenPadding)
            
            Spacer(minLength: 40)
          }
          .padding(.vertical, 20)
        }
      }
    }
    .navigationBarHidden(true)
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
        
        Text("Recovery Dashboard")
            .font(.app(.heading))
            .foregroundStyle(DesignSystem.Colors.textPrimary)
            
        Spacer()
        
        // Hidden button for alignment
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

