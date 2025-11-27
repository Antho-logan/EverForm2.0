//
//  HRVEducationSheet.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

// TODO: Candidate for removal – appears unused in current EverForm flow.
import SwiftUI

struct HRVEducationSheet: View {
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {

          // Hero Section
          VStack(alignment: .leading, spacing: 12) {
            Text("What is HRV Biofeedback?")
              .font(.app(.largeTitle))
              .foregroundStyle(DesignSystem.Colors.textPrimary)

            Text(
              "Heart Rate Variability (HRV) Biofeedback is a powerful technique to train your nervous system for better balance, recovery, and performance."
            )
            .font(.app(.body))
            .foregroundStyle(DesignSystem.Colors.textSecondary)
            .lineSpacing(4)
          }

          Divider().overlay(DesignSystem.Colors.border)

          // Benefits
          VStack(alignment: .leading, spacing: 16) {
            Text("Key Benefits")
              .font(.app(.title))
              .foregroundStyle(DesignSystem.Colors.textPrimary)

            BenefitRow(
              icon: "heart.fill", title: "Cardiovascular Health",
              description: "Can help lower blood pressure and improve heart function.")
            BenefitRow(
              icon: "brain.head.profile", title: "Cognitive Performance",
              description: "Enhances focus, decision making, and mental clarity.")
            BenefitRow(
              icon: "wind", title: "Stress Reduction",
              description: "Reduces anxiety and helps manage chronic stress.")
            BenefitRow(
              icon: "bed.double.fill", title: "Better Sleep",
              description: "Prepares the body for deep, restorative sleep.")
          }

          Divider().overlay(DesignSystem.Colors.border)

          // How it works
          VStack(alignment: .leading, spacing: 12) {
            Text("How does it work?")
              .font(.app(.title))
              .foregroundStyle(DesignSystem.Colors.textPrimary)

            Text(
              "Your heart doesn't beat like a metronome. The time between beats varies, and this variation is healthy. It shows your Autonomic Nervous System (ANS) is responsive."
            )
            .font(.app(.body))
            .foregroundStyle(DesignSystem.Colors.textSecondary)
            .lineSpacing(4)

            Text(
              "Biofeedback training uses rhythmic breathing (usually around 6 breaths per minute) to synchronize your heart rate with your breath. This state is called 'Resonance', maximizing your HRV and strengthening your parasympathetic (rest-and-digest) system."
            )
            .font(.app(.body))
            .foregroundStyle(DesignSystem.Colors.textSecondary)
            .lineSpacing(4)
          }

          Spacer(minLength: 40)
        }
        .padding(24)
      }
      .background(DesignSystem.Colors.background)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Done") {
            dismiss()
          }
          .font(.app(.button))
          .foregroundStyle(DesignSystem.Colors.accent)
        }
      }
    }
  }
}

struct BenefitRow: View {
  let icon: String
  let title: String
  let description: String

  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      Image(systemName: icon)
        .font(.system(size: 24))
        .foregroundStyle(DesignSystem.Colors.accent)
        .frame(width: 32)

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.app(.heading))
          .foregroundStyle(DesignSystem.Colors.textPrimary)

        Text(description)
          .font(.app(.bodySecondary))
          .foregroundStyle(DesignSystem.Colors.textSecondary)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
  }
}
