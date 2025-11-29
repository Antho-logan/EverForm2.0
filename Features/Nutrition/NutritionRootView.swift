//
//  NutritionRootView.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

import SwiftUI

// MARK: - Main Container

struct NutritionOverviewView: View {
  @Environment(\.dismiss) private var dismiss

  @State private var showingQuickActions = false
  @State private var showingFullDashboard = false
  @State private var hasLoaded = false

  @StateObject private var overviewModel: NutritionOverviewViewModel
  @StateObject private var diaryModel: NutritionDiaryViewModel
  @StateObject private var reportModel: NutritionReportViewModel
  @StateObject private var toolsModel: NutritionFoodToolsViewModel

  init(provider: NutritionDataProvider = MockNutritionDataProvider()) {
    _overviewModel = StateObject(wrappedValue: NutritionOverviewViewModel(provider: provider))
    _diaryModel = StateObject(wrappedValue: NutritionDiaryViewModel(provider: provider))
    _reportModel = StateObject(wrappedValue: NutritionReportViewModel(provider: provider))
    _toolsModel = StateObject(wrappedValue: NutritionFoodToolsViewModel(provider: provider))
  }

  enum NutritionTab: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case diary = "Diary"
    case report = "Report"
    case tools = "Food Tools"

    var id: String { rawValue }
  }

  var body: some View {
    // No NavigationStack here - pushed from Overview
    EFScreenContainer {
        VStack(spacing: 0) {
          header

          // Landing Page Content
          ScrollView {
              VStack(spacing: 24) {
                  // Recent Meals
                  FeatureHistorySection(title: "Recent Meals") {
                      VStack(spacing: 12) {
                          FeatureHistoryRow(
                              title: "Breakfast",
                              subtitle: "Oatmeal & Berries",
                              detail: "450 kcal",
                              icon: "cup.and.saucer.fill",
                              iconColor: .orange
                          ) { /* Action */ }
                          
                          FeatureHistoryRow(
                              title: "Lunch",
                              subtitle: "Chicken Salad",
                              detail: "620 kcal",
                              icon: "fork.knife",
                              iconColor: .green
                          ) { /* Action */ }
                      }
                  }
              }
              .padding(.bottom, 32)
          }
        }
    }
    .navigationDestination(isPresented: $showingFullDashboard) {
        NutritionDashboardView(
            overviewModel: overviewModel,
            diaryModel: diaryModel,
            reportModel: reportModel,
            toolsModel: toolsModel
        )
    }
    .sheet(isPresented: $showingQuickActions) {
        NutritionQuickActionsSheet {
          showingQuickActions = false
        }
    }
    .task {
        guard !hasLoaded else { return }
        hasLoaded = true
        await overviewModel.load()
        await diaryModel.load(for: diaryModel.date)
        await reportModel.load()
        await toolsModel.loadSuggestions(for: nil)
    }
  }

  private var header: some View {
    VStack(spacing: 16) {
        HStack(alignment: .top) {
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(DesignSystem.Colors.neutral400)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
        .padding(.top, 16)
        
        FeatureHeroCard(
            title: "Nutrition",
            subtitle: "Log meals and track your macros for today.",
            buttonTitle: "Open Nutrition",
            onButtonTap: { showingFullDashboard = true },
            gradientColors: [Color.orange.opacity(0.6), Color.yellow.opacity(0.3)]
        )
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
    }
    .padding(.bottom, 12)
  }
}

// MARK: - Overview Tab

struct NutritionOverviewDashboardView: View {
  @ObservedObject var viewModel: NutritionOverviewViewModel
  let reportSummary: NutritionReportSummary
  let onOpenQuickActions: () -> Void

  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        MacroSummaryCard(profile: viewModel.profile, summary: viewModel.todaySummary)

        // NutritionActionsRow removed as "Log Meal" is now in Hero Card

        MacroTargetsCard(targets: reportSummary.macroTargets)

        TodayMealsSection(meals: viewModel.todaySummary.meals)

        GuidanceCard(message: viewModel.guidanceText)

        WeeklyCaloriesSparkline(week: viewModel.weekSummaries)
      }
      .padding(.bottom, 32)
      .padding(.horizontal, DesignSystem.Spacing.screenPadding)
    }
  }
}

struct MacroSummaryCard: View {
  let profile: UserNutritionProfile
  let summary: EFNutritionDaySummary

  var body: some View {
    EFCard(
      style: .gradient(
        LinearGradient(
          colors: [DesignSystem.Colors.accent, DesignSystem.Colors.accent.opacity(0.5)],
          startPoint: .topLeading,
          endPoint: .bottomTrailing)
      )
    ) {
      VStack(alignment: .leading, spacing: 16) {
        NutritionSectionHeader(
          title: "Today's Fuel",
          subtitle: "\(summary.caloriesConsumed) / \(profile.dailyCalorieTarget) kcal")

        HStack(spacing: 16) {
          CalorieRing(
            consumed: summary.caloriesConsumed, target: profile.dailyCalorieTarget
          )
          .frame(width: 110, height: 110)

          VStack(alignment: .leading, spacing: 12) {
            NutritionMacroPill(
              label: "Protein", value: summary.protein, target: profile.proteinTarget, color: .blue)
            NutritionMacroPill(
              label: "Carbs", value: summary.carbs, target: profile.carbsTarget, color: .green)
            NutritionMacroPill(
              label: "Fat", value: summary.fat, target: profile.fatTarget, color: .yellow)
          }
        }
      }
    }
  }
}

