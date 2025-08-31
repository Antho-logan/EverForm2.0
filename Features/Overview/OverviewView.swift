//
//  OverviewView.swift
//  EverForm
//
//  Modern Overview screen with avatar, trends, KPIs, and quick actions
//

import SwiftUI

struct OverviewView: View {
    let viewModel: DashboardViewModel
    let openExplain: (String, String) -> Void
    let onScanCalories: () -> Void
    let onQuickMeal: () -> Void
    let onStartMobility: () -> Void
    
    @Environment(WorkoutStore.self) private var workoutStore
    @Environment(ProfileStore.self) private var profileStore
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var showingProfilePopover = false
    @State private var isReorderingQuickActions = false
    
    var body: some View {
        let palette = Theme.palette(colorScheme)
        
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Header with avatar and title
                    headerSection
                    
                    // Resume workout banner if active
                    if workoutStore.hasActiveWorkout {
                        ResumeWorkoutChip(
                            elapsedTime: workoutStore.activeSnapshot?.formattedElapsedTime ?? "0:00",
                            onTap: {
                                DebugLog.info("Resume workout tapped")
                            }
                        )
                    }
                    
                    // Top info band: Trends + KPIs
                    topInfoBandSection
                    
                    // Today's Plan (2x2 grid)
                    todaysPlanSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Bottom padding for tab bar
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, Theme.Spacing.sm)
            }
        }
        .background(palette.background)
        .navigationBarHidden(true)
        .sheet(isPresented: $showingProfilePopover) {
            ProfilePopoverView()
                .presentationDetents([.height(400)])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        HStack {
            // Avatar button
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                showingProfilePopover = true
            }) {
                Circle()
                    .fill(Theme.palette(colorScheme).accent.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(Theme.palette(colorScheme).accent)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Profile")
            
            Spacer()
            
            // Title
            Text("Overview")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Theme.palette(colorScheme).textPrimary)
            
            Spacer()
            
            // Spacer to balance avatar
            Color.clear.frame(width: 40, height: 40)
        }
    }
    
    // MARK: - Top Info Band
    
    @ViewBuilder
    private var topInfoBandSection: some View {
        if horizontalSizeClass == .compact {
            // Stack vertically on narrow screens
            VStack(spacing: Theme.Spacing.md) {
                trendMiniDialsSection
                kpiTilesSection
            }
        } else {
            // Side by side on wider screens
            VStack(spacing: Theme.Spacing.md) {
                HStack(spacing: Theme.Spacing.md) {
                    trendMiniDialsSection
                    kpiTilesSection
                }
            }
        }
    }
    
    private var trendMiniDialsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(minimum: 56, maximum: .infinity), spacing: Theme.Spacing.sm),
            GridItem(.flexible(minimum: 56, maximum: .infinity), spacing: Theme.Spacing.sm)
        ], spacing: Theme.Spacing.sm) {
            TrendMiniDial(
                icon: "figure.walk",
                value: formatNumber(viewModel.todaySteps),
                trendProgress: 0.75
            )
            TrendMiniDial(
                icon: "flame.fill", 
                value: formatNumber(viewModel.todayCalories),
                trendProgress: 0.60
            )
            TrendMiniDial(
                icon: "bed.double.fill",
                value: formatSleepHours(viewModel.todaySleepHours),
                trendProgress: 0.85
            )
            TrendMiniDial(
                icon: "drop.fill",
                value: "\(viewModel.todayHydrationMl) ml",
                trendProgress: 0.40
            )
        }
    }
    
    private var kpiTilesSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(minimum: 150, maximum: .infinity), spacing: Theme.Spacing.sm),
            GridItem(.flexible(minimum: 150, maximum: .infinity), spacing: Theme.Spacing.sm)
        ], spacing: Theme.Spacing.sm) {
            KPITile(
                icon: "figure.walk",
                value: formatNumber(viewModel.todaySteps),
                caption: "Steps"
            ) {
                viewModel.logTap("progress_steps_tap")
            }
            
            KPITile(
                icon: "flame.fill",
                value: "\(viewModel.todayCalories) / \(viewModel.targetCalories)",
                caption: "Calories"
            ) {
                viewModel.logTap("progress_calories_tap")
            }
            
            KPITile(
                icon: "bed.double.fill",
                value: formatSleepHours(viewModel.todaySleepHours),
                caption: "Sleep"
            ) {
                viewModel.logTap("progress_sleep_tap")
            }
            
            KPITile(
                icon: "drop.fill",
                value: "\(viewModel.todayHydrationMl) ml",
                caption: "Hydration"
            ) {
                viewModel.logTap("progress_hydration_tap")
            }
        }
    }

    // MARK: - Today's Plan Section

    private var todaysPlanSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Today's Plan")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Theme.palette(colorScheme).textPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Theme.Spacing.sm),
                GridItem(.flexible(), spacing: Theme.Spacing.sm)
            ], spacing: Theme.Spacing.sm) {
                PlanCard(
                    title: "Training",
                    subtitle: "Upper Power",
                    actionTitle: "Start Workout",
                    icon: "dumbbell.fill",
                    accentColor: Theme.palette(colorScheme).accent
                ) {
                    DebugLog.info("Overview: Training card tapped")
                }

                PlanCard(
                    title: "Nutrition",
                    subtitle: "2400 kcal target",
                    actionTitle: "Log Meal",
                    icon: "fork.knife",
                    accentColor: .orange
                ) {
                    DebugLog.info("Overview: Nutrition card tapped")
                    onQuickMeal()
                }

                PlanCard(
                    title: "Recovery",
                    subtitle: "Bedtime 22:30",
                    actionTitle: "Open",
                    icon: "moon.fill",
                    accentColor: .blue
                ) {
                    DebugLog.info("Overview: Sleep card tapped")
                }

                PlanCard(
                    title: "Mobility",
                    subtitle: "Hips & Shoulders • 8 min",
                    actionTitle: "Start",
                    icon: "figure.flexibility",
                    accentColor: .purple
                ) {
                    DebugLog.info("Overview: Mobility card tapped")
                    onStartMobility()
                }
            }
        }
    }

    // MARK: - Quick Actions Section

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack {
                Text("Quick Actions")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Theme.palette(colorScheme).textPrimary)

                Spacer()

                Button(isReorderingQuickActions ? "Done" : "Reorder") {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    withAnimation(.spring(response: 0.3)) {
                        isReorderingQuickActions.toggle()
                    }
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.palette(colorScheme).accent)
            }

            HStack(spacing: Theme.Spacing.sm) {
                QuickActionTile(
                    icon: "drop.fill",
                    title: "Add Water",
                    isReordering: isReorderingQuickActions
                ) {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    DebugLog.info("Overview: Add Water quick action tapped")
                    viewModel.addWater(250)
                }

                QuickActionTile(
                    icon: "wind",
                    title: "Breathwork",
                    isReordering: isReorderingQuickActions
                ) {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    DebugLog.info("Overview: Breathwork quick action tapped")
                }

                QuickActionTile(
                    icon: "cross.case",
                    title: "Fix Pain",
                    isReordering: isReorderingQuickActions
                ) {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    DebugLog.info("Overview: Fix pain quick action tapped")
                    openExplain("fix_pain", CoachTopic.mobility.rawValue)
                }

                QuickActionTile(
                    icon: "brain.head.profile",
                    title: "Ask Coach",
                    isReordering: isReorderingQuickActions
                ) {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    DebugLog.info("Overview: Ask Coach quick action tapped")
                    viewModel.openCoach()
                }
            }
        }
    }

    // MARK: - Utility Functions

    private func formatNumber(_ number: Int) -> String {
        if number >= 1000 {
            let thousands = Double(number) / 1000.0
            return String(format: "%.1fK", thousands)
        }
        return "\(number)"
    }

    private func formatSleepHours(_ hours: Double) -> String {
        let wholeHours = Int(hours)
        let minutes = Int((hours - Double(wholeHours)) * 60)
        return "\(wholeHours)h \(minutes)m"
    }
}

