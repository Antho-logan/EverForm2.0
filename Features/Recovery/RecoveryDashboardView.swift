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
  @EnvironmentObject var logStore: RecoveryLogStore
  
  // State for multi-select
  @State private var selectedTypes: Set<RecoveryType> = []
  
  // State for sheet presentation
  @State private var isShowingLogSheet = false
  @State private var recoveryNote: String = ""
  @Namespace private var namespace
  
  var body: some View {
    EFScreenContainer {
      VStack(spacing: 0) {
        navigationHeader
        
        ScrollView {
          VStack(spacing: 24) {
            
            // Header Controls (Goal + Range Picker)
            headerControls
            
            // Main Summary Card
            summarySection
            
            // Sleep Analysis
            sleepAnalysisSection
            
            // Active Recovery / AI Coach
            aiCoachSection
            
            // Log Recovery Button
            logRecoveryButton
            
            // Guidance
            guidanceSection
            
            Spacer(minLength: 40)
          }
          .padding(.vertical, 20)
          .animation(.easeInOut(duration: 0.3), value: viewModel.selectedRange)
        }
      }
    }
    .navigationBarHidden(true)
    // Use standard .sheet instead of custom overlay
    .sheet(isPresented: $isShowingLogSheet) {
        RecoveryLogSheet(
            selectedTypes: $selectedTypes,
            note: $recoveryNote,
            onSave: { types, note in
                saveRecovery(types: types, note: note)
            },
            onCancel: {
                isShowingLogSheet = false
                recoveryNote = ""
            }
        )
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    // Nightly Smart Plan
    .sheet(isPresented: $viewModel.isShowingPlanSheet) {
        RecoveryPlanSheet(viewModel: viewModel)
            .presentationDetents([.large])
    }
    // Weekly Focus Plan
    .sheet(isPresented: $viewModel.isShowingWeeklyPlanSheet) {
        WeeklyRecoveryPlanView(viewModel: viewModel)
            .presentationDetents([.large])
    }
    // Insight Detail
    .sheet(isPresented: $viewModel.isShowingInsightDetail) {
        RecoveryInsightDetailView(
            title: viewModel.selectedRange == .today ? "Today's Insight" : "Weekly Insight",
            insight: currentInsight
        )
        .presentationDetents([.medium, .large])
    }
  }
  
  private var currentInsight: RecoveryDailyInsights? {
      switch viewModel.selectedRange {
      case .today:
          if case .loaded(let i) = viewModel.todayInsightsState { return i }
      case .week:
          if case .loaded(let i) = viewModel.weeklyInsightsState { return i }
      }
      return nil
  }
  
  private var headerControls: some View {
      VStack(spacing: 16) {
          // Compact Segmented Control
          RecoverySegmentedControl(selection: $viewModel.selectedRange)
          
          HStack {
              Label("Goal: Optimal", systemImage: "target")
                  .font(.app(.caption))
                  .foregroundStyle(DesignSystem.Colors.accent)
                  .padding(.horizontal, 10)
                  .padding(.vertical, 4)
                  .background(DesignSystem.Colors.accent.opacity(0.1))
                  .clipShape(Capsule())
              Spacer()
          }
          .padding(.horizontal, DesignSystem.Spacing.screenPadding)
      }
      .padding(.top, 16)
  }
  
  private var summarySection: some View {
      Group {
          if viewModel.selectedRange == .today {
              RecoverySummaryCard(log: viewModel.todayLog)
          } else {
              WeeklyRecoverySummaryCard(weekLogs: viewModel.weekLogs)
          }
      }
      .padding(.horizontal, DesignSystem.Spacing.screenPadding)
  }
  
  private var sleepAnalysisSection: some View {
      Group {
          if viewModel.selectedRange == .today {
              SleepStagesCard(stages: viewModel.todayLog.sleepStages)
          } else {
              WeeklySleepChart(weekLogs: viewModel.weekLogs)
          }
      }
      .padding(.horizontal, DesignSystem.Spacing.screenPadding)
  }
  
  private var aiCoachSection: some View {
      // Show AI Section for both Today and Week
      RecoveryAiCoachSection(
          viewModel: viewModel,
          isWeekly: viewModel.selectedRange == .week
      )
      .padding(.horizontal, DesignSystem.Spacing.screenPadding)
  }
  
  private var logRecoveryButton: some View {
      VStack(alignment: .leading, spacing: 16) {
        Button {
            isShowingLogSheet = true
        } label: {
            Text("Log Recovery")
                .font(.app(.button))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(DesignSystem.Colors.accent)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
      }
  }
  
  private var guidanceSection: some View {
      Group {
          Button {
              viewModel.isShowingInsightDetail = true
          } label: {
              if viewModel.selectedRange == .today {
                  RecoveryGuidanceCard(message: viewModel.todayLog.coachInsight)
              } else {
                  RecoveryGuidanceCard(message: viewModel.weeklyInsight)
              }
          }
          .buttonStyle(.plain)
      }
      .padding(.horizontal, DesignSystem.Spacing.screenPadding)
  }
  
  private func saveRecovery(types: Set<RecoveryType>, note: String) {
      for type in types {
          logStore.log(type: type, date: Date(), note: note)
          
          // Sync with local view model if needed for legacy reasons
          if let action = RecoveryAction(rawValue: type.rawValue) {
              viewModel.toggleAction(action)
          }
      }
      
      isShowingLogSheet = false
      recoveryNote = ""
      // Note: keeping selectedTypes populated as per requirements ("Option A")
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
