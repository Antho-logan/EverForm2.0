//
//  RecoveryComponents.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

import SwiftUI

// MARK: - Summary Card

struct RecoverySummaryCard: View {
  let log: DailyRecoveryLog

  var body: some View {
    EFCard(
      style: .gradient(
        LinearGradient(
          colors: [Color.indigo.opacity(0.7), Color.blue.opacity(0.6)], startPoint: .topLeading,
          endPoint: .bottomTrailing))
    ) {
      VStack(alignment: .leading, spacing: 16) {
        HStack(alignment: .top) {
          VStack(alignment: .leading, spacing: 4) {
            Text("Total Sleep")
              .font(.app(.label))
              .foregroundStyle(.white.opacity(0.8))

            Text(log.formattedDuration)
              .font(.app(.largeTitle))
              .foregroundStyle(.white)

            HStack(spacing: 6) {
              Text(log.qualityLabel)
                .font(.app(.bodySecondary))
                .foregroundStyle(.white.opacity(0.9))

              Text("•")
                .foregroundStyle(.white.opacity(0.5))

              Text("Efficiency: \(log.efficiencyPercent)%")
                .font(.app(.caption))
                .foregroundStyle(.white.opacity(0.8))
            }
          }

          Spacer()

          VStack(alignment: .trailing, spacing: 2) {
            Text("\(log.sleepScore)")
              .font(.system(size: 36, weight: .bold, design: .rounded))
              .foregroundStyle(log.scoreColor)

            Text("Sleep Score")
              .font(.app(.caption))
              .foregroundStyle(.white.opacity(0.8))
          }
        }
      }
    }
  }
}

struct WeeklyRecoverySummaryCard: View {
  let weekLogs: [DailyRecoveryLog]

  var averages: (sleep: String, score: Int, efficiency: Int) {
    let totalMins = weekLogs.reduce(0) { $0 + $1.totalSleepMinutes }
    let totalScore = weekLogs.reduce(0) { $0 + $1.sleepScore }
    let totalEff = weekLogs.reduce(0) { $0 + $1.efficiencyPercent }
    let count = Double(weekLogs.count)

    guard count > 0 else { return ("--", 0, 0) }

    let avgMins = Int(Double(totalMins) / count)
    let avgScore = Int(Double(totalScore) / count)
    let avgEff = Int(Double(totalEff) / count)

    let h = avgMins / 60
    let m = avgMins % 60

    return ("\(h)h \(m)m", avgScore, avgEff)
  }

  var body: some View {
    EFCard(
      style: .gradient(
        LinearGradient(
          colors: [Color.indigo.opacity(0.7), Color.blue.opacity(0.6)], startPoint: .topLeading,
          endPoint: .bottomTrailing))
    ) {
      HStack(spacing: 0) {
        StatColumn(label: "Avg Sleep", value: averages.sleep)
        Divider().background(.white.opacity(0.2))
        StatColumn(label: "Avg Score", value: "\(averages.score)")
        Divider().background(.white.opacity(0.2))
        StatColumn(label: "Efficiency", value: "\(averages.efficiency)%")
      }
    }
  }

  struct StatColumn: View {
    let label: String
    let value: String

    var body: some View {
      VStack(spacing: 6) {
        Text(value)
          .font(.app(.title))
          .foregroundStyle(.white)
        Text(label)
          .font(.app(.caption))
          .foregroundStyle(.white.opacity(0.7))
      }
      .frame(maxWidth: .infinity)
    }
  }
}

// MARK: - Sleep Stages Chart

struct SleepStagesCard: View {
  let stages: SleepStageBreakdown
  @State private var showAnimation = false

  var body: some View {
    EFCard {
      VStack(alignment: .leading, spacing: 16) {
        Text("Sleep Stages")
          .font(.app(.heading))
          .foregroundStyle(DesignSystem.Colors.textPrimary)

        // Hypnogram Bar
        GeometryReader { geo in
          HStack(spacing: 0) {
            StageSegment(
              color: Color.indigo,
              width: showAnimation ? geo.size.width * ratio(stages.deepMinutes) : 0)
            StageSegment(
              color: Color.purple,
              width: showAnimation ? geo.size.width * ratio(stages.remMinutes) : 0)
            StageSegment(
              color: Color.blue.opacity(0.6),
              width: showAnimation ? geo.size.width * ratio(stages.lightMinutes) : 0)
            StageSegment(
              color: Color.orange.opacity(0.8),
              width: showAnimation ? geo.size.width * ratio(stages.awakeMinutes) : 0)
          }
        }
        .frame(height: 24)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
          withAnimation(.spring(response: 1.2, dampingFraction: 0.8)) {
            showAnimation = true
          }
        }

        // Legend
        VStack(spacing: 8) {
          StageLegendRow(
            color: .indigo, label: "Deep", minutes: stages.deepMinutes,
            percent: percentage(stages.deepMinutes))
          StageLegendRow(
            color: .purple, label: "REM", minutes: stages.remMinutes,
            percent: percentage(stages.remMinutes))
          StageLegendRow(
            color: .blue.opacity(0.6), label: "Light", minutes: stages.lightMinutes,
            percent: percentage(stages.lightMinutes))
          StageLegendRow(
            color: .orange.opacity(0.8), label: "Awake", minutes: stages.awakeMinutes,
            percent: percentage(stages.awakeMinutes))
        }
      }
    }
  }

  private func ratio(_ minutes: Int) -> CGFloat {
    guard stages.total > 0 else { return 0 }
    return CGFloat(minutes) / CGFloat(stages.total)
  }

  private func percentage(_ minutes: Int) -> Int {
    guard stages.total > 0 else { return 0 }
    return Int((Double(minutes) / Double(stages.total)) * 100)
  }
}

