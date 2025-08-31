//
//  NutritionDiaryView.swift
//  EverForm
//
//  Today's nutrition diary with entries list and goal editing
//  Applied: T-UI, S-OBS2, P-ARCH, C-SIMPLE, R-LOGS
//

import SwiftUI

struct NutritionDiaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NutritionStore.self) private var nutritionStore
    
    @State private var showGoalEditor = false
    @State private var showWeeklyTrends = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with calorie ring
                CalorieRingHeader(nutritionStore: nutritionStore)
                    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                    .padding(.bottom, DesignSystem.Spacing.md)
                
                // Entries List
                if nutritionStore.today.entries.isEmpty {
                    EmptyDiaryView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.Spacing.sm) {
                            ForEach(nutritionStore.today.entriesByTime) { entry in
                                EntryRow(entry: entry) {
                                    deleteEntry(entry.id)
                                }
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                        .padding(.bottom, 120) // Space for footer
                    }
                }
                
                Spacer()
                
                // Footer with totals and goal
                DiaryFooter(
                    nutritionStore: nutritionStore,
                    onAdjustGoal: { showGoalEditor = true },
                    onViewTrends: { showWeeklyTrends = true }
                )
            }
            .navigationTitle("Today's Diary")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showGoalEditor) {
            GoalEditorSheet(nutritionStore: nutritionStore)
        }
        .sheet(isPresented: $showWeeklyTrends) {
            WeeklyTrendsView(onClose: { showWeeklyTrends = false })
        }
        .onAppear {
            TelemetryService.shared.track("nutrition_diary_viewed")
        }
    }
    
    private func deleteEntry(_ id: UUID) {
        withAnimation(.easeInOut(duration: 0.3)) {
            nutritionStore.deleteEntry(id: id)
        }
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}

// MARK: - Calorie Ring Header

struct CalorieRingHeader: View {
    let nutritionStore: NutritionStore
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Date
            Text(nutritionStore.today.formattedDate)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            // Calorie Ring
            ZStack {
                // Background ring
                Circle()
                    .stroke(DesignSystem.Colors.cardBackgroundElevated, lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                // Progress ring
                Circle()
                    .trim(from: 0, to: min(1.0, nutritionStore.todayCalorieProgress))
                    .stroke(
                        DesignSystem.Colors.accent,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: nutritionStore.todayCalorieProgress)
                
                // Center text
                VStack(spacing: 2) {
                    Text("\(nutritionStore.todayCalories)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("/ \(nutritionStore.today.goal.kcal)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text("kcal")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            // Remaining calories
            if nutritionStore.todayRemainingCalories > 0 {
                Text("\(nutritionStore.todayRemainingCalories) kcal remaining")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.success)
            } else {
                Text("Goal reached!")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.accent)
            }
        }
        .padding(.vertical, DesignSystem.Spacing.lg)
    }
}

// MARK: - Empty Diary View

struct EmptyDiaryView: View {
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "fork.knife")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("No meals logged yet")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Start logging your meals to track your nutrition")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Log a meal") {
                UX.Haptic.light()
                router.open(.logMeal)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DesignSystem.Spacing.lg)
    }
}

// MARK: - Entry Row

struct EntryRow: View {
    let entry: MealEntry
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Source icon
            ZStack {
                Circle()
                    .fill(sourceColor.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: entry.source.iconName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(sourceColor)
            }
            
            // Entry details
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(entry.itemRef.displayName)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(entry.formattedTime)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("\(entry.formattedQuantity) • \(entry.kcal) kcal")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    if entry.protein > 0 || entry.carbs > 0 || entry.fat > 0 {
                        Text("• P: \(String(format: "%.0f", entry.protein))g C: \(String(format: "%.0f", entry.carbs))g F: \(String(format: "%.0f", entry.fat))g")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                .stroke(DesignSystem.Border.outlineColor, lineWidth: DesignSystem.Border.outline)
        )
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.displayName), \(entry.kcal) calories, logged at \(entry.formattedTime)")
    }
    
    private var sourceColor: Color {
        switch entry.source {
        case .scan:
            return DesignSystem.Colors.accent
        case .quickAdd:
            return DesignSystem.Colors.success
        case .search:
            return DesignSystem.Colors.info
        }
    }
}

// MARK: - Diary Footer

struct DiaryFooter: View {
    let nutritionStore: NutritionStore
    let onAdjustGoal: () -> Void
    let onViewTrends: () -> Void
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Divider()
            
            // Totals vs Goal
            VStack(spacing: DesignSystem.Spacing.sm) {
                HStack {
                    Text("Today's Totals")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button("Adjust Goal") {
                        onAdjustGoal()
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(DesignSystem.Colors.accent)
                }
                
                // Macro breakdown
                HStack {
                    MacroProgress(
                        label: "Protein",
                        current: nutritionStore.today.totals.protein,
                        goal: Double(nutritionStore.today.goal.protein),
                        unit: "g",
                        color: DesignSystem.Colors.info
                    )
                    
                    MacroProgress(
                        label: "Carbs",
                        current: nutritionStore.today.totals.carbs,
                        goal: Double(nutritionStore.today.goal.carbs),
                        unit: "g",
                        color: DesignSystem.Colors.warning
                    )
                    
                    MacroProgress(
                        label: "Fat",
                        current: nutritionStore.today.totals.fat,
                        goal: Double(nutritionStore.today.goal.fat),
                        unit: "g",
                        color: DesignSystem.Colors.error
                    )
                }
            }
            
            // Weekly Trends Button
            Button("Weekly Trends") {
                onViewTrends()
            }
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundColor(DesignSystem.Colors.accent)
            .padding(.bottom, DesignSystem.Spacing.md)
        }
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
        .background(DesignSystem.Colors.background)
    }
}

// MARK: - Macro Progress

struct MacroProgress: View {
    let label: String
    let current: Double
    let goal: Double
    let unit: String
    let color: Color
    
    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(1.0, current / goal)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            Text("\(String(format: "%.0f", current))\(unit)")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("/ \(String(format: "%.0f", goal))\(unit)")
                .font(.system(size: 10, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(color.opacity(0.2))
                        .frame(height: 4)
                        .clipShape(Capsule())
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 4)
                        .clipShape(Capsule())
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 4)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NutritionDiaryView()
        .environment(NutritionStore())
}



