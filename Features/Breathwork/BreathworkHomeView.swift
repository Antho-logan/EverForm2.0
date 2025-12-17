//
//  BreathworkHomeView.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import SwiftUI

struct BreathworkHomeView: View {
  @Environment(BreathworkStore.self) private var store
  @Environment(\.dismiss) private var dismiss

  @State private var selectedTab: BreathworkTab = .practice

  enum BreathworkTab: String, CaseIterable {
    case practice = "Practice"
    case programs = "Programs"
    case insights = "Insights"
  }

  var body: some View {
    ZStack(alignment: .top) {
      EverFormTheme.Colors.appBackground.ignoresSafeArea()

      VStack(spacing: 0) {
        // Header
        VStack(alignment: .leading, spacing: 16) {
          HStack {
            Button {
              dismiss()
            } label: {
              HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                  .font(.system(size: 17, weight: .semibold))
                Text("Back")
                  .font(EverFormTheme.Typography.body)
              }
              .foregroundStyle(EverFormTheme.Colors.primaryBlue)
            }
            Spacer()
            
            Text("Breathwork")
              .font(EverFormTheme.Typography.screenTitle)
              .foregroundStyle(EverFormTheme.Colors.textPrimary)
            
            Spacer()
            
            // Hidden button for balance
            Button {
            } label: {
              HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                Text("Back")
              }
            }
            .hidden()
          }
          .padding(.horizontal, 20)
          .padding(.top, 10)

          // Custom Segmented Control
          HStack(spacing: 0) {
            ForEach(BreathworkTab.allCases, id: \.self) { tab in
              Button {
                withAnimation(.spring(response: 0.3)) {
                  selectedTab = tab
                }
              } label: {
                VStack(spacing: 8) {
                  Text(tab.rawValue)
                    .font(EverFormTheme.Typography.label)
                    .foregroundStyle(
                      selectedTab == tab
                        ? EverFormTheme.Colors.textPrimary : EverFormTheme.Colors.textSecondary
                    )
                    .fontWeight(selectedTab == tab ? .semibold : .regular)

                  Rectangle()
                    .fill(selectedTab == tab ? EverFormTheme.Colors.primaryBlue : Color.clear)
                    .frame(height: 2)
                }
              }
              .frame(maxWidth: .infinity)
            }
          }
          .padding(.horizontal, 20)
        }
        .background(EverFormTheme.Colors.appBackground.opacity(0.95))

        // Content
        TabView(selection: $selectedTab) {
          BreathworkPracticeView()
            .tag(BreathworkTab.practice)

          BreathworkProgramsView()
            .tag(BreathworkTab.programs)

          BreathworkInsightsView()
            .tag(BreathworkTab.insights)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
      }
    }
    .navigationBarBackButtonHidden(true)
    .task {
      // Ensure patterns are loaded (from backend or fallback to local)
      if !store.patternsLoaded {
        await store.loadPatternsFromBackend()
      }
      // Retry any pending syncs
      await store.retryPendingSyncs()
    }
  }
}
