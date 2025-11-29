//
//  TrainingStartView.swift
//  EverForm
//
//  Created by Gemini on 18/11/2025.
//  Updated by Assistant on 21/11/2025.
//
//

import SwiftUI

struct TrainingStartView: View {
  @StateObject private var viewModel = TrainingViewModel()
  @State private var showingSchedule = false

  // Navigation / Presentation
  @Environment(\.dismiss) private var dismiss

  enum TrainingViewMode: String, CaseIterable {
    case today = "Today"
    case week = "Week"
  }

  var body: some View {
    EFScreenContainer {
      ZStack(alignment: .top) {
        // Main Content
        ScrollView {
          VStack(alignment: .leading, spacing: 24) {

            // Header
            VStack(alignment: .leading, spacing: 16) {
              HStack(alignment: .top) {
                Spacer()
                Button {
                  dismiss()
                } label: {
                  Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(DesignSystem.Colors.neutral400)
                }
                .padding(.trailing, 20)
                .padding(.top, 6)
              }
              
              FeatureHeroCard(
                title: "Training",
                subtitle: "Follow your plan and stay on track with today’s workout.",
                buttonTitle: "Go to Workout Schedule",
                onButtonTap: { showingSchedule = true },
                gradientColors: [Color.green.opacity(0.6), Color.green.opacity(0.3)]
              )
              .padding(.horizontal, 20)
            }

            // Recent Sessions
            FeatureHistorySection(title: "Recent Sessions") {
                VStack(spacing: 12) {
                    FeatureHistoryRow(
                        title: "Upper Body Power",
                        subtitle: "Yesterday • 45 min",
                        detail: "Completed",
                        icon: "dumbbell.fill",
                        iconColor: .green
                    ) { /* Action */ }
                    
                    FeatureHistoryRow(
                        title: "Active Recovery",
                        subtitle: "2 days ago • 20 min",
                        detail: "Completed",
                        icon: "figure.walk",
                        iconColor: .blue
                    ) { /* Action */ }
                }
            }
            .padding(.bottom, 20)

            Spacer(minLength: 100)
          }
          .padding(.bottom, 40)
        }
      }
    }
    .navigationDestination(isPresented: $showingSchedule) {
        TrainingScheduleView(viewModel: viewModel)
    }
  }
}

// MARK: - Subviews

struct TrainingHeroCard: View {
  let day: TrainingDay
  let onStart: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // Top Row
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 4) {
          Text(
            day.isToday
              ? "Today · \(day.date.formatted(.dateTime.day().weekday()))"
              : day.date.formatted(date: .complete, time: .omitted)
          )
          .font(EverFont.label)
          .foregroundColor(DesignSystem.Colors.textSecondary.opacity(0.8))
          .textCase(.uppercase)
        }

        Spacer()

        // Focus Pill
        Text(day.bodyFocus.rawValue)
          .font(EverFont.label)
          .fontWeight(.bold)
          .foregroundColor(day.isRestDay ? DesignSystem.Colors.success : DesignSystem.Colors.accent)
          .padding(.horizontal, 12)
          .padding(.vertical, 6)
          .background(
            Capsule()
              .fill(
                day.isRestDay
                  ? DesignSystem.Colors.success.opacity(0.1)
                  : DesignSystem.Colors.accent.opacity(0.1))
          )
      }
      .padding(.bottom, 16)

      // Main Title
      Text(day.focusTitle)
        .font(DesignSystem.Typography.displaySmall())
        .fontWeight(.bold)
        .foregroundColor(DesignSystem.Colors.textPrimary)
        .lineLimit(2)
        .padding(.bottom, 8)

      // Description / Meta
      if day.isRestDay {
        Text("Easy day. Focus on steps, stretching, or light mobility.")
          .font(EverFont.bodySecondary)
          .foregroundColor(DesignSystem.Colors.textSecondary)
          .padding(.bottom, 24)
      } else {
        HStack(spacing: 12) {
          Label("\(day.durationMinutes) min", systemImage: "clock")
          Text("•")
          Text(day.difficulty.rawValue)
          Text("•")
          Text(day.style.rawValue)
        }
        .font(EverFont.caption)
        .foregroundColor(DesignSystem.Colors.textSecondary)
        .padding(.bottom, 24)
      }

      Spacer()

      // CTA Button
      Button(action: onStart) {
        HStack {
          Text(day.isRestDay ? "Add Light Activity" : "Start Workout")
            .font(EverFont.button)
            .fontWeight(.semibold)

          Spacer()

          Image(systemName: "arrow.right")
            .font(.system(size: 16, weight: .semibold))
        }
        .padding()
        .background(DesignSystem.Colors.accent)
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
      }
    }
    .padding(24)
    .frame(height: 280)  // Fixed height for hero feel
    .background(
      ZStack {
        DesignSystem.Colors.cardBackground

        // Subtle gradient overlay
        LinearGradient(
          colors: [
            DesignSystem.Colors.accent.opacity(0.05),
            Color.clear,
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
      }
    )
    .clipShape(RoundedRectangle(cornerRadius: 24))  // Match Overview radius
    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
  }
}

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
      .padding(.horizontal, 20)  // Content padding inside scroll
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
          .font(EverFont.caption)
          .fontWeight(.semibold)
          .foregroundColor(isSelected ? .white : DesignSystem.Colors.textSecondary)

        // Dot or small indicator
        if day.isCompleted {
          Circle()
            .fill(isSelected ? .white : DesignSystem.Colors.success)
            .frame(width: 6, height: 6)
        } else {
          // Placeholder dot for planned
          Circle()
            .fill(isSelected ? .white.opacity(0.5) : DesignSystem.Colors.neutral300)
            .frame(width: 4, height: 4)
        }
      }
      .frame(width: 48, height: 64)
      .background(isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.cardBackground)
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(DesignSystem.Colors.border, lineWidth: isSelected ? 0 : 1)
      )
      .shadow(
        color: isSelected ? DesignSystem.Colors.accent.opacity(0.3) : Color.clear, radius: 8, x: 0,
        y: 4)
    }
    .buttonStyle(.plain)
  }
}

