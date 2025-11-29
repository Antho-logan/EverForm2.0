//
//  TrainingScheduleView.swift
//  EverForm
//
//  Created by Assistant on 27/11/2025.
//

import SwiftUI

struct TrainingScheduleView: View {
  @ObservedObject var viewModel: TrainingViewModel
  @State private var viewMode: TrainingViewMode = .today
  @State private var showPlan = false
  @State private var showingChangePlanOptions = false

  enum TrainingViewMode: String, CaseIterable {
    case today = "Today"
    case week = "Week"
  }

  var body: some View {
    ZStack(alignment: .top) {
      // Main Content
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          
          // Header Controls
          VStack(alignment: .leading, spacing: 16) {
            // Goal Pill & Segment
            HStack {
              Text("Goal: Strength")
                .font(EverFont.label)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(DesignSystem.Colors.backgroundSecondary)
                .clipShape(Capsule())
                .foregroundColor(DesignSystem.Colors.textSecondary)

              Spacer()

              Picker("View", selection: $viewMode) {
                ForEach(TrainingViewMode.allCases, id: \.self) { mode in
                  Text(mode.rawValue).tag(mode)
                }
              }
              .pickerStyle(.segmented)
              .frame(width: 140)
            }
            .padding(.horizontal, 20)
          }
          .padding(.top, 16)

          if viewMode == .today {
            // Week Selector
            TrainingWeekRow(
              days: viewModel.schedule,
              selectedDay: viewModel.selectedDay,
              onSelect: { viewModel.select(day: $0) }
            )

            // Today's Plan Summary (if not rest day)
            if let day = viewModel.selectedDay, !day.isRestDay {
              TodayPlanSummaryCard(day: day) {
                openPlan()
              }
              .padding(.horizontal, 20)
            }

            // Change Plan Button
            HStack {
              Spacer()
              Button {
                showingChangePlanOptions = true
              } label: {
                Text("Change plan")
                  .font(EverFont.label)
                  .foregroundColor(DesignSystem.Colors.accent)
              }
              .padding(.trailing, 24)
            }
            
          } else {
            // Week View
            VStack(spacing: 16) {
              ForEach(viewModel.schedule) { day in
                WeekListRow(day: day)
                  .onTapGesture {
                    viewModel.select(day: day)
                    withAnimation {
                      viewMode = .today
                    }
                  }
              }
            }
            .padding(.horizontal, 20)
            .transition(.opacity)
          }

          Spacer(minLength: 100)
        }
        .padding(.bottom, 40)
      }

      // Sheet Overlay
      if showPlan, let day = viewModel.selectedDay {
        Color.black.opacity(0.25)
          .ignoresSafeArea()
          .onTapGesture { closePlan() }
          .transition(.opacity)
          .zIndex(1)

        TodaysTrainingPlanView(show: $showPlan, day: day)
          .transition(.move(edge: .bottom))
          .zIndex(2)
      }
    }
    .navigationTitle("Workout Schedule")
    .navigationBarTitleDisplayMode(.inline)
    .actionSheet(isPresented: $showingChangePlanOptions) {
      if let day = viewModel.selectedDay {
        return ActionSheet(
          title: Text("Modify Schedule"),
          buttons: [
            .default(Text("Swap Workout")) { /* Stub */  },
            .default(Text(day.isRestDay ? "Remove Rest Day" : "Mark as Rest Day")) {
              withAnimation {
                viewModel.toggleRest(for: day)
              }
            },
            .cancel(),
          ]
        )
      } else {
        return ActionSheet(title: Text("Error"), buttons: [.cancel()])
      }
    }
  }

  // MARK: - Actions

  func openPlan() {
    UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.6)
    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
      showPlan = true
    }
  }

  func closePlan() {
    withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
      showPlan = false
    }
  }
}