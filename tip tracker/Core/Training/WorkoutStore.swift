//
//  WorkoutStore.swift
//  EverForm
//
//  Central workout session management with persistence and rest timer
//  Applied: S-OBS1, P-ARCH, C-SIMPLE, R-LOGS
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class WorkoutStore {
    // MARK: - State
    private(set) var activeSnapshot: WorkoutSessionSnapshot?
    private(set) var prService = PRService()
    private let backend = BackendClient.shared
    
    // Rest timer
    private var restTimer: Timer?
    private(set) var isRestTimerActive: Bool = false
    
    init() {
        DebugLog.info("WorkoutStore initialized")
        
        // Load active session on startup
        Task {
            await loadActiveSession()
        }
    }
    
    deinit {
        // Note: Cannot access main actor properties from deinit
        // Timer will be cleaned up automatically when the object is deallocated
    }
    
    // MARK: - Private Helpers
    
    private func playLightHaptic() async {
        await MainActor.run {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.prepare()
            impact.impactOccurred()
        }
    }
    
    private func playMediumHaptic() async {
        await MainActor.run {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.prepare()
            impact.impactOccurred()
        }
    }
    
    // MARK: - Computed Properties
    
    /// Whether there's an active workout
    var hasActiveWorkout: Bool {
        activeSnapshot != nil
    }
    
    /// Current exercise being performed
    var currentExercise: ExerciseSession? {
        activeSnapshot?.currentExercise
    }
    
    /// Whether currently in a rest period
    var isResting: Bool {
        activeSnapshot?.isResting ?? false
    }
    
    /// Remaining rest time in seconds
    var remainingRestSeconds: Int {
        activeSnapshot?.remainingRestSeconds ?? 0
    }
    
    /// Formatted remaining rest time
    var formattedRestTime: String {
        let seconds = remainingRestSeconds
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
    
    /// Workout progress (0.0 to 1.0)
    var workoutProgress: Double {
        activeSnapshot?.progressPercentage ?? 0.0
    }
    
    // MARK: - Session Management
    
    /// Start a new planned workout from TodayPlan
    func startPlannedWorkout(title: String) async {
        DebugLog.info("Starting planned workout: \(title)")
        
        // Create exercise sessions from templates
        let exerciseSessions = [
            ExerciseSession.from(template: .benchPress, setCount: 3, targetWeight: 60),
            ExerciseSession.from(template: .pullUps, setCount: 3),
            ExerciseSession.from(template: .overheadPress, setCount: 3, targetWeight: 40),
            ExerciseSession.from(template: .rows, setCount: 3, targetWeight: 50),
            ExerciseSession.from(template: .dips, setCount: 2),
            ExerciseSession.from(template: .facePulls, setCount: 2, targetWeight: 15)
        ]
        
        let snapshot = WorkoutSessionSnapshot(
            workoutId: UUID(), // Generate a new workout ID
            title: title,
            exercises: exerciseSessions
        )
        
        activeSnapshot = snapshot
        await persistActiveSession()
        
        TelemetryService.shared.track("workout_start", properties: [
            "title": title,
            "exercise_count": exerciseSessions.count
        ])
    }
    
    /// Log a set for the specified exercise
    func logSet(for exerciseId: UUID, setIndex: Int, reps: Int, weight: Double?, rpe: Double?) async {
        guard var snapshot = activeSnapshot else {
            DebugLog.info("No active workout to log set to")
            return
        }
        
        // Create set log
        let setLog = SetLog(
            reps: reps,
            weight: weight,
            rpe: rpe != nil ? Int(rpe!) : nil
        )
        
        // Add to snapshot
        snapshot.addSetLog(setLog, to: exerciseId)
        
        // Check for PR
        if let exercise = snapshot.exercises.first(where: { $0.id == exerciseId }),
           let weight = weight {
            let pr = prService.checkForPR(
                exerciseName: exercise.template.name,
                weight: weight,
                reps: reps
            )
            
            if pr != nil {
                // TODO: Show PR celebration UI
                DebugLog.info("🎉 New PR!")
            }
        }
        
        // Start rest timer based on exercise template
        if let exercise = snapshot.exercises.first(where: { $0.id == exerciseId }) {
            let restDuration = exercise.template.defaultRestSec
            snapshot.startRest(durationSeconds: restDuration)
            startRestTimer()
        }
        
        activeSnapshot = snapshot
        await persistActiveSession()
        
        // Haptic feedback
        await playLightHaptic()
        
        TelemetryService.shared.track("set_logged", properties: [
            "exercise": snapshot.exercises.first(where: { $0.id == exerciseId })?.template.name ?? "unknown",
            "reps": reps,
            "weight": weight ?? 0,
            "rpe": rpe ?? 0
        ])
        
        DebugLog.info("Logged set: \(reps) reps @ \(weight ?? 0)kg")
    }
    
    /// Skip a set for the specified exercise
    func skipSet(for exerciseId: UUID, setIndex: Int) async {
        DebugLog.info("Skipped set \(setIndex) for exercise \(exerciseId)")
        // For now, just log the skip - could add skip tracking later
        
        TelemetryService.shared.track("set_skipped", properties: [
            "exercise_id": exerciseId.uuidString,
            "set_index": setIndex
        ])
    }
    
    /// Move to next exercise
    func nextExercise() async {
        guard var snapshot = activeSnapshot else { return }
        
        snapshot.moveToNextExercise()
        activeSnapshot = snapshot
        await persistActiveSession()
        
        DebugLog.info("Moved to next exercise")
    }
    
    /// Move to previous exercise
    func previousExercise() async {
        guard var snapshot = activeSnapshot else { return }
        
        snapshot.moveToPreviousExercise()
        activeSnapshot = snapshot
        await persistActiveSession()
        
        DebugLog.info("Moved to previous exercise")
    }
    
    /// End the current workout session
    func endSession(save: Bool) async -> WorkoutHistorySummary? {
        guard let snapshot = activeSnapshot else {
            DebugLog.info("No active workout to end")
            return nil
        }
        
        stopRestTimer()
        
        if save {
            let summary = WorkoutHistorySummary.from(snapshot: snapshot)
            await WorkoutPersistence.shared.appendHistory(summary)
            Task { await sendToBackend(summary: summary) }
            
            TelemetryService.shared.track("workout_finish_saved", properties: [
                "title": summary.title,
                "duration_min": summary.durationSec / 60,
                "total_sets": summary.totalSets,
                "total_volume": summary.totalVolumeKg
            ])
            
            DebugLog.info("Workout saved: \(summary.title)")
            
            // Clear active session
            activeSnapshot = nil
            await WorkoutPersistence.shared.clearActive()
            
            return summary
        } else {
            TelemetryService.shared.track("workout_finish_discarded")
            DebugLog.info("Workout discarded: \(snapshot.title)")
            
            // Clear active session
            activeSnapshot = nil
            await WorkoutPersistence.shared.clearActive()
            
            return nil
        }
    }
    
    // MARK: - Rest Timer Management
    
    private func startRestTimer() {
        stopRestTimer() // Clear any existing timer
        
        isRestTimerActive = true
        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.tickRestTimer()
            }
        }
        
        TelemetryService.shared.track("rest_start", properties: [
            "duration": remainingRestSeconds
        ])
        
        DebugLog.info("Started rest timer: \(remainingRestSeconds)s")
    }
    
    private func stopRestTimer() {
        restTimer?.invalidate()
        restTimer = nil
        isRestTimerActive = false
    }
    
    @MainActor
    private func tickRestTimer() async {
        guard let snapshot = activeSnapshot else {
            stopRestTimer()
            return
        }
        
        // Check if rest period is over
        if !snapshot.isResting {
            stopRestTimer()
            
            // Rest period completed - show ready notification
            await playMediumHaptic()
            
            // TODO: Show "Ready" toast notification
            
            TelemetryService.shared.track("rest_done")
            DebugLog.info("Rest timer completed - Ready!")
        }
        
        // Update snapshot (this will trigger UI updates via @Observable)
        activeSnapshot = snapshot
    }
    
    /// Manually clear rest timer
    func clearRest() async {
        guard var snapshot = activeSnapshot else { return }
        
        snapshot.clearRest()
        activeSnapshot = snapshot
        await persistActiveSession()
        
        stopRestTimer()
        DebugLog.info("Rest timer cleared manually")
    }
    
    // MARK: - Backend sync
    private func sendToBackend(summary: WorkoutHistorySummary) async {
        let formatter = ISO8601DateFormatter()
        let payload = BackendTrainingSessionRequest(
            title: summary.title,
            status: "completed",
            durationMinutes: Int(summary.durationSec / 60),
            performedAt: formatter.string(from: summary.date),
            notes: nil,
            sets: summary.exerciseSummaries.flatMap { exercise in
                let sets: [SetSummary]
                if let best = exercise.bestSet {
                    sets = [best]
                } else if exercise.totalReps > 0 {
                    // Provide at least a single aggregate set when we have rep counts but no detailed set info
                    sets = [SetSummary(reps: exercise.totalReps, weight: nil, rpe: nil)]
                } else {
                    sets = []
                }
                
                return sets.map { set in
                    BackendTrainingSetRequest(
                        exercise: exercise.exerciseName,
                        reps: Int(set.reps),
                        weight: set.weight,
                        rpe: set.rpe,
                        notes: nil
                    )
                }
            }
        )
        
        do {
            let _: BackendTrainingSession = try await backend.post("training/sessions", body: payload)
        } catch {
            DebugLog.info("WorkoutStore: failed to persist session to backend \(error)")
        }
    }
    
    // MARK: - Persistence
    
    private func loadActiveSession() async {
        if let snapshot = await WorkoutPersistence.shared.loadActive() {
            activeSnapshot = snapshot
            
            // If there was an active rest period, restart the timer
            if snapshot.isResting {
                startRestTimer()
            }
            
            DebugLog.info("Loaded active session: \(snapshot.title)")
        }
    }
    
    private func persistActiveSession() async {
        guard let snapshot = activeSnapshot else { return }
        await WorkoutPersistence.shared.saveActive(snapshot)
    }
}

// MARK: - Backend DTOs
private struct BackendTrainingSessionRequest: Codable {
    let title: String
    let status: String
    let durationMinutes: Int?
    let performedAt: String?
    let notes: String?
    let sets: [BackendTrainingSetRequest]
}

private struct BackendTrainingSetRequest: Codable {
    let exercise: String
    let reps: Int
    let weight: Double?
    let rpe: Double?
    let notes: String?
}
