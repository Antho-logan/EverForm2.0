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
          VStack(alignment: .leading, spacing: 24) {

            // Header
            EFHeader(title: "Training", showBack: true) {
                dismiss()
            }

            // Hero Card (Refactored to remove "green wall" look)
            Button {
                showingSchedule = true
            } label: {
                EverFormCard {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Schedule")
                                .font(EverFormTheme.Typography.label)
                                .foregroundStyle(EverFormTheme.Colors.textSecondary)
                            
                            Text("Keep the momentum")
                                .font(EverFormTheme.Typography.cardTitle)
                                .foregroundStyle(EverFormTheme.Colors.textPrimary)
                            
                            Text("Next: Upper Body Power")
                                .font(EverFormTheme.Typography.body)
                                .foregroundStyle(EverFormTheme.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "calendar")
                            .font(.system(size: 24))
                            .foregroundStyle(EverFormTheme.Colors.trainingGreen)
                            .padding(12)
                            .background(EverFormTheme.Colors.trainingGreen.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)

            // Recent Sessions
            VStack(spacing: 16) {
              Text("Recent Sessions")
                  .sectionTitle()
                  .padding(.horizontal, 20)
              
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
              .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
          }
          // RootTabView provides bottom safe-area for the custom tab bar via `safeAreaInset`.
          // Avoid large spacer hacks that can make content feel clipped/zoomed.
          .padding(.bottom, 24)
        }
    }
    .navigationDestination(isPresented: $showingSchedule) {
      TrainingScheduleView(viewModel: viewModel)
    }
  }
}

// MARK: - Subviews

struct RecentSessionRow: View {
    let title: String
    let subtitle: String
    let detail: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        EverFormCard {
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
