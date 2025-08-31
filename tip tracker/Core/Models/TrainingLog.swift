//
//  TrainingLog.swift
//  EverForm
//
//  Training session logging models for workout tracking
//  Applied: P-ARCH, C-SIMPLE, R-LOGS
//

import Foundation

struct SetEntry: Identifiable, Codable {
    let id: UUID
    let exerciseId: UUID
    let setIndex: Int
    let reps: Int
    let weight: Double?
    let rpe: Double?
    let timestamp: Date
    
    init(
        id: UUID = UUID(),
        exerciseId: UUID,
        setIndex: Int,
        reps: Int,
        weight: Double? = nil,
        rpe: Double? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.setIndex = setIndex
        self.reps = reps
        self.weight = weight
        self.rpe = rpe
        self.timestamp = timestamp
    }
}

struct WorkoutLog: Identifiable, Codable {
    let id: UUID
    let workoutId: UUID
    let title: String
    let startedAt: Date
    let finishedAt: Date?
    let notes: String?
    let sets: [SetEntry]
    
    init(
        id: UUID = UUID(),
        workoutId: UUID,
        title: String,
        startedAt: Date,
        finishedAt: Date? = nil,
        notes: String? = nil,
        sets: [SetEntry] = []
    ) {
        self.id = id
        self.workoutId = workoutId
        self.title = title
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.notes = notes
        self.sets = sets
    }
    
    /// Total volume calculation (sum of reps × weight)
    var totalVolume: Double {
        sets.compactMap { set in
            guard let weight = set.weight else { return nil }
            return Double(set.reps) * weight
        }.reduce(0, +)
    }
    
    /// Duration of workout session
    var duration: TimeInterval? {
        guard let finishedAt = finishedAt else { return nil }
        return finishedAt.timeIntervalSince(startedAt)
    }
}

struct WorkoutSession: Codable {
    let workout: Workout
    let startedAt: Date
    var sets: [SetEntry]
    var currentRestUntil: Date?
    
    init(
        workout: Workout,
        startedAt: Date = Date(),
        sets: [SetEntry] = [],
        currentRestUntil: Date? = nil
    ) {
        self.workout = workout
        self.startedAt = startedAt
        self.sets = sets
        self.currentRestUntil = currentRestUntil
    }
    
    /// Get sets for a specific exercise block
    func sets(for exerciseBlock: ExerciseBlock) -> [SetEntry] {
        sets.filter { $0.exerciseId == exerciseBlock.exercise.id }
            .sorted { $0.setIndex < $1.setIndex }
    }
    
    /// Get next set index for an exercise
    func nextSetIndex(for exerciseBlock: ExerciseBlock) -> Int {
        let exerciseSets = sets(for: exerciseBlock)
        return (exerciseSets.map(\.setIndex).max() ?? 0) + 1
    }
    
    /// Duration since workout started
    var elapsedTime: TimeInterval {
        Date().timeIntervalSince(startedAt)
    }
}


