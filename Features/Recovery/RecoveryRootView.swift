//
//  RecoveryRootView.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

import SwiftUI

struct RecoveryHomeView: View {
  @StateObject private var viewModel = RecoveryDashboardViewModel()
  @Environment(\.dismiss) private var dismiss
  @State private var showingFullDashboard = false

  var body: some View {
    // No NavigationStack here - pushed from Overview
    EFScreenContainer {
        ScrollView {
          VStack(spacing: 24) {
            
            // Header
            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(DesignSystem.Colors.neutral400)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                FeatureHeroCard(
                    title: "Recovery",
                    subtitle: "Wind down, improve sleep, and support recovery.",
                    buttonTitle: "Open Recovery Plan",
                    onButtonTap: { showingFullDashboard = true },
                    gradientColors: [Color.blue.opacity(0.6), Color.blue.opacity(0.3)]
                )
                .padding(.horizontal, 20)
            }

            // Recent Recovery
            FeatureHistorySection(title: "Recent Recovery") {
                VStack(spacing: 12) {
                    FeatureHistoryRow(
                        title: "Wind Down",
                        subtitle: "Yesterday • Completed",
                        detail: "95%",
                        icon: "moon.stars.fill",
                        iconColor: .blue
                    ) { /* Action */ }
                }
            }

            Spacer(minLength: 40)
          }
          .padding(.top, 16)
        }
    }
    .navigationDestination(isPresented: $showingFullDashboard) {
        RecoveryDashboardView(viewModel: viewModel)
    }
    .navigationTitle("Recovery")
    .navigationBarTitleDisplayMode(.large)
  }
}

