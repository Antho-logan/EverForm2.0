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

  var body: some View {
    EFScreenContainer {
        ScrollView {
          VStack(alignment: .leading, spacing: EverFormTheme.Spacing.sectionSpacing) {

            // Header
            EFHeader(title: "Training", showBack: true) {
                dismiss()
            }

            // Hero Card
            TrainingHero(onTap: { showingSchedule = true })
              .padding(.horizontal, EverFormTheme.Spacing.screenPadding)

            // Recent Sessions
            VStack(spacing: 16) {
              EFSectionHeader(title: "Recent Sessions")
              
              VStack(spacing: 12) {
                RecentSessionRow(
                  title: "Upper Body Power",
                  subtitle: "Yesterday • 45 min",
                  detail: "Completed",
                  icon: "dumbbell.fill",
                  iconColor: EverFormTheme.Colors.trainingGreen
                )

                RecentSessionRow(
                  title: "Active Recovery",
                  subtitle: "2 days ago • 20 min",
                  detail: "Completed",
                  icon: "figure.walk",
                  iconColor: EverFormTheme.Colors.recoveryBlue
                )
              }
            }
            .padding(.horizontal, EverFormTheme.Spacing.screenPadding)
            .padding(.bottom, 20)

            Spacer(minLength: 100)
          }
          .padding(.bottom, 40)
        }
    }
    .navigationDestination(isPresented: $showingSchedule) {
      TrainingScheduleView(viewModel: viewModel)
    }
  }
}

// MARK: - Subviews

struct TrainingHero: View {
    var onTap: () -> Void
    
    var body: some View {
        EFCard(style: .gradient(EverFormTheme.Colors.gradient(for: EverFormTheme.Colors.trainingGreen))) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Good morning")
                    .font(EverFormTheme.Typography.caption)
                    .foregroundStyle(.white.opacity(0.8))
                
                Text("Training")
                    .font(EverFormTheme.Typography.screenTitle)
                    .foregroundStyle(.white)
                
                Text("Follow your plan and stay on track.")
                    .font(EverFormTheme.Typography.body)
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.top, 4)
                
                Spacer()
                
                Button(action: onTap) {
                    HStack {
                        Text("Go to Workout Schedule")
                            .font(EverFormTheme.Typography.button)
                            .foregroundStyle(EverFormTheme.Colors.trainingGreen)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(EverFormTheme.Colors.trainingGreen)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .frame(height: 180)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct RecentSessionRow: View {
    let title: String
    let subtitle: String
    let detail: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        EFCard {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(iconColor)
                    .frame(width: 40, height: 40)
                    .background(iconColor.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(EverFormTheme.Typography.cardTitle)
                        .foregroundStyle(EverFormTheme.Colors.textPrimary)
                    
                    Text(subtitle)
                        .font(EverFormTheme.Typography.caption)
                        .foregroundStyle(EverFormTheme.Colors.textSecondary)
                }
                
                Spacer()
                
                Text(detail)
                    .font(EverFormTheme.Typography.caption)
                    .foregroundStyle(EverFormTheme.Colors.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(EverFormTheme.Colors.surface)
                    .clipShape(Capsule())
            }
        }
    }
}