struct CalorieRing: View {
  let consumed: Int
  let target: Int

  @State private var animatedProgress: CGFloat = 0

  var progress: Double {
    guard target > 0 else { return 0 }
    return min(Double(consumed) / Double(target), 1.2)
  }

  var body: some View {
    ZStack {
      Circle()
        .stroke(Color.white.opacity(0.1), lineWidth: 12)

      Circle()
        .trim(from: 0, to: animatedProgress)
        .stroke(
          AngularGradient(
            gradient: Gradient(colors: [.white.opacity(0.8), .white, .white.opacity(0.8)]),
            center: .center
          ),
          style: StrokeStyle(lineWidth: 12, lineCap: .round)
        )
        .rotationEffect(.degrees(-90))
        .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 0)

      VStack(spacing: 2) {
        Text("\(consumed)")
          .font(.system(size: 28, weight: .bold, design: .rounded))
          .foregroundStyle(.white)
        Text("kcal")
          .font(.system(size: 12, weight: .medium))
          .foregroundStyle(.white.opacity(0.7))
      }
    }
    .onAppear {
      withAnimation(.spring(response: 1.2, dampingFraction: 0.8)) {
        animatedProgress = progress
      }
    }
    .onChange(of: consumed) { _, _ in
      withAnimation(.spring(response: 1.2, dampingFraction: 0.8)) {
        animatedProgress = progress
      }
    }
  }
}

struct NutritionMacroPill: View {
  let label: String
  let value: Int
  let target: Int
  let color: Color

  @State private var showProgress = false

  var progress: Double {
    guard target > 0 else { return 0 }
    return min(Double(value) / Double(target), 1.0)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack {
        Text(label)
          .font(.system(size: 14, weight: .medium))
        Spacer()
        Text("\(value)g / \(target)g")
          .font(.system(size: 12, weight: .medium))
          .opacity(0.8)
      }
      .foregroundStyle(.white)

      GeometryReader { geo in
        ZStack(alignment: .leading) {
          Capsule()
            .fill(.white.opacity(0.15))

          Capsule()
            .fill(color)
            .frame(width: showProgress ? geo.size.width * progress : 0)
            .shadow(color: color.opacity(0.5), radius: 4, x: 0, y: 2)
        }
      }
      .frame(height: 8)
    }
    .onAppear {
      withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.2)) {
        showProgress = true
      }
    }
  }
}

struct NutritionActionsRow: View {
  let onTap: () -> Void

  var body: some View {
    HStack(spacing: 12) {
      ForEach(NutritionQuickActionItem.sample) { item in
        Button {
          onTap()
        } label: {
          VStack(alignment: .leading, spacing: 8) {
            Image(systemName: item.icon)
              .font(.system(size: 18, weight: .semibold))
              .foregroundStyle(item.tint)
              .padding(10)
              .background(item.tint.opacity(0.1))
              .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text(item.title)
              .font(.app(.heading))
              .foregroundStyle(DesignSystem.Colors.textPrimary)

            Text(item.subtitle)
              .font(.app(.caption))
              .foregroundStyle(DesignSystem.Colors.textSecondary)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(14)
          .background(DesignSystem.Colors.cardBackground)
          .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
          .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
              .stroke(DesignSystem.Colors.border, lineWidth: 1)
          )
        }
      }
    }
  }
}

struct MacroTargetsCard: View {
  let targets: [NutrientTarget]

  var body: some View {
    EFCard {
      VStack(alignment: .leading, spacing: 14) {
        NutritionSectionHeader(title: "Macronutrient Targets", subtitle: "Daily progress")

        VStack(spacing: 12) {
          ForEach(targets) { target in
            NutrientProgressRow(target: target)
          }
        }
      }
    }
  }
}

struct NutrientProgressRow: View {
  let target: NutrientTarget
  @State private var showProgress = false

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack {
        Text(target.name)
          .font(.system(size: 15, weight: .medium))
          .foregroundStyle(DesignSystem.Colors.textPrimary)
        Spacer()
        Text(target.displayValue)
          .font(.system(size: 13, weight: .regular))
          .foregroundStyle(DesignSystem.Colors.textSecondary)
      }

      GeometryReader { geo in
        ZStack(alignment: .leading) {
          Capsule()
            .fill(DesignSystem.Colors.backgroundSecondary)

          Capsule()
            .fill(DesignSystem.Colors.accent)
            .frame(width: showProgress ? geo.size.width * target.progress : 0)
            .shadow(color: DesignSystem.Colors.accent.opacity(0.3), radius: 3, x: 0, y: 1)
        }
      }
      .frame(height: 8)
    }
    .onAppear {
      withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.1)) {
        showProgress = true
      }
    }
  }
}

