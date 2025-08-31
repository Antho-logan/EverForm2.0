//
//  WorkoutSession.swift
//  EverForm
//
//  Workout session models for active training sessions
//  Applied: P-ARCH, C-SIMPLE, R-LOGS, S-OBS1
//

import Foundation

// MARK: - Workout Session Snapshot
struct WorkoutSessionSnapshot: Identifiable, Codable {
    let id: UUID
    let workoutId: UUID
    let title: String
    let startTime: Date
    var endTime: Date?
    var exercises: [ExerciseSession]
    var isCompleted: Bool
    var currentExerciseIndex: Int
    var isResting: Bool
    var remainingRestSeconds: Int
    
    init(
        id: UUID = UUID(),
        workoutId: UUID,
        title: String,
        startTime: Date = Date(),
        endTime: Date? = nil,
        exercises: [ExerciseSession] = [],
        isCompleted: Bool = false,
        currentExerciseIndex: Int = 0,
        isResting: Bool = false,
        remainingRestSeconds: Int = 0
    ) {
        self.id = id
        self.workoutId = workoutId
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
        self.exercises = exercises
        self.isCompleted = isCompleted
        self.currentExerciseIndex = currentExerciseIndex
        self.isResting = isResting
        self.remainingRestSeconds = remainingRestSeconds
    }
    
    // Computed properties for WorkoutSummary compatibility
    var startedAt: Date { startTime }
    var totalVolume: Double {
        exercises.reduce(0) { $0 + $1.totalVolume }
    }
    var totalCompletedSets: Int {
        exercises.reduce(0) { $0 + $1.completedSets.count }
    }
    var totalReps: Int {
        exercises.reduce(0) { $0 + $1.totalReps }
    }
    
    // Current exercise
    var currentExercise: ExerciseSession? {
        guard currentExerciseIndex < exercises.count else { return nil }
        return exercises[currentExerciseIndex]
    }
    
    // Progress percentage
    var progressPercentage: Double {
        guard !exercises.isEmpty else { return 0.0 }
        let completedExercises = exercises.filter { $0.isCompleted }.count
        return Double(completedExercises) / Double(exercises.count)
    }
    
    // Formatted elapsed time
    var formattedElapsedTime: String {
        let elapsed = Date().timeIntervalSince(startTime)
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // Mutating methods
    mutating func addSetLog(_ setResult: SetResult, to exerciseId: UUID) {
        if let index = exercises.firstIndex(where: { $0.id == exerciseId }) {
            exercises[index].completedSets.append(setResult)
        }
    }
    
    mutating func startRest(durationSeconds: Int) {
        isResting = true
        remainingRestSeconds = durationSeconds
    }
    
    mutating func clearRest() {
        isResting = false
        remainingRestSeconds = 0
    }
    
    mutating func moveToNextExercise() {
        if currentExerciseIndex < exercises.count - 1 {
            currentExerciseIndex += 1
        }
    }
    
    mutating func moveToPreviousExercise() {
        if currentExerciseIndex > 0 {
            currentExerciseIndex -= 1
        }
    }
}

// MARK: - Exercise Session
struct ExerciseSession: Identifiable, Codable {
    let id: UUID
    let exercise: Exercise
    let targetSets: Int
    let targetReps: ClosedRange<Int>
    let targetWeight: Double?
    var completedSets: [SetResult]
    var isCompleted: Bool
    
    init(
        id: UUID = UUID(),
        exercise: Exercise,
        targetSets: Int,
        targetReps: ClosedRange<Int>,
        targetWeight: Double? = nil,
        completedSets: [SetResult] = [],
        isCompleted: Bool = false
    ) {
        self.id = id
        self.exercise = exercise
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.targetWeight = targetWeight
        self.completedSets = completedSets
        self.isCompleted = isCompleted
    }
    
    static func from(template: Exercise, setCount: Int, targetWeight: Double? = nil) -> ExerciseSession {
        return ExerciseSession(
            exercise: template,
            targetSets: setCount,
            targetReps: 8...12,
            targetWeight: targetWeight
        )
    }
    
    // Template compatibility (for backward compatibility)
    var template: Exercise { exercise }
    
    // Computed properties for WorkoutSummary compatibility
    var totalReps: Int {
        completedSets.reduce(0) { $0 + $1.reps }
    }
    var totalVolume: Double {
        completedSets.reduce(0) { total, set in
            total + (Double(set.reps) * (set.weight ?? 0))
        }
    }
}

// MARK: - Set Result
struct SetResult: Identifiable, Codable {
    let id: UUID
    let reps: Int
    let weight: Double?
    let restSeconds: Int?
    let completedAt: Date
    let rpe: Int? // Rate of Perceived Exertion
    
