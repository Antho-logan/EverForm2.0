//
//  NutritionDashboardView.swift
//  EverForm
//
//  Created by Assistant on 27/11/2025.
//

import SwiftUI

struct NutritionDashboardView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var selectedTab: NutritionOverviewView.NutritionTab = .overview
  @State private var showingQuickActions = false
  
  @ObservedObject var overviewModel: NutritionOverviewViewModel
  @ObservedObject var diaryModel: NutritionDiaryViewModel
  @ObservedObject var reportModel: NutritionReportViewModel
  @ObservedObject var toolsModel: NutritionFoodToolsViewModel

  var body: some View {
    EFScreenContainer {
      VStack(spacing: 0) {
        navigationHeader
        
        tabSelector
        
        TabView(selection: $selectedTab) {
          NutritionOverviewDashboardView(
            viewModel: overviewModel,
            reportSummary: reportModel.summary,
            onOpenQuickActions: { showingQuickActions = true }
          )
          .tag(NutritionOverviewView.NutritionTab.overview)

          NutritionDiaryTabView(
            viewModel: diaryModel,
            onOpenQuickAdd: { showingQuickActions = true }
          )
          .tag(NutritionOverviewView.NutritionTab.diary)

          NutritionReportView(
            viewModel: reportModel,
            weeklySummaries: overviewModel.weekSummaries
          )
          .tag(NutritionOverviewView.NutritionTab.report)

          NutritionFoodToolsView(viewModel: toolsModel)
            .tag(NutritionOverviewView.NutritionTab.tools)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
      }
    }
    .navigationBarHidden(true)
    .sheet(isPresented: $showingQuickActions) {
        NutritionQuickActionsSheet {
          showingQuickActions = false
        }
    }
  }
  
  private var navigationHeader: some View {
    HStack {
        Button {
            dismiss()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                Text("Back")
                    .font(.app(.body))
            }
            .foregroundStyle(DesignSystem.Colors.accent)
        }
        
        Spacer()
        
        Text("Nutrition Dashboard")
            .font(.app(.heading))
            .foregroundStyle(DesignSystem.Colors.textPrimary)
            
        Spacer()
        
        // Hidden button to balance the layout center title
        Button { } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                Text("Back")
            }
        }
        .hidden()
    }
    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
    .padding(.vertical, 12)
    .background(DesignSystem.Colors.background)
  }
  
  private var tabSelector: some View {
    HStack(spacing: 0) {
      ForEach(NutritionOverviewView.NutritionTab.allCases) { tab in
        Button {
          withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
            selectedTab = tab
          }
        } label: {
          VStack(spacing: 6) {
            Text(tab.rawValue)
              .font(.app(selectedTab == tab ? .button : .bodySecondary))
              .foregroundStyle(
                selectedTab == tab
                  ? DesignSystem.Colors.accent : DesignSystem.Colors.textSecondary)

            Rectangle()
              .fill(selectedTab == tab ? DesignSystem.Colors.accent : Color.clear)
              .frame(height: 2)
          }
        }
        .frame(maxWidth: .infinity)
      }
    }
    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
    .padding(.vertical, 8)
    .background(DesignSystem.Colors.backgroundSecondary)
  }
}