struct TodayMealsSection: View {
  let meals: [EFMeal]

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      NutritionSectionHeader(title: "Today's Meals", subtitle: "Logged items")

      VStack(spacing: 10) {
        ForEach(meals) { meal in
          MealSummaryRow(meal: meal)
        }
      }
    }
  }
}

struct MealSummaryRow: View {
  let meal: EFMeal

  var body: some View {
    HStack(spacing: 16) {
      ZStack {
        Circle()
          .fill(DesignSystem.Colors.backgroundSecondary)
          .frame(width: 48, height: 48)
        Image(systemName: meal.type.icon)
          .font(.system(size: 20))
          .foregroundStyle(DesignSystem.Colors.accent)
      }

      VStack(alignment: .leading, spacing: 4) {
        Text(meal.type.rawValue)
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(DesignSystem.Colors.textPrimary)
        Text(meal.summaryText)
          .font(.caption)
          .foregroundStyle(DesignSystem.Colors.textSecondary)
      }

      Spacer()

      VStack(alignment: .trailing, spacing: 2) {
        Text("\(meal.totalCalories) kcal")
          .font(.system(size: 14, weight: .medium))
          .foregroundStyle(DesignSystem.Colors.textPrimary)
        Text("P\(meal.totalProtein) • C\(meal.totalCarbs) • F\(meal.totalFat)")
          .font(.caption)
          .foregroundStyle(DesignSystem.Colors.textSecondary)
      }
      
      Image(systemName: "chevron.right")
        .font(.caption)
        .foregroundStyle(DesignSystem.Colors.textSecondary)
    }
    .padding()
    .background(DesignSystem.Colors.cardBackground)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
  }
}

struct GuidanceCard: View {
  let message: String

  var body: some View {
    EFCard {
      HStack(alignment: .top, spacing: 12) {
        Image(systemName: "lightbulb.max")
          .font(.system(size: 22, weight: .semibold))
          .foregroundStyle(DesignSystem.Colors.warning)

        VStack(alignment: .leading, spacing: 6) {
          Text("Today's Guidance")
            .font(.app(.heading))
            .foregroundStyle(DesignSystem.Colors.textPrimary)

          Text(message)
            .font(.app(.bodySecondary))
            .foregroundStyle(DesignSystem.Colors.textSecondary)
            .lineSpacing(4)
        }
      }
    }
  }
}

struct WeeklyCaloriesSparkline: View {
  let week: [EFNutritionDaySummary]
  @State private var showBars = false

  var maxCalories: Double {
    guard let max = week.map({ Double($0.caloriesConsumed) }).max() else { return 1 }
    return max
  }

  var body: some View {
    EFCard {
      VStack(alignment: .leading, spacing: 16) {
        NutritionSectionHeader(title: "Weekly Snapshot", subtitle: "Calories per day")

        HStack(alignment: .bottom, spacing: 10) {
          ForEach(Array(week.enumerated()), id: \.element.id) { index, day in
            VStack(spacing: 8) {
              Capsule()
                .fill(DesignSystem.Colors.accent)
                .frame(
                  width: 12,
                  height: showBars
                    ? max(16, CGFloat(day.caloriesConsumed) / CGFloat(maxCalories) * 100) : 0
                )
                .shadow(color: DesignSystem.Colors.accent.opacity(0.3), radius: 4, x: 0, y: 2)

              Text(shortDate(day.date))
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .bottom)
            .animation(
              .spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.05),
              value: showBars)
          }
        }
        .frame(height: 130)
      }
    }
    .onAppear {
      showBars = true
    }
  }

  private func shortDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "E"
    return formatter.string(from: date)
  }
}

// MARK: - Diary Tab

struct NutritionDiaryTabView: View {
  @ObservedObject var viewModel: NutritionDiaryViewModel
  let onOpenQuickAdd: () -> Void

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        diaryHeader
        DiaryTotalsCard(totals: viewModel.totals)

        if viewModel.entries.isEmpty {
          EmptyDiaryPlaceholder(onOpenQuickAdd: onOpenQuickAdd)
        } else {
          VStack(spacing: 10) {
            ForEach(viewModel.entries) { entry in
              DiaryEntryRow(entry: entry)
            }
          }
        }
      }
      .padding(.horizontal, DesignSystem.Spacing.screenPadding)
      .padding(.bottom, 24)
    }
    .task(id: viewModel.date) {
      await viewModel.load(for: viewModel.date)
    }
  }

  private var diaryHeader: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text("Today's Diary")
          .font(.app(.title))
          .foregroundStyle(DesignSystem.Colors.textPrimary)
        Text(viewModel.formattedDate)
          .font(.app(.bodySecondary))
          .foregroundStyle(DesignSystem.Colors.textSecondary)
      }
      Spacer()
      HStack(spacing: 8) {
        Button {
          viewModel.changeDay(by: -1)
        } label: {
          Image(systemName: "chevron.left")
            .padding(8)
            .background(DesignSystem.Colors.cardBackground)
            .clipShape(Circle())
        }
        Button {
          viewModel.changeDay(by: 1)
        } label: {
          Image(systemName: "chevron.right")
            .padding(8)
            .background(DesignSystem.Colors.cardBackground)
            .clipShape(Circle())
        }
      }
      .foregroundStyle(DesignSystem.Colors.textPrimary)
    }
  }
}