    init(
        id: UUID = UUID(),
        reps: Int,
        weight: Double? = nil,
        restSeconds: Int? = nil,
        completedAt: Date = Date(),
        rpe: Int? = nil
    ) {
        self.id = id
        self.reps = reps
        self.weight = weight
        self.restSeconds = restSeconds
        self.completedAt = completedAt
        self.rpe = rpe
    }
}

// MARK: - PR Service
@Observable
final class PRService {
    private var personalRecords: [UUID: PersonalRecord] = [:]
    
    init() {
        DebugLog.info("PRService initialized") // R-LOGS
    }
    
    func getPersonalRecord(for exerciseId: UUID) -> PersonalRecord? {
        return personalRecords[exerciseId]
    }
    
    func updatePersonalRecord(_ record: PersonalRecord) {
        personalRecords[record.exerciseId] = record
        DebugLog.info("PR updated for exercise: \(record.exerciseId)") // R-LOGS
    }
    
    func checkForPR(exerciseName: String, weight: Double, reps: Int) -> PersonalRecord? {
        // Simple PR check - could be enhanced with more sophisticated logic
        let exerciseId = UUID() // In real implementation, would map exercise name to ID
        let newRecord = PersonalRecord(
            exerciseId: exerciseId,
            weight: weight,
            reps: reps
        )
        
        if let existing = personalRecords[exerciseId] {
            // Check if this is a new PR (higher weight or same weight with more reps)
            if weight > existing.weight || (weight == existing.weight && reps > existing.reps) {
                updatePersonalRecord(newRecord)
                return newRecord
            }
        } else {
            // First time doing this exercise
            updatePersonalRecord(newRecord)
            return newRecord
        }
        
        return nil
    }
}

// MARK: - Personal Record
struct PersonalRecord: Identifiable, Codable {
    let id: UUID
    let exerciseId: UUID
    let weight: Double
    let reps: Int
    let achievedAt: Date
    
    init(
        id: UUID = UUID(),
        exerciseId: UUID,
        weight: Double,
        reps: Int,
        achievedAt: Date = Date()
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.weight = weight
        self.reps = reps
        self.achievedAt = achievedAt
    }
}

// MARK: - SetLog (alias for SetResult for backward compatibility)
typealias SetLog = SetResult

// MARK: - Workout Persistence
@Observable
final class WorkoutPersistence {
    static let shared = WorkoutPersistence()
    
    private let activeFilename = "active_workout.json"
    private let historyFilename = "workout_history.json"
    private let maxHistoryItems = 200
    
    private init() {
        DebugLog.info("WorkoutPersistence initialized") // R-LOGS
    }
    
    func saveActive(_ snapshot: WorkoutSessionSnapshot) async {
        do {
            try SafeFileIO.save(snapshot, to: activeFilename)
            DebugLog.info("Saved active workout session: \(snapshot.title)")
        } catch {
            DebugLog.info("Failed to save active workout: \(error.localizedDescription)")
            await MainActor.run {
                UX.Banner.show(message: "Failed to save workout session")
            }
        }
    }
    
    func loadActive() async -> WorkoutSessionSnapshot? {
        let snapshot = SafeFileIO.load(WorkoutSessionSnapshot.self, from: activeFilename)
        if let snapshot = snapshot {
            DebugLog.info("Loaded active workout session: \(snapshot.title)")
        } else {
            DebugLog.info("No active workout session found")
        }
        return snapshot
    }
    
    func clearActive() async {
        do {
            try SafeFileIO.deleteFile(activeFilename)
            DebugLog.info("Cleared active workout session")
        } catch {
            DebugLog.info("Failed to clear active workout: \(error.localizedDescription)")
        }
    }
    
    func appendHistory(_ summary: WorkoutHistorySummary) async {
        var history = SafeFileIO.load([WorkoutHistorySummary].self, from: historyFilename) ?? []
        history.insert(summary, at: 0)
        
        // Cap history to maxHistoryItems
        history = SafeFileIO.capHistory(history, maxCount: maxHistoryItems)
        
        do {
            try SafeFileIO.save(history, to: historyFilename)
            DebugLog.info("Appended workout to history: \(summary.title)")
        } catch {
            DebugLog.info("Failed to save workout history: \(error.localizedDescription)")
            await MainActor.run {
                UX.Banner.show(message: "Failed to save workout history")
            }
        }
    }
    
    func loadHistory(limit: Int) async -> [WorkoutHistorySummary] {
        let history = SafeFileIO.load([WorkoutHistorySummary].self, from: historyFilename) ?? []
        let limitedHistory = Array(history.prefix(limit))
        DebugLog.info("Loaded workout history: \(limitedHistory.count) items (limit: \(limit))")
        return limitedHistory
    }
}
