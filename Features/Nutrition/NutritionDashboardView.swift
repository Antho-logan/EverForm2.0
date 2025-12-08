//
//  NutritionDashboardView.swift
//  EverForm
//
//  Created by Assistant on 27/11/2025.
//

import SwiftUI

struct NutritionDashboardView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(ThemeManager.self) private var themeManager
  
  @State private var selectedTab: NutritionOverviewView.NutritionTab = .overview
  @State private var showingQuickActions = false
  @Namespace private var tabNamespace
  
  @ObservedObject var overviewModel: NutritionOverviewViewModel
  @ObservedObject var diaryModel: NutritionDiaryViewModel
  @ObservedObject var reportModel: NutritionReportViewModel
  @ObservedObject var toolsModel: NutritionFoodToolsViewModel

  var body: some View {
    EFScreenContainer {
      VStack(spacing: 0) {
        // Header
        EFHeader(title: "Nutrition Dashboard", showBack: true)
        
        // Custom Tab Strip
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 24) {
            ForEach(NutritionOverviewView.NutritionTab.allCases) { tab in
              Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                  selectedTab = tab
                }
              } label: {
                VStack(spacing: 6) {
                  Text(tab.rawValue)
                    .font(.system(size: 15, weight: selectedTab == tab ? .semibold : .medium))
                    .foregroundStyle(selectedTab == tab ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textSecondary)
                  
                  ZStack {
                    if selectedTab == tab {
                      Capsule()
                        .fill(DesignSystem.Colors.accent) // Blue accent
                        .frame(height: 3)
                        .matchedGeometryEffect(id: "tab_indicator", in: tabNamespace)
                    } else {
                      Capsule()
                        .fill(Color.clear)
                        .frame(height: 3)
                    }
                  }
                }
                .fixedSize()
              }
            }
          }
          .padding(.horizontal, 20)
          .padding(.top, 4)
          .padding(.bottom, 12)
        }
        
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
}