struct DiaryTotalsCard: View {
  let totals: NutritionValues

  var body: some View {
    EFCard {
      VStack(alignment: .leading, spacing: 12) {
        NutritionSectionHeader(title: "Totals vs Goal", subtitle: "Logged today")

        HStack(spacing: 8) {
          TotalsPill(
            title: "Calories", value: "\(totals.kcal)", color: DesignSystem.Colors.accent)
          TotalsPill(title: "Protein", value: "\(Int(totals.protein))g", color: .blue)
          TotalsPill(title: "Carbs", value: "\(Int(totals.carbs))g", color: .green)
          TotalsPill(title: "Fat", value: "\(Int(totals.fat))g", color: .yellow)
        }
      }
    }
  }
}

struct TotalsPill: View {
  let title: String
  let value: String
  let color: Color

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .font(.app(.caption))
        .foregroundStyle(DesignSystem.Colors.textSecondary)
      Text(value)
        .font(.app(.heading))
        .foregroundStyle(DesignSystem.Colors.textPrimary)
    }
    .padding(10)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(color.opacity(0.1))
    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
  }
}

struct DiaryEntryRow: View {
  let entry: MealEntry

  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      ZStack {
        Circle()
          .fill(DesignSystem.Colors.backgroundSecondary)
          .frame(width: 48, height: 48)
        Image(systemName: entry.source.iconName)
          .font(.system(size: 20))
          .foregroundStyle(DesignSystem.Colors.accent)
      }

      VStack(alignment: .leading, spacing: 4) {
        HStack {
          Text(entry.itemRef.displayName)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(DesignSystem.Colors.textPrimary)
          Spacer()
          Text(entry.formattedTime)
            .font(.caption)
            .foregroundStyle(DesignSystem.Colors.textSecondary)
        }

        Text("\(entry.formattedQuantity) • \(entry.kcal) kcal")
          .font(.caption)
          .foregroundStyle(DesignSystem.Colors.textSecondary)

        Text("P \(Int(entry.protein))g • C \(Int(entry.carbs))g • F \(Int(entry.fat))g")
          .font(.caption)
          .foregroundStyle(DesignSystem.Colors.textSecondary)
      }
    }
    .padding()
    .background(DesignSystem.Colors.cardBackground)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
  }
}

struct EmptyDiaryPlaceholder: View {
  let onOpenQuickAdd: () -> Void

  var body: some View {
    VStack(spacing: 12) {
      Text("No meals logged yet")
        .font(.app(.title))
        .foregroundStyle(DesignSystem.Colors.textPrimary)
      Text("Add your first meal to start tracking today.")
        .font(.app(.bodySecondary))
        .foregroundStyle(DesignSystem.Colors.textSecondary)
      Button("Quick add") {
        onOpenQuickAdd()
      }
      .font(.app(.button))
      .padding(.horizontal, 18)
      .padding(.vertical, 10)
      .background(DesignSystem.Colors.accent)
      .foregroundStyle(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    .frame(maxWidth: .infinity)
    .padding(20)
    .background(DesignSystem.Colors.cardBackground)
    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
  }
}

// MARK: - Report Tab

struct NutritionReportView: View {
  @ObservedObject var viewModel: NutritionReportViewModel
  let weeklySummaries: [EFNutritionDaySummary]

  var body: some View {
    ScrollView {
      LazyVStack(spacing: 18) {
        MacroTargetsCard(targets: viewModel.summary.macroTargets)
          .transition(.opacity.combined(with: .move(edge: .bottom)))

        HighlightedNutrientsGrid(targets: viewModel.summary.highlightedTargets)
          .transition(.opacity.combined(with: .move(edge: .bottom)))

        NutrientGroupsSection(groups: viewModel.summary.nutrientGroups)

        BiohackingMetricsRow(scores: viewModel.summary.biohackingScores)
          .padding(.horizontal, 2)

        WeeklyAverageCard(week: weeklySummaries)
      }
      .padding(.horizontal, DesignSystem.Spacing.screenPadding)
      .padding(.bottom, 28)
      .animation(
        .spring(response: 0.6, dampingFraction: 0.8), value: viewModel.summary.macroTargets.isEmpty)
    }
    .task {
      await viewModel.load()
    }
  }
}

struct HighlightedNutrientsGrid: View {
  let targets: [NutrientTarget]

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      NutritionSectionHeader(title: "Key Micronutrients", subtitle: "Focus areas")
      LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
        ForEach(targets) { target in
          EFCard {
            VStack(alignment: .leading, spacing: 10) {
              Text(target.name)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(DesignSystem.Colors.textPrimary)

              Text(target.displayValue)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(DesignSystem.Colors.textSecondary)

              CustomProgressBar(value: target.progress, color: DesignSystem.Colors.accent)
            }
          }
        }
      }
    }
  }
}

