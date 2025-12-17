//
//  FixPainRootView.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import SwiftUI

struct FixPainView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel = FixPainViewModel()
  @State private var showAssessment = false

  var body: some View {
    // No NavigationStack here - pushed from Overview
    EFScreenContainer {
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {

          // Header
          VStack(spacing: 16) {
            HStack(alignment: .top) {
              Button {
                dismiss()
              } label: {
                Image(systemName: "chevron.down")
                  .font(.system(size: 18, weight: .semibold))
                  .foregroundStyle(DesignSystem.Colors.textSecondary)
                  .padding(10)
                  .background(DesignSystem.Colors.cardBackground)
                  .clipShape(Circle())
                  .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
              }
              Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            FeatureHeroCard(
              title: "Fix Pain",
              subtitle: "Identify your issue and get a personalized recovery plan in minutes.",
              buttonTitle: "Start Assessment",
              onButtonTap: {
                viewModel.startNewAssessment()
                showAssessment = true
              },
              gradientColors: [
                Color.blue.opacity(0.55),
                Color.purple.opacity(0.5),
              ]
            )
            .padding(.horizontal, 20)
          }

          // Recent Section
          if !viewModel.recentAssessments.isEmpty {
            FeatureHistorySection(title: "Recent Checks") {
              VStack(spacing: 12) {
                ForEach(viewModel.recentAssessments) { assessment in
                  RecentAssessmentRow(assessment: assessment)
                }
              }
            }
          } else {
            // Placeholder or Education
            VStack(alignment: .leading, spacing: 16) {
              Text("Common Issues")
                .sectionTitle()

              ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                  CommonIssueCard(title: "Knee Pain", icon: "figure.walk")
                  CommonIssueCard(title: "Lower Back", icon: "figure.core.training")
                  CommonIssueCard(title: "Shoulder", icon: "figure.cooldown")
                }
              }
            }
            .padding(.horizontal, 20)
          }

          Spacer(minLength: 40)
        }
      }
      // Background handled by EFScreenContainer
      .fullScreenCover(isPresented: $showAssessment) {
        FixPainAssessmentFlowView(viewModel: viewModel, isPresented: $showAssessment)
      }
    }
  }
}

struct RecentAssessmentRow: View {
  let assessment: FixPainAssessment

  var body: some View {
    HStack(spacing: 16) {
      ZStack {
        Circle()
          .fill(EverFormTheme.Colors.surface)
          .frame(width: 48, height: 48)

        Image(systemName: "cross.case.fill")
          .foregroundStyle(EverFormTheme.Colors.fixPainIndigo)
          .font(.system(size: 20))
      }

      VStack(alignment: .leading, spacing: 4) {
        Text(assessment.region?.rawValue ?? "Unknown Region")
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(EverFormTheme.Colors.textPrimary)

        Text(assessment.createdAt.formatted(date: .abbreviated, time: .omitted))
          .font(.caption)
          .foregroundStyle(EverFormTheme.Colors.textSecondary)
      }

      Spacer()

      Image(systemName: "chevron.right")
        .font(.caption)
        .foregroundStyle(EverFormTheme.Colors.textSecondary)
    }
    .padding()
    .cardStyle()
  }
}

struct CommonIssueCard: View {
  let title: String
  let icon: String

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      Image(systemName: icon)
        .font(.title)
        .foregroundStyle(EverFormTheme.Colors.fixPainIndigo)
        .frame(width: 40, height: 40)
        .background(EverFormTheme.Colors.surface)
        .clipShape(Circle())

      Text(title)
        .font(.system(size: 15, weight: .semibold))
        .foregroundStyle(EverFormTheme.Colors.textPrimary)
    }
    .padding(16)
    .frame(width: 120, height: 120)
    .cardStyle()
  }
}
