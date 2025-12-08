//
//  TrainingScheduleView.swift
//  EverForm
//
//  Created by Assistant on 27/11/2025.
//  Updated by Assistant on 21/11/2025.
//

import SwiftUI

struct TrainingScheduleView: View {
  @ObservedObject var viewModel: TrainingViewModel
  @State private var viewMode: TrainingViewMode = .today
  @State private var showPlan = false
  @State private var showingChangePlanOptions = false
  @Environment(\.dismiss) private var dismiss

  enum TrainingViewMode: String, CaseIterable {
    case today = "Today"
    case week = "Week"
  }

  var body: some View {
    EFScreenContainer {
      VStack(spacing: 0) {
        EFHeader(title: "Workout Schedule", showBack: true) {
            dismiss()
        }
        
        ScrollView {
            VStack(alignment: .leading, spacing: EverFormTheme.Spacing.sectionSpacing) {
                
                // Controls
                HStack {
                    EFPillChip("Goal: Strength", isSelected: false) {}
                        .disabled(true)
                    
                    Spacer()
                    
                    EFSegmentedControl(
                        items: TrainingViewMode.allCases,
                        selection: $viewMode
                    ) { mode in mode.rawValue }
                    .frame(width: 160)
                }
                .padding(.horizontal, EverFormTheme.Spacing.screenPadding)
                
                if viewMode == .today {
                    // Week Selector
                    TrainingWeekRow(
                        days: viewModel.schedule,
                        selectedDay: viewModel.selectedDay,
                        onSelect: { viewModel.select(day: $0) }
                    )
                    
                    // Plan Summary
                    if let day = viewModel.selectedDay, !day.isRestDay {
                        TodayPlanSummaryCard(day: day) {
                            openPlan()
                        }
                        .padding(.horizontal, EverFormTheme.Spacing.screenPadding)
                    }
                    
                    // Change Plan
                    HStack {
                        Spacer()
                        Button {
                            showingChangePlanOptions = true
                        } label: {
                            Text("Change plan")
                                .font(EverFormTheme.Typography.label)
                                .foregroundStyle(EverFormTheme.Colors.trainingGreen)
                        }
                        .padding(.trailing, EverFormTheme.Spacing.screenPadding)
                    }
                } else {
                    // Week List
                    VStack(spacing: 12) {
                        ForEach(viewModel.schedule) { day in
                            WeekListRow(day: day)
                                .onTapGesture {
                                    viewModel.select(day: day)
                                    withAnimation { viewMode = .today }
                                }
                        }
                    }
                    .padding(.horizontal, EverFormTheme.Spacing.screenPadding)
                }
                
                Spacer(minLength: 100)
            }
            .padding(.bottom, 40)
        }
      }
      
      // Sheet Overlay
      if showPlan, let day = viewModel.selectedDay {
        Color.black.opacity(0.25)
          .ignoresSafeArea()
          .onTapGesture { closePlan() }
          .zIndex(1)

        TodaysTrainingPlanView(show: $showPlan, day: day)
          .transition(.move(edge: .bottom))
          .zIndex(2)
      }
    }
    .actionSheet(isPresented: $showingChangePlanOptions) {
        // Keep existing logic
        if let day = viewModel.selectedDay {
            return ActionSheet(
                title: Text("Modify Schedule"),
                buttons: [
                    .default(Text("Swap Workout")) {},
                    .default(Text(day.isRestDay ? "Remove Rest Day" : "Mark as Rest Day")) {
                        withAnimation { viewModel.toggleRest(for: day) }
                    },
                    .cancel()
                ]
            )
        } else {
            return ActionSheet(title: Text("Error"), buttons: [.cancel()])
        }
    }
  }
  
  // Actions
  func openPlan() {
    let impact = UIImpactFeedbackGenerator(style: .light)
    impact.impactOccurred()
    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) { showPlan = true }
  }
  func closePlan() { withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) { showPlan = false } }
}

// MARK: - Subviews

struct TrainingWeekRow: View {
    let days: [TrainingDay]
    let selectedDay: TrainingDay?
    let onSelect: (TrainingDay) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(days) { day in
                    DayChip(
                        day: day,
                        isSelected: day.id == selectedDay?.id,
                        onTap: { onSelect(day) }
                    )
                }
            }
            .padding(.horizontal, EverFormTheme.Spacing.screenPadding)
        }
    }
}