struct CustomProgressBar: View {
  let value: Double
  let color: Color
  @State private var showProgress = false

  var body: some View {
    GeometryReader { geo in
      ZStack(alignment: .leading) {
        Capsule()
          .fill(DesignSystem.Colors.backgroundSecondary)

        Capsule()
          .fill(color)
          .frame(width: showProgress ? geo.size.width * min(value, 1.0) : 0)
          .shadow(color: color.opacity(0.4), radius: 3, x: 0, y: 1)
      }
    }
    .frame(height: 6)
    .onAppear {
      withAnimation(.spring(response: 1.0, dampingFraction: 0.8).delay(0.2)) {
        showProgress = true
      }
    }
  }
}

struct NutrientGroupsSection: View {
  let groups: [NutrientGroup]

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      NutritionSectionHeader(title: "Micronutrient Coverage", subtitle: "Grouped by system")

      ForEach(Array(groups.enumerated()), id: \.element.id) { index, group in
        EFCard {
          VStack(alignment: .leading, spacing: 10) {
            Text(group.title)
              .font(.app(.heading))
              .foregroundStyle(DesignSystem.Colors.textPrimary)

            ForEach(group.nutrients) { nutrient in
              NutrientProgressRow(target: nutrient)
            }
          }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .animation(
          .spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1),
          value: groups.isEmpty)
      }
    }
  }
}

struct WeeklyAverageCard: View {
  let week: [EFNutritionDaySummary]

  private var average: (kcal: Int, protein: Int, carbs: Int, fat: Int) {
    guard !week.isEmpty else { return (0, 0, 0, 0) }
    let totalCalories = week.map(\.caloriesConsumed).reduce(0, +)
    let totalProtein = week.map(\.protein).reduce(0, +)
    let totalCarbs = week.map(\.carbs).reduce(0, +)
    let totalFat = week.map(\.fat).reduce(0, +)
    let count = week.count
    return (totalCalories / count, totalProtein / count, totalCarbs / count, totalFat / count)
  }

  var body: some View {
    EFCard {
      VStack(alignment: .leading, spacing: 12) {
        NutritionSectionHeader(title: "Weekly Averages", subtitle: "Per day")

        HStack(spacing: 12) {
          TotalsPill(
            title: "Calories", value: "\(average.kcal) kcal", color: DesignSystem.Colors.accent)
          TotalsPill(title: "Protein", value: "\(average.protein) g", color: .blue)
          TotalsPill(title: "Carbs", value: "\(average.carbs) g", color: .green)
          TotalsPill(title: "Fat", value: "\(average.fat) g", color: .yellow)
        }
      }
    }
  }
}

// MARK: - Food Tools Tab

struct NutritionFoodToolsView: View {
  @ObservedObject var viewModel: NutritionFoodToolsViewModel

  var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        NutritionSectionHeader(title: "Food Tools", subtitle: "Meals, recipes, and discovery")

        NavigationLink {
          CustomMealsListView(meals: viewModel.customMeals)
        } label: {
          CardRow(
            title: "Custom Meals",
            subtitle: "Combine your favourite foods into one meal for faster logging.",
            icon: "fork.knife"
          )
        }

        NavigationLink {
          CustomRecipesView()
        } label: {
          CardRow(
            title: "Custom Recipes",
            subtitle: "Create or import recipes to reuse later.",
            icon: "book.pages"
          )
        }

        NavigationLink {
          CustomFoodsFormView()
        } label: {
          CardRow(
            title: "Custom Foods",
            subtitle: "Build a food with serving sizes and key nutrients.",
            icon: "leaf.fill"
          )
        }

        NavigationLink {
          RepeatItemsView(items: viewModel.repeatItems)
        } label: {
          CardRow(
            title: "Repeat Items",
            subtitle: "Schedule frequent foods or meals.",
            icon: "arrow.triangle.2.circlepath"
          )
        }

        NavigationLink {
          NutritionSuggestionsView(groups: viewModel.suggestionGroups) {
            Task { await viewModel.loadSuggestions(for: nil) }
          }
        } label: {
          CardRow(
            title: "Suggest Food",
            subtitle: "Hand-picked options by target.",
            icon: "wand.and.stars"
          )
        }

        NavigationLink {
          OracleNutrientSearchView(viewModel: viewModel)
        } label: {
          CardRow(
            title: "Oracle Nutrient Search",
            subtitle: "Find foods richest in a nutrient.",
            icon: "graduationcap"
          )
        }
      }
      .padding(.horizontal, DesignSystem.Spacing.screenPadding)
      .padding(.bottom, 24)
    }
    .task {
      await viewModel.loadSuggestions(for: nil)
    }
  }
}

struct CardRow: View {
  let title: String
  let subtitle: String
  let icon: String

