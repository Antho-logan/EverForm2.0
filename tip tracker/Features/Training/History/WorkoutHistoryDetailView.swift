//
//  WorkoutHistoryDetailView.swift
//  EverForm
//
//  Detailed view of a completed workout with exercise breakdown
//  Applied: T-UI, S-OBS2, P-ARCH, C-SIMPLE, R-LOGS
//

import SwiftUI

struct WorkoutHistoryDetailView: View {
    let workout: WorkoutHistorySummary
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    // Header Stats
                    WorkoutStatsSection(workout: workout)
                    
                    // Exercise Breakdown
                    if !workout.exerciseSummaries.isEmpty {
                        ExerciseBreakdownSection(exercises: workout.exerciseSummaries)
                    }
                    
                    // Notes
                    if let notes = workout.notes, !notes.isEmpty {
                        NotesSection(notes: notes)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                .padding(.vertical, DesignSystem.Spacing.lg)
            }
            .navigationTitle(workout.title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            // TODO: Share workout
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        
                        Button {
                            // TODO: Export to Health
                        } label: {
                            Label("Export to Health", systemImage: "heart")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .onAppear {
            TelemetryService.shared.track("workout_detail_viewed", properties: [
                "workout_id": workout.id.uuidString,
                "title": workout.title
            ])
        }
    }
}

// MARK: - Workout Stats Section

struct WorkoutStatsSection: View {
    let workout: WorkoutHistorySummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Workout Summary")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    DetailStatCard(
                        title: "Duration",
                        value: workout.formattedDuration,
                        icon: "clock.fill",
                        color: DesignSystem.Colors.info
                    )
                    
                    DetailStatCard(
                        title: "Total Volume",
                        value: workout.formattedVolume,
                        icon: "scalemass.fill",
                        color: DesignSystem.Colors.success
                    )
                }
                
                HStack(spacing: DesignSystem.Spacing.md) {
                    DetailStatCard(
                        title: "Sets",
                        value: "\(workout.totalSets)",
                        icon: "list.bullet.circle.fill",
                        color: DesignSystem.Colors.accent
                    )
                    
                    DetailStatCard(
                        title: "Total Reps",
                        value: "\(workout.totalReps)",
                        icon: "number.circle.fill",
                        color: DesignSystem.Colors.warning
                    )
                }
            }
            
            // Date and Time
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                
                Text(workout.formattedDate)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Exercise Breakdown Section

struct ExerciseBreakdownSection: View {
    let exercises: [ExerciseSummary]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Exercise Breakdown")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(exercises) { exercise in
                    ExerciseDetailCard(exercise: exercise)
                }
            }
        }
    }
}

// MARK: - Notes Section

struct NotesSection: View {
    let notes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Notes")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(notes)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.primary)
                .padding(DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                        .stroke(DesignSystem.Border.outlineColor, lineWidth: DesignSystem.Border.outline)
                )
        }
    }
}

// MARK: - Detail Stat Card

struct DetailStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                .stroke(DesignSystem.Border.outlineColor, lineWidth: DesignSystem.Border.outline)
        )
    }
}

// MARK: - Exercise Detail Card

struct ExerciseDetailCard: View {
    let exercise: ExerciseSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Exercise Name
            Text(exercise.exerciseName)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
            
            // Stats Row
            HStack(spacing: DesignSystem.Spacing.lg) {
                StatPill(
                    label: "Sets",
                    value: "\(exercise.completedSets)",
                    color: DesignSystem.Colors.accent
                )
                
                StatPill(
                    label: "Reps",
                    value: "\(exercise.totalReps)",
                    color: DesignSystem.Colors.info
                )
                
                if exercise.totalVolume > 0 {
                    StatPill(
                        label: "Volume",
                        value: String(format: "%.0f kg", exercise.totalVolume),
                        color: DesignSystem.Colors.success
                    )
                }
                
                Spacer()
            }
            
            // Best Set
            if let bestSet = exercise.bestSet {
                HStack {
                    Text("Best set:")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Text(bestSet.displayText)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackgroundElevated)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.sm)
                .stroke(DesignSystem.Border.outlineColor, lineWidth: DesignSystem.Border.outline)
        )
    }
}

// MARK: - Stat Pill

struct StatPill: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}

#Preview {
    WorkoutHistoryDetailView(
        workout: WorkoutHistorySummary(
            title: "Upper Power",
            totalVolumeKg: 2450.0,
            totalSets: 18,
            totalReps: 162,
            durationSec: 4200,
            notes: "Great workout! Felt strong on bench press and managed to hit all my target reps.",
            exerciseSummaries: [
                ExerciseSummary(
                    exerciseName: "Bench Press",
                    completedSets: 3,
                    totalReps: 30,
                    totalVolume: 1800.0,
                    bestSet: SetSummary(reps: 10, weight: 60.0, rpe: 8.0)
                ),
                ExerciseSummary(
                    exerciseName: "Pull-ups",
                    completedSets: 3,
                    totalReps: 24,
                    totalVolume: 0.0,
                    bestSet: SetSummary(reps: 8, weight: nil, rpe: 7.5)
                ),
                ExerciseSummary(
                    exerciseName: "Overhead Press",
                    completedSets: 3,
                    totalReps: 27,
                    totalVolume: 1080.0,
                    bestSet: SetSummary(reps: 9, weight: 40.0, rpe: 8.5)
                )
            ]
        )
    )
}
