//
//  RecoveryRootView.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

import SwiftUI

struct RecoveryHomeView: View {
  @StateObject private var viewModel = RecoveryDashboardViewModel()
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    // No NavigationStack here - pushed from Overview
    EFScreenContainer {
        ScrollView {
          VStack(spacing: 24) {

            // Header Controls
            VStack(spacing: 16) {
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
            }
            .padding(.horizontal, 20)

            // Main Summary Card
            Group {
              if viewModel.selectedRange == .today {
                RecoverySummaryCard(log: viewModel.todayLog)
              } else {
                WeeklyRecoverySummaryCard(weekLogs: viewModel.weekLogs)
              }
            }
            .padding(.horizontal, 20)

            // Sleep Analysis
            Group {
              if viewModel.selectedRange == .today {
                SleepStagesCard(stages: viewModel.todayLog.sleepStages)
              } else {
                WeeklySleepChart(weekLogs: viewModel.weekLogs)
              }
            }
            .padding(.horizontal, 20)

            // Active Recovery (Always for Today)
            VStack(alignment: .leading, spacing: 16) {
              Text("Active Recovery")
                .font(.app(.title))
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .padding(.horizontal, 20)

              ActiveRecoveryGrid(completedActions: viewModel.todayLog.completedActions) { action in
                viewModel.toggleAction(action)
              }
              .padding(.horizontal, 20)
            }

            // Guidance
            Group {
                if viewModel.selectedRange == .today {
                    RecoveryGuidanceCard(message: viewModel.todayLog.coachInsight)
                } else {
                    RecoveryGuidanceCard(message: viewModel.weeklyInsight)
                }
            }
              .padding(.horizontal, 20)

            Spacer(minLength: 40)
          }
          .padding(.top, 16)
        }
    }
    .navigationTitle("Recovery")
    .navigationBarTitleDisplayMode(.large)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          dismiss()
        } label: {
          Image(systemName: "xmark.circle.fill")
            .font(.system(size: 24))
            .foregroundStyle(DesignSystem.Colors.neutral400)
        }
      }
    }
  }
}