  var body: some View {
    HStack(spacing: 16) {
      ZStack {
        Circle()
          .fill(DesignSystem.Colors.backgroundSecondary)
          .frame(width: 48, height: 48)
        Image(systemName: icon)
          .font(.system(size: 20))
          .foregroundStyle(DesignSystem.Colors.accent)
      }

      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(DesignSystem.Colors.textPrimary)
        Text(subtitle)
          .font(.caption)
          .foregroundStyle(DesignSystem.Colors.textSecondary)
      }

      Spacer()

      Image(systemName: "chevron.right")
        .font(.caption)
        .foregroundStyle(DesignSystem.Colors.textSecondary)
    }
    .padding()
    .background(DesignSystem.Colors.cardBackground)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
  }
}

struct CustomMealsListView: View {
  let meals: [CustomMealTemplate]

  var body: some View {
    List {
      Section(header: Text("Saved Meals").font(.app(.heading))) {
        ForEach(meals) { meal in
          let joinedItems = meal.items.joined(separator: ", ")
          VStack(alignment: .leading, spacing: 4) {
            Text(meal.name)
              .font(.app(.heading))
            Text("\(meal.kcal) kcal • \(joinedItems)")
              .font(.app(.bodySecondary))
              .foregroundStyle(DesignSystem.Colors.textSecondary)
          }
          .listRowBackground(DesignSystem.Colors.backgroundSecondary)
        }
      }
      Section(header: Text("Actions").font(.app(.heading))) {
        NavigationLink("Create Meal") {
          CreateMealView()
        }
        .font(.app(.button))
      }
    }
    .scrollContentBackground(.hidden)
    .background(DesignSystem.Colors.background)
    .navigationTitle("Custom Meals")
  }
}

struct CreateMealView: View {
  @State private var name = ""
  @State private var kcal = ""
  @State private var notes = ""

  var body: some View {
    Form {
      Section(header: Text("Meal Details").font(.app(.heading))) {
        TextField("Name", text: $name)
        TextField("Calories", text: $kcal)
          .keyboardType(.numberPad)
        TextField("Notes", text: $notes, axis: .vertical)
      }

      Section(header: Text("Actions").font(.app(.heading))) {
        Button("Save (stub)") {}
      }
    }
    .navigationTitle("Create Meal")
  }
}

struct CustomRecipesView: View {
  var body: some View {
    VStack(spacing: 16) {
      Text("Custom Recipes")
        .font(.app(.title))
        .foregroundStyle(DesignSystem.Colors.textPrimary)
      Text("Create a recipe or import from a URL. Parsing will be added later.")
        .font(.app(.bodySecondary))
        .foregroundStyle(DesignSystem.Colors.textSecondary)
        .multilineTextAlignment(.center)

      Button("Create Recipe") {}
        .font(.app(.button))
        .padding()
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Colors.accent)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

      Button("Import Recipe (stub)") {}
        .font(.app(.button))
        .padding()
        .frame(maxWidth: .infinity)
        .background(DesignSystem.Colors.backgroundSecondary)
        .foregroundStyle(DesignSystem.Colors.textPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

      Spacer()
    }
    .padding()
    .background(DesignSystem.Colors.background)
    .navigationTitle("Custom Recipes")
  }
}

struct CustomFoodsFormView: View {
  @State private var name = ""
  @State private var serving = ""
  @State private var protein = ""
  @State private var carbs = ""
  @State private var fat = ""
  @State private var magnesium = ""

  var body: some View {
    Form {
      Section(header: Text("Basics").font(.app(.heading))) {
        TextField("Food name", text: $name)
        TextField("Serving size (e.g. 100g, 1 cup)", text: $serving)
      }

      Section(header: Text("Macros").font(.app(.heading))) {
        TextField("Protein (g)", text: $protein).keyboardType(.decimalPad)
        TextField("Carbs (g)", text: $carbs).keyboardType(.decimalPad)
        TextField("Fat (g)", text: $fat).keyboardType(.decimalPad)
      }

      Section(header: Text("Key Nutrients").font(.app(.heading))) {
        TextField("Magnesium (mg)", text: $magnesium).keyboardType(.decimalPad)
      }

      Section(header: Text("Actions").font(.app(.heading))) {
        Button("Save Food (stub)") {}
      }
    }
    .navigationTitle("Create Food")
  }
}

struct RepeatItemsView: View {
  let items: [RepeatItem]

  var body: some View {
    List {
      ForEach(items) { item in
        VStack(alignment: .leading, spacing: 4) {
          Text(item.title)
            .font(.app(.heading))
          Text(item.detail)
            .font(.app(.bodySecondary))
            .foregroundStyle(DesignSystem.Colors.textSecondary)
          Text(item.schedule)
            .font(.app(.caption))
            .foregroundStyle(DesignSystem.Colors.textSecondary)
        }
        .listRowBackground(DesignSystem.Colors.backgroundSecondary)
      }
    }
    .scrollContentBackground(.hidden)
    .background(DesignSystem.Colors.background)
    .navigationTitle("Repeat Items")
  }
}

struct NutritionSuggestionsView: View {
  let groups: [NutritionRecommendationGroup]
  let onRefresh: () -> Void

