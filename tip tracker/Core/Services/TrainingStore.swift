//
//  TrainingStore.swift
//  EverForm
//
//  Training session management with persistence and workout tracking
//  Applied: S-OBS1, P-ARCH, C-SIMPLE, R-LOGS, SEC-SAFE
//

import Foundation
import SwiftUI

@Observable
final class TrainingStore {
    private(set) var activeSession: WorkoutSession?
    private(set) var workoutLogs: [WorkoutLog] = []
    
    private let userDefaults = UserDefaults.standard
    private let activeSessionKey = "training.activeSession"
    private let logsKey = "training.logs"
    
    init() {
        DebugLog.info("TrainingStore initialized")
        loadPersistedData()
    }
    
    // MARK: - Session Management
    
    /// Start a new workout session
    func start(workout: Workout) {
        DebugLog.info("Starting workout: \(workout.title)")
        
        // End any existing session first
        if activeSession != nil {
            DebugLog.info("Ending existing session before starting new one")
        }
        
        let session = WorkoutSession(workout: workout)
        activeSession = session
        persistActiveSession()
        
        TelemetryService.shared.track("workout_started", properties: [
            "workout_id": workout.id.uuidString,
            "workout_title": workout.title,
            "exercise_count": workout.exercises.count
        ])
    }
    
    /// End current workout session and create log
    func end(notes: String? = nil) -> WorkoutLog? {
        guard let session = activeSession else {
            DebugLog.info("No active session to end")
            return nil
        }
        
        DebugLog.info("Ending workout session: \(session.workout.title)")
        
        let workoutLog = WorkoutLog(
            workoutId: session.workout.id,
            title: session.workout.title,
            startedAt: session.startedAt,
            finishedAt: Date(),
            notes: notes,
            sets: session.sets
        )
        
        // Add to logs and persist
        workoutLogs.append(workoutLog)
        persistLogs()
        
        // Clear active session
        activeSession = nil
        clearActiveSession()
        
        TelemetryService.shared.track("workout_completed", properties: [
            "workout_id": session.workout.id.uuidString,
            "duration_minutes": Int((workoutLog.duration ?? 0) / 60),
            "total_sets": session.sets.count,
            "total_volume": workoutLog.totalVolume
        ])
        
        return workoutLog
    }
    
    /// Add a set to the current session
    func addSet(
        for exerciseBlock: ExerciseBlock,
        reps: Int,
        weight: Double? = nil,
        rpe: Double? = nil
    ) {
        guard var session = activeSession else {
            DebugLog.info("No active session to add set to")
            return
        }
        
        let setIndex = session.nextSetIndex(for: exerciseBlock)
        let setEntry = SetEntry(
            exerciseId: exerciseBlock.exercise.id,
            setIndex: setIndex,
            reps: reps,
            weight: weight,
            rpe: rpe
        )
        
        session.sets.append(setEntry)
        activeSession = session
        persistActiveSession()
        
        DebugLog.info("Added set for \(exerciseBlock.exercise.name): \(reps) reps @ \(weight ?? 0)kg, RPE: \(rpe ?? 0)")
        
        TelemetryService.shared.track("training_set_logged", properties: [
            "exercise_name": exerciseBlock.exercise.name,
            "reps": reps,
            "weight": weight ?? 0,
            "rpe": rpe ?? 0
        ])
    }
    
    /// Undo the last set entry
    func undoLastSet() {
        guard var session = activeSession, !session.sets.isEmpty else {
            DebugLog.info("No sets to undo")
            return
        }
        
        let removedSet = session.sets.removeLast()
        activeSession = session
        persistActiveSession()
        
        DebugLog.info("Undid last set: \(removedSet.reps) reps")
        
        TelemetryService.shared.track("training_set_undone", properties: [
            "exercise_id": removedSet.exerciseId.uuidString
        ])
    }
    
    /// Resume session if any exists
    func resumeIfAny() {
        // Data is loaded in init, so this is mostly for explicit resume calls
        if activeSession != nil {
            DebugLog.info("Resuming existing workout session")
        }
    }
    
    // MARK: - Persistence
    
    private func loadPersistedData() {
        // Load active session
        if let sessionData = userDefaults.data(forKey: activeSessionKey) {
            do {
                activeSession = try JSONDecoder().decode(WorkoutSession.self, from: sessionData)
                DebugLog.info("Loaded active session: \(activeSession?.workout.title ?? "unknown")")
            } catch {
                DebugLog.info("Failed to decode active session: \(error)")
                clearActiveSession()
            }
        }
        
        // Load workout logs
        if let logsData = userDefaults.data(forKey: logsKey) {
            do {
                workoutLogs = try JSONDecoder().decode([WorkoutLog].self, from: logsData)
                DebugLog.info("Loaded \(workoutLogs.count) workout logs")
            } catch {
                DebugLog.info("Failed to decode workout logs: \(error)")
                workoutLogs = []
            }
        }
    }
    
    private func persistActiveSession() {
        guard let session = activeSession else {
            clearActiveSession()
            return
        }
        
        do {
            let data = try JSONEncoder().encode(session)
            userDefaults.set(data, forKey: activeSessionKey)
            DebugLog.info("Persisted active session")
        } catch {
            DebugLog.info("Failed to persist active session: \(error)")
        }
    }
    
    private func clearActiveSession() {
        userDefaults.removeObject(forKey: activeSessionKey)
        DebugLog.info("Cleared active session")
    }
    
    private func persistLogs() {
        do {
            let data = try JSONEncoder().encode(workoutLogs)
            userDefaults.set(data, forKey: logsKey)
            DebugLog.info("Persisted \(workoutLogs.count) workout logs")
        } catch {
            DebugLog.info("Failed to persist workout logs: \(error)")
        }
    }
    
    // MARK: - Computed Properties
    
    /// Whether there's an active workout session
    var hasActiveSession: Bool {
        activeSession != nil
    }
    
    /// Time elapsed since workout started (formatted)
    var sessionElapsedTime: String {
        guard let session = activeSession else { return "0:00" }
        let elapsed = Int(session.elapsedTime)
        let minutes = elapsed / 60
        let seconds = elapsed % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}


