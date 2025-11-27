//
//  MobilityDashboardView.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

import SwiftUI

struct MobilityDashboardView: View {
  @ObservedObject var store: MobilityStore
  @State private var showLevelSheet = false
  @State private var showAnimations = false

  var body: some View {
    VStack(spacing: 16) {
      HStack(spacing: 16) {
        // Tile A: Mobility Time
        DashboardTile(title: "Time this week", icon: "clock.fill") {
          VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
              Text("\(store.weeklyMinutes)")
                .font(DesignSystem.Typography.displaySmall())
                .foregroundStyle(DesignSystem.Colors.textPrimary)
              Text("min")
                .font(DesignSystem.Typography.bodyMedium())
                .foregroundStyle(DesignSystem.Colors.textSecondary)
            }

            GeometryReader { geo in
              ZStack(alignment: .leading) {
                Capsule()
                  .fill(DesignSystem.Colors.neutral200.opacity(0.3))

                Capsule()
                  .fill(DesignSystem.Colors.accent)
                  .frame(
                    width: showAnimations
                      ? min(
                        CGFloat(store.weeklyMinutes) / CGFloat(max(store.weeklyGoalMinutes, 1)), 1.0
                      ) * geo.size.width : 0)
              }
            }
            .frame(height: 8)

            Text("Goal: \(store.weeklyGoalMinutes) min")
              .font(DesignSystem.Typography.caption())
              .foregroundStyle(DesignSystem.Colors.textTertiary)
          }
        }

        // Tile B: Mobility Score
        DashboardTile(title: "Mobility Score", icon: "chart.bar.fill") {
          ZStack {
            Circle()
              .stroke(DesignSystem.Colors.neutral200.opacity(0.2), lineWidth: 8)

            Circle()
              .trim(
                from: 0, to: showAnimations ? Double(store.scoreSummary.overallScore) / 100.0 : 0
              )
              .stroke(
                store.scoreSummary.level.color,
                style: StrokeStyle(lineWidth: 8, lineCap: .round)
              )
              .rotationEffect(.degrees(-90))
              .animation(.spring(response: 1.2, dampingFraction: 0.8), value: showAnimations)

            VStack(spacing: 0) {
              Text("\(store.scoreSummary.overallScore)")
                .font(DesignSystem.Typography.titleLarge())
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
              Text(store.scoreSummary.level.rawValue)
                .font(DesignSystem.Typography.caption())
                .foregroundStyle(store.scoreSummary.level.color)
            }
          }
          .padding(8)
        }
        .onTapGesture {
          showLevelSheet = true
        }
      }
      .frame(height: 160)

      HStack(spacing: 16) {
        // Tile C: Focus
        DashboardTile(title: "Focus Areas", icon: "figure.flexibility") {
          VStack(alignment: .leading, spacing: 8) {
            Text("Hips & Thoracic")
              .font(DesignSystem.Typography.bodyLarge())
              .foregroundStyle(DesignSystem.Colors.textPrimary)

            HStack {
              TagChip(text: "Hips", color: .orange)
              TagChip(text: "Spine", color: .purple)
            }
          }
        }

        // Tile D: Last Session
        DashboardTile(title: "Last Session", icon: "checkmark.circle.fill") {
          VStack(alignment: .leading, spacing: 4) {
            Text("Daily Flow")
              .font(DesignSystem.Typography.bodyMedium())
              .foregroundStyle(DesignSystem.Colors.textPrimary)
            Text("Yesterday • 12 min")
              .font(DesignSystem.Typography.caption())
              .foregroundStyle(DesignSystem.Colors.textSecondary)
          }
        }
      }
      .frame(height: 140)

      NavigationLink(destination: MobilityTestsOverviewView(store: store)) {
        HStack {
          Text("Test your mobility")
            .font(DesignSystem.Typography.buttonLarge())
          Spacer()
          Image(systemName: "arrow.right")
        }
        .padding()
        .background(DesignSystem.Colors.accent)
        .foregroundColor(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
      }
    }
    .sheet(isPresented: $showLevelSheet) {
      MobilityLevelSheet(scoreSummary: store.scoreSummary, sport: store.primarySport)
    }
    .onAppear {
      withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
        showAnimations = true
      }
    }
  }
}

struct DashboardTile<Content: View>: View {
  let title: String
  let icon: String
  let content: () -> Content

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack {
        Image(systemName: icon)
          .font(.system(size: 14))
          .foregroundStyle(DesignSystem.Colors.accent)
        Text(title)
          .font(DesignSystem.Typography.labelMedium())
          .foregroundStyle(DesignSystem.Colors.textSecondary)
          .textCase(.uppercase)
        Spacer()
      }

      content()
      Spacer(minLength: 0)
    }
    .padding(16)
    .background(DesignSystem.Colors.cardBackground)
    .clipShape(RoundedRectangle(cornerRadius: 16))
  }
}

struct TagChip: View {
  let text: String
  let color: Color

  var body: some View {
    Text(text)
      .font(DesignSystem.Typography.labelSmall())
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(color.opacity(0.2))
      .foregroundStyle(color)
      .clipShape(Capsule())
  }
}
