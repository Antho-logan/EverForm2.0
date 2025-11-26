//
//  TodaysTrainingPlanView.swift
//  EverForm
//
//  Created by Gemini on 18/11/2025.
//  Updated by Assistant on 21/11/2025.
//
//

import SwiftUI

struct TodaysTrainingPlanView: View {
  @Binding var show: Bool
  let day: TrainingDay

  @State private var selectedExercise: TrainingExercise?

  var body: some View {
    GeometryReader { proxy in
      VStack(spacing: 0) {
        // Custom Sheet Header
        HStack(alignment: .center) {
          VStack(alignment: .leading, spacing: 4) {
            Text(day.isToday ? "TODAY" : day.label.uppercased())
              .font(EverFont.label)
              .foregroundColor(DesignSystem.Colors.accent)
              .tracking(1.0)

            Text(day.focusTitle)
              .font(DesignSystem.Typography.titleMedium())
              .foregroundColor(DesignSystem.Colors.textPrimary)
              .lineLimit(1)

            // Chip Row
            HStack(spacing: 12) {
              Label("\(day.durationMinutes) min", systemImage: "clock")
              Text("•")
              Text(day.difficulty.rawValue)
              Text("•")
              Text(day.style.rawValue)
            }
            .font(EverFont.caption)
            .foregroundColor(DesignSystem.Colors.textSecondary)
          }

          Spacer()

          Button {
            show = false
          } label: {
            Image(systemName: "xmark.circle.fill")
              .font(.system(size: 30))
              .foregroundStyle(DesignSystem.Colors.neutral200)
          }
        }
        .padding(24)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .zIndex(1)

        ScrollView {
          VStack(alignment: .leading, spacing: 24) {

            // Sections
            if day.sections.isEmpty {
              EmptyStateView(message: "No exercises planned for this session.")
            } else {
              ForEach(day.sections) { section in
                VStack(alignment: .leading, spacing: 12) {
                  Text(section.title.uppercased())
                    .font(EverFont.label)
                    .fontWeight(.bold)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .padding(.leading, 24)

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

            // Bottom Padding for sticky button
            Spacer().frame(height: 100)
          }
          .padding(.top, 24)
        }

        // Sticky Button
        if !day.isRestDay {
          VStack {
            Spacer()
            Button(action: {
              // Start workout logic
            }) {
              Text("Start Workout")
                .font(EverFont.button)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(DesignSystem.Colors.accent)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: DesignSystem.Colors.accent.opacity(0.3), radius: 10, y: 5)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
          }
        }
      }
      .background(DesignSystem.Colors.background)
      .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
      .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
      .padding(.top, 60)
      .ignoresSafeArea(edges: .bottom)
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
    Button(action: onTap) {
      HStack(alignment: .center, spacing: 16) {
        // Icon Avatar
        ZStack {
          Circle()
            .fill(DesignSystem.Colors.backgroundSecondary)
            .frame(width: 44, height: 44)

          Image(systemName: iconForExercise(exercise))
            .font(.system(size: 18))
            .foregroundColor(DesignSystem.Colors.textPrimary)
        }

        // Info
        VStack(alignment: .leading, spacing: 4) {
          Text(exercise.name)
            .font(EverFont.bodySecondary)
            .fontWeight(.semibold)
            .foregroundColor(DesignSystem.Colors.textPrimary)
            .lineLimit(1)

          if let sub = exercise.sublabel {
            Text(sub)
              .font(EverFont.caption)
              .foregroundColor(DesignSystem.Colors.textSecondary)
          }
        }

        Spacer()

        // Stats
        Text(exercise.volumeString)
          .font(EverFont.bodySecondary)
          .fontWeight(.medium)
          .foregroundColor(DesignSystem.Colors.textPrimary)

        Image(systemName: "chevron.right")
          .font(EverFont.caption)
          .foregroundColor(DesignSystem.Colors.neutral300)
      }
      .padding(16)
      .background(DesignSystem.Colors.cardBackground)
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(DesignSystem.Colors.border, lineWidth: 0.5)
      )
    }
    .buttonStyle(ScaleButtonStyle())
  }

  func iconForExercise(_ exercise: TrainingExercise) -> String {
    // Simple heuristic for icons
    let lower = exercise.name.lowercased()
    if lower.contains("squat") || lower.contains("leg") {
      return "figure.strengthtraining.traditional"
    }
    if lower.contains("run") || lower.contains("cardio") { return "figure.run" }
    if lower.contains("yoga") || lower.contains("stretch") { return "figure.yoga" }
    return "dumbbell.fill"
  }
}

struct EmptyStateView: View {
  let message: String
  var body: some View {
    VStack(spacing: 12) {
      Image(systemName: "list.bullet.clipboard")
        .font(.largeTitle)
        .foregroundColor(DesignSystem.Colors.neutral300)
      Text(message)
        .font(EverFont.bodySecondary)
        .foregroundColor(DesignSystem.Colors.textSecondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 40)
  }
}

struct ScaleButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
      .animation(.spring(response: 0.3), value: configuration.isPressed)
  }
}
