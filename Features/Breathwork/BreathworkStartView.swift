//
//  BreathworkStartView.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import SwiftUI

struct BreathworkStartView: View {
  @State private var store = BreathworkStore()
  @Environment(\.dismiss) private var dismiss
  @State private var showingFullExperience = false

  var body: some View {
    // No NavigationStack needed here as OverviewRootView pushes this view
    EFScreenContainer {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          // Header
          VStack(spacing: 16) {
            HStack(alignment: .top) {
              Spacer()
              Button {
                dismiss()
              } label: {
                Image(systemName: "xmark.circle.fill")
                  .font(.title2)
                  .foregroundStyle(DesignSystem.Colors.neutral400)
              }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            FeatureHeroCard(
              title: "Breathwork",
              subtitle: "Calm your nervous system with guided breathing.",
              buttonTitle: "Open Breathwork",
              onButtonTap: { showingFullExperience = true },
              gradientColors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.3)]
            )
            .padding(.horizontal, 20)
          }

          // Recent Sessions
          FeatureHistorySection(title: "Recent Sessions") {
            if store.isLoadingSessions {
              HStack {
                ProgressView()
                  .scaleEffect(0.8)
                Text("Loading sessions...")
                  .font(DesignSystem.Typography.bodyMedium())
                  .foregroundStyle(DesignSystem.Colors.textSecondary)
              }
              .padding(.vertical, 8)
            } else if store.recentSessions.isEmpty {
              Text("No sessions yet. Start your first breathwork session to see it here.")
                .font(DesignSystem.Typography.bodyMedium())
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .padding(.vertical, 8)
            } else {
              VStack(spacing: 12) {
                ForEach(store.recentSessions) { session in
                  FeatureHistoryRow(
                    title: session.patternName,
                    subtitle: formatSessionDate(session.date),
                    detail: "\(session.durationMinutes) min",
                    icon: "wind",
                    iconColor: .blue
                  ) {
                    // Tapping a recent session opens full dashboard
                    showingFullExperience = true
                  }
                }
              }
            }
          }

          Spacer(minLength: 40)
        }
      }
    }
    .navigationDestination(isPresented: $showingFullExperience) {
      BreathworkHomeView()
        .environment(store)
    }
    .navigationBarBackButtonHidden(true)
    .task {
      // Load patterns and sessions from backend on appear
      await store.loadPatternsFromBackend()
      await store.loadRecentSessionsFromBackend()
    }
  }

  private func formatSessionDate(_ date: Date) -> String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    return formatter.localizedString(for: date, relativeTo: Date())
  }
}
