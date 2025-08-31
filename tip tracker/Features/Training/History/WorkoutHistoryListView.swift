//
//  WorkoutHistoryListView.swift
//  EverForm
//
//  Workout history list with summary cards
//  Applied: T-UI, S-OBS2, P-ARCH, C-SIMPLE, R-LOGS
//

import SwiftUI

struct WorkoutHistoryListView: View {
    let onClose: () -> Void
    @State private var workoutHistory: [WorkoutHistorySummary] = []
    @State private var isLoading = true
    @State private var selectedWorkout: WorkoutHistorySummary?
    @State private var showWorkoutDetail = false
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.Spacing.md) {
                            ForEach(0..<5, id: \.self) { _ in
                                SkeletonView.card
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                        .padding(.vertical, DesignSystem.Spacing.lg)
                    }
                } else if workoutHistory.isEmpty {
                    EmptyHistoryView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.Spacing.md) {
                            ForEach(workoutHistory) { workout in
                                WorkoutHistoryCard(
                                    workout: workout,
                                    onTap: {
                                        selectedWorkout = workout
                                        showWorkoutDetail = true
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                        .padding(.vertical, DesignSystem.Spacing.lg)
                    }
                }
            }
            .navigationTitle("Workout History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        onClose()
                    }
                }
            }
            .sheet(isPresented: $showWorkoutDetail) {
                if let workout = selectedWorkout {
                    WorkoutHistoryDetailView(workout: workout)
                }
            }
            .onAppear {
                loadHistory()
            }
        }
    }
    
    private func loadHistory() {
        Task {
            let history = await WorkoutPersistence.shared.loadHistory(limit: 30)
            
            await MainActor.run {
                workoutHistory = history
                isLoading = false
            }
            
            DebugLog.info("Loaded workout history: \(history.count) entries")
            TelemetryService.shared.track("workout_history_viewed", properties: [
                "count": history.count
            ])
        }
    }
}

// MARK: - Empty State View

struct EmptyHistoryView: View {
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "dumbbell")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("No workouts yet")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Complete your first workout to see it here")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Start your first workout") {
                UX.Haptic.light()
                router.go(.overview)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DesignSystem.Spacing.lg)
    }
}

// MARK: - Workout History Card

struct WorkoutHistoryCard: View {
    let workout: WorkoutHistorySummary
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(workout.title)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(workout.shortFormattedDate)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                // Stats Row
                HStack(spacing: DesignSystem.Spacing.lg) {
                    StatItem(
                        icon: "clock.fill",
                        value: workout.formattedDuration,
                        color: DesignSystem.Colors.info
                    )
                    
                    StatItem(
                        icon: "scalemass.fill",
                        value: workout.formattedVolume,
                        color: DesignSystem.Colors.success
                    )
                    
                    StatItem(
                        icon: "list.bullet.circle.fill",
                        value: "\(workout.totalSets) sets",
                        color: DesignSystem.Colors.accent
                    )
                    
                    Spacer()
                }
                
                // Exercise Summary (first 3 exercises)
                if !workout.exerciseSummaries.isEmpty {
                    HStack {
                        Text("Exercises:")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Text(exerciseList)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
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
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Workout: \(workout.title), \(workout.formattedDate), \(workout.formattedDuration), \(workout.formattedVolume)")
    }
    
    private var exerciseList: String {
        let names = workout.exerciseSummaries.prefix(3).map(\.exerciseName)
        let list = names.joined(separator: ", ")
        
        if workout.exerciseSummaries.count > 3 {
            return list + ", +\(workout.exerciseSummaries.count - 3) more"
        } else {
            return list
        }
    }
}

// MARK: - Stat Item

struct StatItem: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    WorkoutHistoryListView(onClose: { print("Close") })
}
