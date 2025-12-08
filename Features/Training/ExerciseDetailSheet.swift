//
//  ExerciseDetailSheet.swift
//  EverForm
//
//  Created by Gemini on 18/11/2025.
//  Updated by Assistant on 21/11/2025.
//

import SwiftUI

struct ExerciseDetailSheet: View {
  let exercise: TrainingExercise
  @Binding var isPresented: Bool

  var body: some View {
    EFScreenContainer {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          // Header
          VStack(alignment: .leading, spacing: 8) {
            Text(exercise.name)
              .font(EverFormTheme.Typography.screenTitle)
              .foregroundStyle(EverFormTheme.Colors.textPrimary)

            HStack {
              ForEach(exercise.primaryMuscles, id: \.self) { muscle in
                EFPillChip(muscle.label, isSelected: true) {}
                  .disabled(true)
              }
              ForEach(exercise.secondaryMuscles, id: \.self) { muscle in
                EFPillChip(muscle.label, isSelected: false) {}
                  .disabled(true)
              }
            }
          }

          // Video Placeholder
          ZStack {
            RoundedRectangle(cornerRadius: 16)
              .fill(EverFormTheme.Colors.surface)
              .aspectRatio(16 / 9, contentMode: .fit)

            Image(systemName: "play.circle.fill")
              .font(.system(size: 48))
              .foregroundStyle(EverFormTheme.Colors.trainingGreen.opacity(0.8))
          }

          // Details Grid
          LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            DetailCell(title: "Tempo", value: exercise.tempo, icon: "metronome")
            DetailCell(title: "Rest", value: exercise.rest, icon: "timer")
            DetailCell(title: "Breathing", value: exercise.breathing, icon: "lungs")
            DetailCell(title: "Safety", value: exercise.safety, icon: "cross.case")
          }

          // Technique
          if !exercise.technique.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
              Text("Technique")
                .font(EverFormTheme.Typography.cardTitle)
                .foregroundStyle(EverFormTheme.Colors.textPrimary)

              ForEach(Array(exercise.technique.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                  Text("\(index + 1)")
                    .font(EverFormTheme.Typography.label)
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background(EverFormTheme.Colors.textSecondary)
                    .clipShape(Circle())
                    .padding(.top, 2)

                  Text(step)
                    .font(EverFormTheme.Typography.body)
                    .foregroundStyle(EverFormTheme.Colors.textPrimary)
                }
              }
            }
          }

          // Coach Cue
          if let cue = exercise.coachCue {
            VStack(alignment: .leading, spacing: 8) {
              Text("Coach Cue")
                .font(EverFormTheme.Typography.cardTitle)
                .foregroundStyle(EverFormTheme.Colors.textPrimary)

              EFCard {
                  HStack(spacing: 12) {
                    Image(systemName: "brain.head.profile")
                      .foregroundStyle(EverFormTheme.Colors.trainingGreen)
                      .font(.title2)

                    Text("\"\(cue)\"")
                      .font(EverFormTheme.Typography.body.italic())
                      .foregroundStyle(EverFormTheme.Colors.textPrimary)
                  }
              }
            }
          }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
        .padding(.top, 24)
      }
    }
  }
}

// MARK: - Components

private struct DetailCell: View {
  let title: String
  let value: String
  let icon: String

  var body: some View {
    EFCard {
        VStack(alignment: .leading, spacing: 8) {
          HStack {
            Image(systemName: icon)
              .foregroundStyle(EverFormTheme.Colors.trainingGreen)
            Text(title)
              .font(EverFormTheme.Typography.label)
              .foregroundStyle(EverFormTheme.Colors.textSecondary)
          }

          Text(value)
            .font(EverFormTheme.Typography.body)
            .fontWeight(.semibold)
            .foregroundStyle(EverFormTheme.Colors.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
  }
}
