//
//  WorkoutHistoryListView.swift
//  EverForm
//
//  Workout history list with summary cards
//  Applied: T-UI, S-OBS2, P-ARCH, C-SIMPLE, R-LOGS
//
//

import SwiftUI

struct WorkoutHistoryListView: View {
    let onClose: () -> Void
    @State private var workoutHistory: [WorkoutHistorySummary] = []
    @State private var isLoading = true
    @State private var selectedWorkout: WorkoutHistorySummary?
    @State private var showWorkoutDetail = false
    @Environment(AppRouter.self) private var router
    
    var body: some View {
        EFScreenContainer {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Close") { onClose() }
                        .font(EverFormTheme.Typography.button)
                        .foregroundColor(EverFormTheme.Colors.textSecondary)
                    
                    Spacer()
                    
                    Text("History")
                        .font(EverFormTheme.Typography.sectionTitle)
                        .foregroundColor(EverFormTheme.Colors.textPrimary)
                    
                    Spacer()
                    
                    // Balance spacing
                    Text("Close").hidden()
                }
                .padding(20)
                .background(EverFormTheme.Colors.background)
                
                if isLoading {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(0..<5, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(EverFormTheme.Colors.surface)
                                    .frame(height: 120)
                            }
                        }
                        .padding(20)
                    }
                } else if workoutHistory.isEmpty {
                    EmptyHistoryView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
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
                        .padding(20)
                        .padding(.bottom, 40)
                    }
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
        VStack(spacing: 24) {
            Image(systemName: "dumbbell")
                .font(.system(size: 60))
                .foregroundColor(EverFormTheme.Colors.textSecondary)
            
            VStack(spacing: 8) {
                Text("No workouts yet")
                    .font(EverFormTheme.Typography.sectionTitle)
                    .foregroundColor(EverFormTheme.Colors.textPrimary)
                
                Text("Complete your first workout to see it here")
                    .font(EverFormTheme.Typography.body)
                    .foregroundColor(EverFormTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            EFPrimaryButton("Start your first workout", color: EverFormTheme.Colors.trainingGreen) {
                // UX.Haptic.light() // If available
                router.go(.overview)
            }
            .frame(width: 240)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
    }
}

// MARK: - Workout History Card

struct WorkoutHistoryCard: View {
    let workout: WorkoutHistorySummary
    let onTap: () -> Void
    
    var body: some View {
        EFCard {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(workout.title)
                            .font(EverFormTheme.Typography.cardTitle)
                            .foregroundColor(EverFormTheme.Colors.textPrimary)
                        
                        Text(workout.shortFormattedDate)
                            .font(EverFormTheme.Typography.caption)
                            .foregroundColor(EverFormTheme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(EverFormTheme.Colors.textSecondary)
                }
                
                // Stats Row
                HStack(spacing: 16) {
                    StatItem(
                        icon: "clock.fill",
                        value: workout.formattedDuration,
                        color: EverFormTheme.Colors.infoBlue
                    )
                    
                    StatItem(
                        icon: "scalemass.fill",
                        value: workout.formattedVolume,
                        color: EverFormTheme.Colors.successGreen
                    )
                    
                    StatItem(
                        icon: "list.bullet.circle.fill",
                        value: "\(workout.totalSets) sets",
                        color: EverFormTheme.Colors.trainingGreen
                    )
                    
                    Spacer()
                }
                
                // Exercise Summary (first 3 exercises)
                if !workout.exerciseSummaries.isEmpty {
                    HStack {
                        Text("Exercises:")
                            .font(EverFormTheme.Typography.label)
                            .foregroundColor(EverFormTheme.Colors.textSecondary)
                        
                        Text(exerciseList)
                            .font(EverFormTheme.Typography.caption)
                            .foregroundColor(EverFormTheme.Colors.textSecondary)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                }
            }
        }
        .onTapGesture { onTap() }
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
                .font(EverFormTheme.Typography.label)
                .foregroundColor(EverFormTheme.Colors.textPrimary)
        }
    }
}
