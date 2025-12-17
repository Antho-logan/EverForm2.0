//
//  TodaysTrainingPlanView.swift
//  EverForm
//
//  Created by Gemini on 18/11/2025.
//  Updated by Assistant on 21/11/2025.
//

import SwiftUI

struct TodaysTrainingPlanView: View {
  @Binding var show: Bool
  let day: TrainingDay
  
  @State private var selectedExercise: TrainingExercise?

  var body: some View {
    EFScreenContainer {
      VStack(spacing: 0) {
        // Custom Sheet Header
        HStack(alignment: .center) {
          VStack(alignment: .leading, spacing: 4) {
            Text(day.isToday ? "TODAY" : day.label.uppercased())
              .font(EverFormTheme.Typography.label)
              .foregroundColor(EverFormTheme.Colors.trainingGreen)
              .tracking(1.0)

            Text(day.focusTitle)
              .font(EverFormTheme.Typography.cardTitle)
              .foregroundColor(EverFormTheme.Colors.textPrimary)
              .lineLimit(1)

            // Chip Row
            HStack(spacing: 12) {
              Label("\(day.durationMinutes) min", systemImage: "clock")
              Text("•")
              Text(day.difficulty.rawValue)
              Text("•")
              Text(day.style.rawValue)
            }
            .font(EverFormTheme.Typography.caption)
            .foregroundColor(EverFormTheme.Colors.textSecondary)
          }

          Spacer()

          Button {
            show = false
          } label: {
            Image(systemName: "xmark.circle.fill")
              .font(.system(size: 30))
              .foregroundStyle(EverFormTheme.Colors.textSecondary.opacity(0.5))
          }
        }
        .padding(24)
        .background(EverFormTheme.Colors.card)
        // No clipShape here to allow it to blend with background if needed, or rounded bottom?
        // Keeping simple background.
        
        ScrollView {
          VStack(alignment: .leading, spacing: 24) {

            // Sections
            if day.sections.isEmpty {
                VStack(spacing: 12) {
                  Image(systemName: "list.bullet.clipboard")
                    .font(.largeTitle)
                    .foregroundColor(EverFormTheme.Colors.textSecondary)
                  Text("No exercises planned for this session.")
                    .font(EverFormTheme.Typography.body)
                    .foregroundColor(EverFormTheme.Colors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
              ForEach(day.sections) { section in
                VStack(alignment: .leading, spacing: 12) {
                  EFSectionHeader(title: section.title.uppercased())
                    .padding(.horizontal, 20)

                  VStack(spacing: 12) {
                    ForEach(section.exercises) { exercise in
                      ExerciseCardRow(exercise: exercise) {
                        selectedExercise = exercise
                      }
                    }
                  }
                  .padding(.horizontal, 20)
                }
              }
            }

          }
          .padding(.top, 24)
        }
      }
    }
    // Sticky bottom CTA as a proper safe-area inset (no fixed heights / magic padding).
    .safeAreaInset(edge: .bottom, spacing: 0) {
        if !day.isRestDay {
            VStack(spacing: 0) {
                // Top fade so the button feels docked but content is still readable.
                LinearGradient(
                    colors: [
                        EverFormTheme.Colors.background.opacity(0),
                        EverFormTheme.Colors.background,
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 22)

                EFPrimaryButton("Start Workout", color: EverFormTheme.Colors.trainingGreen) {
                    // Start logic
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            .background(EverFormTheme.Colors.background.ignoresSafeArea(edges: .bottom))
        }
    }
    .sheet(item: $selectedExercise) { exercise in
      ExerciseDetailSheet(
        exercise: exercise,
        isPresented: Binding(
          get: { selectedExercise != nil },
          set: { if !$0 { selectedExercise = nil } }
        )
      )
      .presentationDetents([.medium, .large])
      .presentationDragIndicator(.visible)
    }
  }
}

struct ExerciseCardRow: View {
  let exercise: TrainingExercise
  let onTap: () -> Void

  var body: some View {
    EFCard {
      HStack(alignment: .center, spacing: 16) {
        // Icon
        ZStack {
          Circle()
            .fill(EverFormTheme.Colors.surface)
            .frame(width: 44, height: 44)

          Image(systemName: "dumbbell.fill")
            .font(.system(size: 18))
            .foregroundColor(EverFormTheme.Colors.textPrimary)
        }

        // Info
        VStack(alignment: .leading, spacing: 4) {
          Text(exercise.name)
            .font(EverFormTheme.Typography.body)
            .fontWeight(.semibold)
            .foregroundColor(EverFormTheme.Colors.textPrimary)
            .lineLimit(1)

          if let sub = exercise.sublabel {
            Text(sub)
              .font(EverFormTheme.Typography.caption)
              .foregroundColor(EverFormTheme.Colors.textSecondary)
          }
        }

        Spacer()

        // Stats
        Text(exercise.volumeString)
          .font(EverFormTheme.Typography.body)
          .fontWeight(.medium)
          .foregroundColor(EverFormTheme.Colors.textPrimary)

        Image(systemName: "chevron.right")
          .font(EverFormTheme.Typography.caption)
          .foregroundColor(EverFormTheme.Colors.textSecondary)
      }
    }
    .onTapGesture { onTap() }
  }
}
