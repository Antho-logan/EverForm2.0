//
//  WorkoutHistoryDetailView.swift
//  EverForm
//
//  Detailed view of a completed workout with exercise breakdown
//  Applied: T-UI, S-OBS2, P-ARCH, C-SIMPLE, R-LOGS
//
//

import SwiftUI

struct WorkoutHistoryDetailView: View {
    let workout: WorkoutHistorySummary
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        EFScreenContainer {
            VStack(spacing: 0) {
                EFHeader(title: workout.title, showBack: true) {
                    dismiss()
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: EverFormTheme.Spacing.sectionSpacing) {
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
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Workout Summary")
                .font(EverFormTheme.Typography.sectionTitle)
                .foregroundColor(EverFormTheme.Colors.textPrimary)
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    DetailStatCard(
                        title: "Duration",
                        value: workout.formattedDuration,
                        icon: "clock.fill",
                        color: EverFormTheme.Colors.infoBlue
                    )
                    
                    DetailStatCard(
                        title: "Total Volume",
                        value: workout.formattedVolume,
                        icon: "scalemass.fill",
                        color: EverFormTheme.Colors.successGreen
                    )
                }
                
                HStack(spacing: 12) {
                    DetailStatCard(
                        title: "Sets",
                        value: "\(workout.totalSets)",
                        icon: "list.bullet.circle.fill",
                        color: EverFormTheme.Colors.trainingGreen
                    )
                    
                    DetailStatCard(
                        title: "Total Reps",
                        value: "\(workout.totalReps)",
                        icon: "number.circle.fill",
                        color: EverFormTheme.Colors.warningAmber
                    )
                }
            }
            
            // Date
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(EverFormTheme.Colors.textSecondary)
                
                Text(workout.formattedDate)
                    .font(EverFormTheme.Typography.body)
                    .foregroundColor(EverFormTheme.Colors.textSecondary)
            }
            .padding(.top, 8)
        }
    }
}

// MARK: - Exercise Breakdown Section

struct ExerciseBreakdownSection: View {
    let exercises: [ExerciseSummary]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Exercise Breakdown")
                .font(EverFormTheme.Typography.sectionTitle)
                .foregroundColor(EverFormTheme.Colors.textPrimary)
            
            VStack(spacing: 8) {
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes")
                .font(EverFormTheme.Typography.sectionTitle)
                .foregroundColor(EverFormTheme.Colors.textPrimary)
            
            Text(notes)
                .font(EverFormTheme.Typography.body)
                .foregroundColor(EverFormTheme.Colors.textPrimary)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(EverFormTheme.Colors.card)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(EverFormTheme.Colors.cardStroke, lineWidth: 1)
                )
        }
    }
}

// MARK: - Components

struct DetailStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        EFCard {
            VStack(spacing: 8) {
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
                        .font(EverFormTheme.Typography.cardTitle)
                        .foregroundColor(EverFormTheme.Colors.textPrimary)
                    
                    Text(title)
                        .font(EverFormTheme.Typography.caption)
                        .foregroundColor(EverFormTheme.Colors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct ExerciseDetailCard: View {
    let exercise: ExerciseSummary
    
    var body: some View {
        EFCard {
            VStack(alignment: .leading, spacing: 8) {
                Text(exercise.exerciseName)
                    .font(EverFormTheme.Typography.cardTitle)
                    .foregroundColor(EverFormTheme.Colors.textPrimary)
                
                HStack(spacing: 12) {
                    StatPill(label: "Sets", value: "\(exercise.completedSets)", color: EverFormTheme.Colors.trainingGreen)
                    StatPill(label: "Reps", value: "\(exercise.totalReps)", color: EverFormTheme.Colors.infoBlue)
                    if exercise.totalVolume > 0 {
                        StatPill(label: "Volume", value: String(format: "%.0f kg", exercise.totalVolume), color: EverFormTheme.Colors.successGreen)
                    }
                    Spacer()
                }
                
                if let bestSet = exercise.bestSet {
                    HStack {
                        Text("Best set:")
                            .font(EverFormTheme.Typography.caption)
                            .foregroundColor(EverFormTheme.Colors.textSecondary)
                        Text(bestSet.displayText)
                            .font(EverFormTheme.Typography.label)
                            .foregroundColor(EverFormTheme.Colors.textPrimary)
                        Spacer()
                    }
                }
            }
        }
    }
}

struct StatPill: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(EverFormTheme.Typography.caption)
                .foregroundColor(color)
            Text(value)
                .font(EverFormTheme.Typography.label)
                .foregroundColor(EverFormTheme.Colors.textPrimary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}