struct StageSegment: View {
  let color: Color
  let width: CGFloat

  var body: some View {
    Rectangle()
      .fill(color)
      .frame(width: width)
  }
}

struct StageLegendRow: View {
  let color: Color
  let label: String
  let minutes: Int
  let percent: Int

  var body: some View {
    HStack {
      Circle()
        .fill(color)
        .frame(width: 8, height: 8)

      Text(label)
        .font(.app(.bodySecondary))
        .foregroundStyle(DesignSystem.Colors.textSecondary)

      Spacer()

      Text("\(minutes)m")
        .font(.app(.bodySecondary))
        .foregroundStyle(DesignSystem.Colors.textPrimary)

      Text("(\(percent)%)")
        .font(.app(.caption))
        .foregroundStyle(DesignSystem.Colors.textSecondary)
        .frame(width: 40, alignment: .trailing)
    }
  }
}

// MARK: - Weekly Chart

struct WeeklySleepChart: View {
  let weekLogs: [DailyRecoveryLog]
  @State private var showAnimation = false

  var body: some View {
    EFCard {
      VStack(alignment: .leading, spacing: 16) {
        HStack {
          Text("Sleep This Week")
            .font(.app(.heading))
            .foregroundStyle(DesignSystem.Colors.textPrimary)
          Spacer()
          Text("Target: 7–9h")
            .font(.app(.caption))
            .foregroundStyle(DesignSystem.Colors.textSecondary)
        }

        HStack(alignment: .bottom, spacing: 8) {
          ForEach(Array(weekLogs.enumerated()), id: \.element.id) { index, log in
            VStack(spacing: 6) {
              let hours = Double(log.totalSleepMinutes) / 60.0
              let height = min(max(hours / 10.0 * 120, 10), 120)  // Scale to max 10h

              ZStack(alignment: .bottom) {
                Capsule()
                  .fill(DesignSystem.Colors.backgroundSecondary)
                  .frame(height: 120)
                  .frame(width: 8)

                Capsule()
                  .fill(hours >= 7 ? DesignSystem.Colors.accent : DesignSystem.Colors.neutral300)
                  .frame(height: showAnimation ? height : 0)
                  .frame(width: 8)
              }

              Text(weekday(from: log.date))
                .font(.app(.caption))
                .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .animation(
              .spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.05),
              value: showAnimation)
          }
        }
      }
    }
    .onAppear {
      showAnimation = true
    }
  }

  private func weekday(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "E"
    return String(formatter.string(from: date).prefix(1))
  }
}

// MARK: - Active Recovery Grid

struct ActiveRecoveryGrid: View {
  let completedActions: Set<RecoveryAction>
  let onToggle: (RecoveryAction) -> Void

  let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible()),
  ]

  var body: some View {
    LazyVGrid(columns: columns, spacing: 12) {
      ForEach(RecoveryAction.allCases) { action in
        HabitTile(
          action: action,
          isCompleted: completedActions.contains(action)
        ) {
          onToggle(action)
        }
      }
    }
  }
}

struct HabitTile: View {
  let action: RecoveryAction
  let isCompleted: Bool
  let onTap: () -> Void

  var body: some View {
    Button {
      onTap()
    } label: {
      VStack(spacing: 10) {
        ZStack {
          Circle()
            .fill(
              isCompleted ? DesignSystem.Colors.accent : DesignSystem.Colors.backgroundSecondary
            )
            .frame(width: 44, height: 44)

          Image(systemName: action.icon)
            .font(.system(size: 20))
            .foregroundStyle(isCompleted ? .white : DesignSystem.Colors.textSecondary)
        }

        Text(action.rawValue)
          .font(.app(.caption))
          .foregroundStyle(
            isCompleted ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textSecondary
          )
          .multilineTextAlignment(.center)
      }
      .frame(maxWidth: .infinity)
      .padding(.vertical, 16)
      .background(DesignSystem.Colors.cardBackground)
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(isCompleted ? DesignSystem.Colors.accent.opacity(0.5) : Color.clear, lineWidth: 1)
      )
    }
    .buttonStyle(.plain)
  }
}

// MARK: - Guidance Card

struct RecoveryGuidanceCard: View {
  let message: String

  var body: some View {
    EFCard {
      HStack(alignment: .top, spacing: 16) {
        Image(systemName: "quote.opening")
          .font(.app(.title))
          .foregroundStyle(DesignSystem.Colors.accent)

        VStack(alignment: .leading, spacing: 6) {
          Text("Coach's Insight")
            .font(.app(.heading))
            .foregroundStyle(DesignSystem.Colors.textPrimary)

          Text(message)
            .font(.app(.bodySecondary))
            .foregroundStyle(DesignSystem.Colors.textSecondary)
            .lineSpacing(4)
        }
      }
    }
  }
}