struct DayChip: View {
    let day: TrainingDay
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(day.dayLetter)
                    .font(EverFormTheme.Typography.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(isSelected ? EverFormTheme.Colors.textOnAccent : EverFormTheme.Colors.textSecondary)
                
                Circle()
                    .fill(indicatorColor)
                    .frame(width: 6, height: 6)
            }
            .frame(width: 48, height: 64)
            .background(isSelected ? EverFormTheme.Colors.trainingGreen : EverFormTheme.Colors.card)
            .clipShape(RoundedRectangle(cornerRadius: EverFormTheme.Radius.pill))
            .overlay(
                RoundedRectangle(cornerRadius: EverFormTheme.Radius.pill)
                    .stroke(EverFormTheme.Colors.cardStroke, lineWidth: isSelected ? 0 : 1)
            )
            .shadow(color: isSelected ? EverFormTheme.Colors.trainingGreen.opacity(0.3) : Color.clear, radius: 8, y: 4)
        }
    }
    
    var indicatorColor: Color {
        if day.isCompleted { return isSelected ? .white : EverFormTheme.Colors.successGreen }
        return isSelected ? .white.opacity(0.5) : EverFormTheme.Colors.textSecondary.opacity(0.3)
    }
}

struct TodayPlanSummaryCard: View {
    let day: TrainingDay
    let action: () -> Void
    
    var body: some View {
        EFCard(style: .tinted(EverFormTheme.Colors.trainingGreen)) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Today's Plan")
                        .font(EverFormTheme.Typography.cardTitle)
                        .foregroundStyle(EverFormTheme.Colors.textPrimary)
                    Spacer()
                    Text("Generated")
                        .font(EverFormTheme.Typography.caption)
                        .foregroundStyle(EverFormTheme.Colors.textSecondary)
                }
                
                VStack(spacing: 0) {
                    ForEach(Array(day.sections.prefix(3).enumerated()), id: \.element.id) { index, section in
                        PlanRow(
                            title: section.title,
                            subtitle: "\(section.exercises.count) exercises",
                            icon: "dumbbell.fill"
                        )
                        if index < min(day.sections.count, 3) - 1 {
                            Divider().padding(.leading, 40)
                        }
                    }
                }
            }
        }
        .onTapGesture { action() }
    }
}

struct PlanRow: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(EverFormTheme.Colors.trainingGreen)
                .frame(width: 32, height: 32)
                .background(EverFormTheme.Colors.trainingGreen.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(EverFormTheme.Typography.body)
                    .foregroundStyle(EverFormTheme.Colors.textPrimary)
                Text(subtitle)
                    .font(EverFormTheme.Typography.caption)
                    .foregroundStyle(EverFormTheme.Colors.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(EverFormTheme.Colors.textSecondary)
        }
        .padding(.vertical, 8)
    }
}

struct WeekListRow: View {
    let day: TrainingDay
    
    var body: some View {
        EFCard {
            HStack(spacing: 16) {
                // Date Badge
                VStack {
                    Text(day.label)
                        .font(EverFormTheme.Typography.caption)
                        .foregroundStyle(EverFormTheme.Colors.textSecondary)
                    Text(day.date.formatted(.dateTime.day()))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(EverFormTheme.Colors.textPrimary)
                }
                .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(day.focusTitle)
                        .font(EverFormTheme.Typography.cardTitle)
                        .foregroundStyle(EverFormTheme.Colors.textPrimary)
                    
                    HStack {
                        Text(day.bodyFocus.rawValue)
                            .font(EverFormTheme.Typography.caption)
                            .foregroundStyle(EverFormTheme.Colors.trainingGreen)
                        if !day.isRestDay {
                            Text("• \(day.durationMinutes) min")
                                .font(EverFormTheme.Typography.caption)
                                .foregroundStyle(EverFormTheme.Colors.textSecondary)
                        }
                    }
                }
                Spacer()
                
                if day.isToday {
                    Text("Today")
                        .font(EverFormTheme.Typography.label)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(EverFormTheme.Colors.trainingGreen.opacity(0.1))
                        .foregroundStyle(EverFormTheme.Colors.trainingGreen)
                        .clipShape(Capsule())
                }
            }
        }
    }
}
