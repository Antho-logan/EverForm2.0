//
//  ExerciseDetailSheet.swift
//  EverForm
//
//  Created by Gemini on 18/11/2025.
//  Updated by Assistant on 21/11/2025.
//
//

import SwiftUI

struct ExerciseDetailSheet: View {
  let exercise: TrainingExercise
  @Binding var isPresented: Bool

  var body: some View {
    VStack(spacing: 0) {
      // Drag handle
      Capsule()
        .fill(Color.secondary.opacity(0.3))
        .frame(width: 36, height: 5)
        .padding(.top, 8)
        .padding(.bottom, 20)

      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          // Header
          VStack(alignment: .leading, spacing: 8) {
            Text(exercise.name)
              .font(DesignSystem.Typography.displaySmall())
              .foregroundStyle(DesignSystem.Colors.textPrimary)

            HStack {
              ForEach(exercise.primaryMuscles, id: \.self) { muscle in
                Tag(text: muscle.label, color: DesignSystem.Colors.accent)
              }
              ForEach(exercise.secondaryMuscles, id: \.self) { muscle in
                Tag(text: muscle.label, color: DesignSystem.Colors.textSecondary)
              }
            }
          }

          // Video Placeholder
          ZStack {
            RoundedRectangle(cornerRadius: 16)
              .fill(DesignSystem.Colors.neutral100)
              .aspectRatio(16 / 9, contentMode: .fit)

            if let url = exercise.videoURL {
              // Placeholder for actual video player
              Link(destination: url) {
                Image(systemName: "play.circle.fill")
                  .font(.system(size: 48))
                  .foregroundStyle(DesignSystem.Colors.accent.opacity(0.8))
              }
            } else {
              Image(systemName: "play.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(DesignSystem.Colors.accent.opacity(0.8))
            }
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
                .font(EverFont.cardTitle)
                .foregroundStyle(DesignSystem.Colors.textPrimary)

              ForEach(Array(exercise.technique.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                  Text("\(index + 1)")
                    .font(EverFont.label)
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background(DesignSystem.Colors.neutral400)
                    .clipShape(Circle())
                    .padding(.top, 2)

                  Text(step)
                    .font(EverFont.body)
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                }
              }
            }
          }

          // Coach Cue
          if let cue = exercise.coachCue {
            VStack(alignment: .leading, spacing: 8) {
              Text("Coach Cue")
                .font(EverFont.cardTitle)
                .foregroundStyle(DesignSystem.Colors.textPrimary)

              HStack(spacing: 12) {
                Image(systemName: "brain.head.profile")
                  .foregroundStyle(DesignSystem.Colors.accent)
                  .font(.title2)

                Text("\"\(cue)\"")
                  .font(EverFont.bodySecondary.italic())
                  .foregroundStyle(DesignSystem.Colors.textPrimary)
              }
              .padding()
              .frame(maxWidth: .infinity, alignment: .leading)
              .background(DesignSystem.Colors.backgroundSecondary)
              .clipShape(RoundedRectangle(cornerRadius: 12))
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(DesignSystem.Colors.border, lineWidth: 1)
              )
            }
          }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
      }
    }
    .background(DesignSystem.Colors.cardBackground)
  }
}

// MARK: - Components

private struct DetailCell: View {
  let title: String
  let value: String
  let icon: String

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Image(systemName: icon)
          .foregroundStyle(DesignSystem.Colors.accent)
        Text(title)
          .font(EverFont.label)
          .foregroundStyle(DesignSystem.Colors.textSecondary)
      }

      Text(value)
        .font(EverFont.bodySecondary.weight(.semibold))
        .foregroundStyle(DesignSystem.Colors.textPrimary)
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(DesignSystem.Colors.backgroundSecondary)
    .clipShape(RoundedRectangle(cornerRadius: 12))
  }
}

private struct Tag: View {
  let text: String
  var color: Color = .blue

  var body: some View {
    Text(text)
      .font(EverFont.smallCaption)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(color.opacity(0.1))
      .foregroundStyle(color)
      .clipShape(Capsule())
  }
}