// MARK: - Supporting Components

private struct PlanCard: View {
    let title: String
    let subtitle: String
    let actionTitle: String
    let icon: String
    let accentColor: Color
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            EFCard {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    HStack {
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(accentColor)
                            .frame(width: 24, height: 24)

                        Spacer()
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Theme.palette(colorScheme).textPrimary)

                        Text(subtitle)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.palette(colorScheme).textSecondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    HStack {
                        Text(actionTitle)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(accentColor)
                            .padding(.horizontal, Theme.Spacing.sm)
                            .padding(.vertical, 6)
                            .background(accentColor.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Spacer()
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .frame(height: 144)
        .accessibilityLabel(title)
        .accessibilityValue(subtitle)
        .accessibilityHint("Tap to \(actionTitle.lowercased())")
    }
}

private struct QuickActionTile: View {
    let icon: String
    let title: String
    let isReordering: Bool
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.xs) {
                ZStack {
                    if isReordering {
                        // Drag handle overlay
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Theme.palette(colorScheme).textSecondary)
                            .opacity(0.6)
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(Theme.palette(colorScheme).accent)
                    }
                }
                .frame(width: 44, height: 44)

                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.palette(colorScheme).textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 84)
            .background(Theme.palette(colorScheme).surface)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .stroke(Theme.palette(colorScheme).stroke, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: isPressed)
        }
        .buttonStyle(.plain)
        .disabled(isReordering)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        }, perform: {})
        .accessibilityLabel(title)
    }
}



// MARK: - Preview

#Preview {
    OverviewView(
        viewModel: DashboardViewModel(),
        openExplain: { _, _ in },
        onScanCalories: {},
        onQuickMeal: {},
        onStartMobility: {}
    )
    .environment(WorkoutStore())
    .environment(ProfileStore())
}