  var body: some View {
    List {
      ForEach(groups) { group in
        Section(header: Text(group.title).font(.app(.heading))) {
          if let description = group.description {
            Text(description)
              .font(.app(.bodySecondary))
              .foregroundStyle(DesignSystem.Colors.textSecondary)
          }
          ForEach(group.foods) { food in
            VStack(alignment: .leading, spacing: 4) {
              Text(food.name)
                .font(.app(.body))
              Text("\(food.calories) kcal • \(food.macroLine)")
                .font(.app(.caption))
                .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
            .listRowBackground(DesignSystem.Colors.backgroundSecondary)
          }
        }
      }
    }
    .toolbar {
      Button("Refresh") { onRefresh() }
    }
    .scrollContentBackground(.hidden)
    .background(DesignSystem.Colors.background)
    .navigationTitle("Suggest Food")
  }
}

struct OracleNutrientSearchView: View {
  @ObservedObject var viewModel: NutritionFoodToolsViewModel
  @State private var selectedNutrient = "Protein"

  var body: some View {
    VStack(alignment: .leading, spacing: 16) {
      Picker("Nutrient", selection: $selectedNutrient) {
        ForEach(["Protein", "Magnesium", "Iron", "Potassium", "Fiber"], id: \.self) { nutrient in
          Text(nutrient).tag(nutrient)
        }
      }
      .pickerStyle(.segmented)

      Button("Search top foods") {
        Task { await viewModel.searchTopFoods(by: selectedNutrient) }
      }
      .font(.app(.button))
      .padding()
      .frame(maxWidth: .infinity)
      .background(DesignSystem.Colors.accent)
      .foregroundStyle(.white)
      .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

      List {
        ForEach(viewModel.oracleResults) { food in
          VStack(alignment: .leading, spacing: 4) {
            Text(food.name)
              .font(.app(.body))
            Text("\(food.calories) kcal • \(food.macroLine)")
              .font(.app(.caption))
              .foregroundStyle(DesignSystem.Colors.textSecondary)
          }
          .listRowBackground(DesignSystem.Colors.backgroundSecondary)
        }
      }
      .scrollContentBackground(.hidden)
      .background(DesignSystem.Colors.background)

      Spacer()
    }
    .padding()
    .background(DesignSystem.Colors.background)
    .navigationTitle("Oracle Nutrient Search")
    .task {
      await viewModel.searchTopFoods(by: selectedNutrient)
    }
  }
}

// MARK: - Shared UI

struct NutritionSectionHeader: View {
  let title: String
  var subtitle: String? = nil

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .font(.app(.title))
        .foregroundStyle(DesignSystem.Colors.textPrimary)
      if let subtitle {
        Text(subtitle)
          .font(.app(.bodySecondary))
          .foregroundStyle(DesignSystem.Colors.textSecondary)
      }
    }
  }
}

struct BiohackingMetricsRow: View {
  let scores: [BiohackingScore]

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 12) {
        ForEach(Array(scores.enumerated()), id: \.element.id) { index, score in
          HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
              Text(score.title)
                .font(.app(.caption))
                .foregroundStyle(DesignSystem.Colors.textSecondary)
              Text("\(score.score)%")
                .font(.app(.button))
                .foregroundStyle(
                  score.score > 80
                    ? DesignSystem.Colors.success
                    : (score.score > 50 ? DesignSystem.Colors.warning : DesignSystem.Colors.error)
                )
            }

            CircularProgress(
              progress: Double(score.score) / 100.0, color: DesignSystem.Colors.accent,
              size: 26)
          }
          .padding(12)
          .background(DesignSystem.Colors.cardBackground)
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .overlay(
            RoundedRectangle(cornerRadius: 16).stroke(DesignSystem.Colors.border, lineWidth: 1)
          )
          .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
          .transition(.scale.combined(with: .opacity))
          .animation(
            .spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.1),
            value: scores.isEmpty)
        }
      }
      .padding(.vertical, 4)  // Add padding for shadows
    }
  }
}

struct CircularProgress: View {
  let progress: Double
  let color: Color
  let size: CGFloat

  @State private var animatedProgress: CGFloat = 0

  var body: some View {
    ZStack {
      Circle()
        .stroke(color.opacity(0.15), lineWidth: 4)
      Circle()
        .trim(from: 0, to: animatedProgress)
        .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
        .rotationEffect(.degrees(-90))
        .shadow(color: color.opacity(0.3), radius: 2, x: 0, y: 0)
    }
    .frame(width: size, height: size)
    .onAppear {
      withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
        animatedProgress = progress
      }
    }
  }
}

// MARK: - Quick Actions Sheet

struct NutritionQuickActionsSheet: View {
  let onDismiss: () -> Void

  var body: some View {
    NavigationStack {
      List {
        Section(header: Text("Log").font(.app(.heading))) {
          ForEach(NutritionQuickActionItem.sample) { action in
            HStack {
              Image(systemName: action.icon)
                .foregroundStyle(action.tint)
              VStack(alignment: .leading) {
                Text(action.title)
                  .font(.app(.body))
                Text(action.subtitle)
                  .font(.app(.caption))
                  .foregroundStyle(DesignSystem.Colors.textSecondary)
              }
              Spacer()
              Image(systemName: "chevron.right")
                .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
          }
        }
      }
      .scrollContentBackground(.hidden)
      .background(DesignSystem.Colors.background)
      .navigationTitle("Quick Actions")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Close") { onDismiss() }
            .font(.app(.button))
        }
      }
    }
  }
}

