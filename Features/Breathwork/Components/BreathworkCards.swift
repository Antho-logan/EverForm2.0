//
//  BreathworkCards.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import SwiftUI

struct BreathworkPatternCard: View {
  let pattern: BreathworkPattern
  let isSelected: Bool
  let onTap: () -> Void

  var body: some View {
    Button(action: onTap) {
      VStack(alignment: .leading, spacing: 12) {
        HStack {
          ZStack {
            Circle()
              .fill(
                LinearGradient(
                  colors: pattern.type.gradientColors, startPoint: .topLeading,
                  endPoint: .bottomTrailing)
              )
              .frame(width: 40, height: 40)

            Image(systemName: pattern.type.iconName)
              .foregroundStyle(.white)
              .font(.system(size: 18, weight: .semibold))
          }

          Spacer()

          if isSelected {
            Image(systemName: "checkmark.circle.fill")
              .foregroundStyle(DesignSystem.Colors.accent)
              .font(.title3)
          }
        }

        Spacer()

        VStack(alignment: .leading, spacing: 4) {
          Text(pattern.displayName)
            .font(DesignSystem.Typography.headline())
            .foregroundStyle(DesignSystem.Colors.textPrimary)
            .lineLimit(1)

          Text(pattern.targetEffect)
            .font(DesignSystem.Typography.caption())
            .foregroundStyle(DesignSystem.Colors.textSecondary)
        }
      }
      .padding(16)
      .frame(width: 160, height: 140)
      .background(DesignSystem.Colors.cardBackground)
      .clipShape(RoundedRectangle(cornerRadius: 20))
      .overlay(
        RoundedRectangle(cornerRadius: 20)
          .stroke(isSelected ? DesignSystem.Colors.accent : Color.clear, lineWidth: 2)
      )
      .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    .buttonStyle(.plain)
    .scaleEffect(isSelected ? 1.02 : 1.0)
    .animation(.spring(response: 0.3), value: isSelected)
  }
}

struct BreathworkStatCard: View {
  let title: String
  let value: String
  let icon: String
  let color: Color

  var body: some View {
    HStack(spacing: 12) {
      ZStack {
        Circle()
          .fill(color.opacity(0.1))
          .frame(width: 36, height: 36)
        Image(systemName: icon)
          .foregroundStyle(color)
          .font(.caption.weight(.semibold))
      }

      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(DesignSystem.Typography.caption())
          .foregroundStyle(DesignSystem.Colors.textSecondary)
        Text(value)
          .font(DesignSystem.Typography.title3())
          .foregroundStyle(DesignSystem.Colors.textPrimary)
      }
      Spacer()
    }
    .padding(12)
    .background(DesignSystem.Colors.cardBackground)
    .clipShape(RoundedRectangle(cornerRadius: 16))
  }
}

struct BreathworkProgramCard: View {
  let program: BreathworkProgram
  let progress: Double  // 0.0 to 1.0
  @State private var showAnimation = false

  var body: some View {
    HStack(spacing: 16) {
      // Progress Ring Placeholder
      ZStack {
        Circle()
          .stroke(DesignSystem.Colors.neutral200, lineWidth: 4)
        Circle()
          .trim(from: 0, to: showAnimation ? progress : 0)
          .stroke(DesignSystem.Colors.accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
          .rotationEffect(.degrees(-90))
          .animation(.spring(response: 1.2, dampingFraction: 0.8), value: showAnimation)

        Text("\(Int(progress * 100))%")
          .font(.caption2.weight(.bold))
          .foregroundStyle(DesignSystem.Colors.textSecondary)
      }
      .frame(width: 48, height: 48)

      VStack(alignment: .leading, spacing: 4) {
        Text(program.name)
          .font(DesignSystem.Typography.headline())
          .foregroundStyle(DesignSystem.Colors.textPrimary)

        Text("\(program.daysCount) Days • \(program.dailyMinutes) min/day")
          .font(DesignSystem.Typography.subheadline())
          .foregroundStyle(DesignSystem.Colors.textSecondary)
      }

      Spacer()

      Image(systemName: "chevron.right")
        .foregroundStyle(DesignSystem.Colors.neutral400)
    }
    .padding(16)
    .background(DesignSystem.Colors.cardBackground)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .onAppear {
      showAnimation = true
    }
  }
}

// Helper Typography until fully synced with DesignSystem file I saw earlier which had static funcs
extension DesignSystem.Typography {
  static func headline() -> Font { .system(size: 17, weight: .semibold) }
  static func title3() -> Font { .system(size: 20, weight: .semibold) }
  static func subheadline() -> Font { .system(size: 15, weight: .regular) }
  // caption already exists in snippet I read? I'll just add robust fallbacks here to be safe
}