struct WeekListRow: View {
  let day: TrainingDay

  var body: some View {
    HStack(spacing: 16) {
      // Day badge
      VStack {
        Text(day.label)
          .font(EverFont.label)
          .foregroundStyle(DesignSystem.Colors.textSecondary)
        Text(day.date.formatted(.dateTime.day()))
          .font(EverFont.navTitle)
          .foregroundStyle(DesignSystem.Colors.textPrimary)
      }
      .frame(width: 50)

      VStack(alignment: .leading, spacing: 4) {
        Text(day.focusTitle)
          .font(EverFont.bodySecondary)
          .foregroundStyle(DesignSystem.Colors.textPrimary)

        HStack {
          Text(day.bodyFocus.rawValue)
            .font(EverFont.caption)
            .foregroundStyle(DesignSystem.Colors.accent)
          if !day.isRestDay {
            Text("• \(day.durationMinutes) min")
              .font(EverFont.caption)
              .foregroundStyle(DesignSystem.Colors.textSecondary)
          }
        }
      }

      Spacer()

      if day.isToday {
        Text("Today")
          .font(EverFont.label)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(DesignSystem.Colors.accent.opacity(0.1))
          .foregroundStyle(DesignSystem.Colors.accent)
          .clipShape(Capsule())
      }

      Image(systemName: "chevron.right")
        .font(EverFont.caption)
        .foregroundStyle(DesignSystem.Colors.neutral300)
    }
    .padding()
    .background(DesignSystem.Colors.cardBackground)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .overlay(
      RoundedRectangle(cornerRadius: 16)
        .stroke(DesignSystem.Colors.border, lineWidth: 1)
    )
  }
}

struct TodayPlanSummaryCard: View {
  let day: TrainingDay
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(alignment: .leading, spacing: 16) {
        HStack {
          Text("Today's Plan")
            .font(DesignSystem.Typography.titleMedium())
            .foregroundColor(DesignSystem.Colors.textPrimary)

          Spacer()

          Text("Generated")
            .font(EverFont.caption)
            .foregroundColor(DesignSystem.Colors.textTertiary)
        }

        // Sections
        VStack(spacing: 0) {
          ForEach(Array(day.sections.prefix(3).enumerated()), id: \.element.id) { index, section in
            PlanRow(
              title: section.title,
              subtitle: "\(section.exercises.count) exercises",
              icon: iconForSection(section.title)
            )

            if index < min(day.sections.count, 3) - 1 {
              Divider().padding(.leading, 40)
            }
          }
        }
      }
      .padding(20)
      .background(DesignSystem.Colors.cardBackground)
      .clipShape(RoundedRectangle(cornerRadius: 20))
      .overlay(
        RoundedRectangle(cornerRadius: 20)
          .stroke(DesignSystem.Colors.border, lineWidth: 1)
      )
    }
    .buttonStyle(.plain)
  }

  func iconForSection(_ title: String) -> String {
    switch title.lowercased() {
    case "warm-up": return "figure.flexibility"
    case "main set", "session": return "dumbbell.fill"
    case "finisher": return "flame.fill"
    case "routine": return "figure.yoga"
    default: return "list.bullet"
    }
  }
}

struct PlanRow: View {
  let title: String
  let subtitle: String
  let icon: String

  var body: some View {
    HStack(spacing: 16) {
      ZStack {
        Circle()
          .fill(DesignSystem.Colors.backgroundSecondary)
          .frame(width: 36, height: 36)

        Image(systemName: icon)
          .font(.system(size: 14))
          .foregroundColor(DesignSystem.Colors.textPrimary)
      }

      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(EverFont.bodySecondary)
          .fontWeight(.medium)
          .foregroundColor(DesignSystem.Colors.textPrimary)

        Text(subtitle)
          .font(EverFont.caption)
          .foregroundColor(DesignSystem.Colors.textSecondary)
      }

      Spacer()

      Image(systemName: "chevron.right")
        .font(EverFont.caption)
        .foregroundColor(DesignSystem.Colors.neutral300)
    }
    .padding(.vertical, 12)
  }
}