struct NutritionQuickActionItem: Identifiable {
  let id = UUID()
  let title: String
  let subtitle: String
  let icon: String
  let tint: Color

  static let sample: [NutritionQuickActionItem] = [
    NutritionQuickActionItem(
      title: "Log Meal", subtitle: "Add a full meal entry", icon: "fork.knife", tint: .orange),
    NutritionQuickActionItem(
      title: "Quick Add Protein", subtitle: "Fast macro entry", icon: "bolt.fill", tint: .blue),
    NutritionQuickActionItem(
      title: "Scan Food", subtitle: "Use barcode or camera", icon: "camera.viewfinder", tint: .green
    ),
  ]
}

// MARK: - View Models & Engines

@MainActor
class NutritionOverviewViewModel: ObservableObject {
  @Published var todaySummary: EFNutritionDaySummary = .mockToday()
  @Published var weekSummaries: [EFNutritionDaySummary] = []
  @Published var profile: UserNutritionProfile = .mock()
  @Published var guidanceText: String = "Loading guidance..."

  private let provider: NutritionDataProvider

  init(provider: NutritionDataProvider) {
    self.provider = provider
  }

  func load() async {
    async let day = provider.fetchDaySummary(date: Date())
    async let week = provider.fetchWeekSummary(for: Date())

    let (today, weekData) = await (day, week)
    todaySummary = today
    weekSummaries = weekData
    guidanceText = NutritionGuidance.message(for: profile, summary: todaySummary)
  }
}

@MainActor
class NutritionDiaryViewModel: ObservableObject {
  @Published var date: Date = Date()
  @Published var entries: [MealEntry] = []
  @Published var totals: NutritionValues = .zero

  private let provider: NutritionDataProvider

  init(provider: NutritionDataProvider) {
    self.provider = provider
  }

  var formattedDate: String {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter.string(from: date)
  }

  func load(for date: Date) async {
    let fetched = await provider.fetchDiaryEntries(for: date)
    entries = fetched
    totals = fetched.reduce(into: NutritionValues.zero) { partial, entry in
      partial = partial + entry.nutritionValues
    }
  }

  func changeDay(by offset: Int) {
    if let newDate = Calendar.current.date(byAdding: .day, value: offset, to: date) {
      date = newDate
    }
  }
}

@MainActor
class NutritionReportViewModel: ObservableObject {
  @Published var summary: NutritionReportSummary = .mock()

  private let provider: NutritionDataProvider

  init(provider: NutritionDataProvider) {
    self.provider = provider
  }

  func load() async {
    let data = await provider.fetchReportSummary(for: Date())
    summary = data
  }
}

@MainActor
class NutritionFoodToolsViewModel: ObservableObject {
  @Published var customMeals: [CustomMealTemplate] = [
    CustomMealTemplate(name: "Muscle Gain Bowl", kcal: 640, items: ["Rice", "Chicken", "Avocado"]),
    CustomMealTemplate(
      name: "Overnight Oats", kcal: 420, items: ["Oats", "Greek Yogurt", "Berries"]),
  ]

  @Published var repeatItems: [RepeatItem] = [
    RepeatItem(title: "Breakfast Shake", detail: "Protein + banana", schedule: "Daily • 8:00 AM"),
    RepeatItem(title: "Electrolyte Mix", detail: "Magnesium + sodium", schedule: "Training days"),
  ]

  @Published var suggestionGroups: [NutritionRecommendationGroup] = []
  @Published var oracleResults: [NutritionSuggestedFood] = []

  private let provider: NutritionDataProvider

  init(provider: NutritionDataProvider) {
    self.provider = provider
  }

  func loadSuggestions(for target: NutritionSuggestionTarget?) async {
    let groups = await provider.fetchFoodSuggestions(for: target)
    suggestionGroups = NutritionSuggestionEngine.prepare(groups: groups)
  }

  func searchTopFoods(by nutrient: String) async {
    oracleResults = await provider.searchFoods(byNutrient: nutrient)
  }
}

struct NutritionGuidance {
  static func message(for profile: UserNutritionProfile, summary: EFNutritionDaySummary) -> String {
    let caloriesRemaining = profile.dailyCalorieTarget - summary.caloriesConsumed

    if caloriesRemaining < -200 {
      return "You're slightly above target. Plan a lighter dinner or add a short walk to offset."
    } else if summary.protein < profile.proteinTarget / 2 {
      return
        "Protein is lagging. Add \(profile.proteinTarget - summary.protein)g more via lean sources."
    } else if caloriesRemaining > 700 {
      return "Fuel up: you still have \(caloriesRemaining) kcal available to support recovery."
    } else {
      return "Nice pace today. Keep hydration and fiber up to finish strong."
    }
  }
}

enum NutritionSuggestionEngine {
  static func prepare(groups: [NutritionRecommendationGroup]) -> [NutritionRecommendationGroup] {
    groups.sorted { $0.title < $1.title }
  }
}
