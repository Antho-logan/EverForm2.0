//
//  OverviewContentView.swift
//  EverForm
//
//  Main overview content combining dashboard components
//  Applied: T-UI, S-OBS2, P-ARCH, C-SIMPLE
//

import SwiftUI

struct OverviewContentView: View {
    let viewModel: DashboardViewModel
    let openExplain: (String, String) -> Void
    let onScanCalories: () -> Void
    let onQuickMeal: () -> Void
    let onStartMobility: () -> Void

    @Environment(WorkoutStore.self) private var workoutStore
    @Environment(ProfileStore.self) private var profileStore
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        let palette = Theme.palette(colorScheme)

        ScrollView {
            VStack(spacing: 20) {
                // Header Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Overview")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(palette.textPrimary)
                        Spacer()
                    }

                    // Resume workout banner if active
                    if workoutStore.hasActiveWorkout {
                        ResumeWorkoutChip(
                            elapsedTime: workoutStore.activeSnapshot?.formattedElapsedTime ?? "0:00",
                            onTap: {
                                DebugLog.info("Resume workout tapped")
                            }
                        )
                    }

                    // Trends + KPI Section
                    if horizontalSizeClass == .compact {
                        // Stack vertically on narrow screens
                        VStack(spacing: 12) {
                            trendMiniDialsSection
                            kpiTilesSection
                        }
                    } else {
                        // Side by side on wider screens
                        HStack(spacing: 12) {
                            trendMiniDialsSection
                            kpiTilesSection
                        }
                    }
                }

                // Today's Plan Section (2x2 Grid)
                todaysPlanSection

                // Quick Actions (Updated)
                quickActionsSection

                // Bottom padding for tab bar
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
        .navigationBarHidden(true)
    }

    // MARK: - Helper Views

    private var trendMiniDialsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                TrendMiniDial(icon: "figure.walk", value: "8.4K", trendProgress: 0.75)
                TrendMiniDial(icon: "flame.fill", value: "1.9K", trendProgress: 0.60)
                TrendMiniDial(icon: "bed.double.fill", value: "7h 30m", trendProgress: 0.85)
                TrendMiniDial(icon: "drop.fill", value: "0 ml", trendProgress: 0.40)
            }
        }
    }

    private var kpiTilesSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
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

    private var todaysPlanSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Plan")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Theme.palette(colorScheme).textPrimary)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
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

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Quick Actions")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Theme.palette(colorScheme).textPrimary)

                Spacer()

                Button("Reorder") {
                    // TODO: Implement reordering
                    DebugLog.info("Reorder quick actions tapped")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.palette(colorScheme).accent)
            }

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                QuickActionTile(
                    icon: "drop.fill",
                    title: "Add Water",
                    style: .water
                ) {
                    DebugLog.info("Overview: Add Water quick action tapped")
                    viewModel.addWater(250)
                }

                QuickActionTile(
                    icon: "wind",
                    title: "Breathwork",
                    style: .info
                ) {
                    DebugLog.info("Overview: Breathwork quick action tapped")
                }

                QuickActionTile(
                    icon: "cross.case",
                    title: "Fix Pain",
                    style: .danger
                ) {
                    DebugLog.info("Overview: Fix pain quick action tapped")
                    openExplain("fix_pain", CoachTopic.mobility.rawValue)
                }

                QuickActionTile(
                    icon: "brain.head.profile",
                    title: "Ask Coach",
                    style: .success
                ) {
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

// MARK: - Plan Card Component

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
                VStack(alignment: .leading, spacing: 12) {
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
                            .padding(.horizontal, 12)
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



// MARK: - Resume Workout Chip

struct ResumeWorkoutChip: View {
    let elapsedTime: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "repeat.circle.fill")
                    .foregroundColor(DesignSystem.Colors.accent)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Resume Workout")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Elapsed: \(elapsedTime)")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.accent.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                    .stroke(DesignSystem.Colors.accent.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Resume workout, elapsed time \(elapsedTime)")
    }
}

#Preview {
    OverviewContentView(
        viewModel: DashboardViewModel(),
        openExplain: { _, _ in },
        onScanCalories: {},
        onQuickMeal: {},
        onStartMobility: {}
    )
    .environment(WorkoutStore())
}
