//
//  Workout.swift
//  EverForm
//
//  Workout structure and exercise blocks for training sessions
//  Applied: P-ARCH, C-SIMPLE, R-LOGS
//

import Foundation

struct Workout: Identifiable, Codable {
    let id: UUID
    let title: String
    let estDurationMin: Int
    let exercises: [ExerciseBlock]
    
    init(
        id: UUID = UUID(),
        title: String,
        estDurationMin: Int,
        exercises: [ExerciseBlock]
    ) {
        self.id = id
        self.title = title
        self.estDurationMin = estDurationMin
        self.exercises = exercises
    }
}

struct ExerciseBlock: Identifiable, Codable {
    let id: UUID
    let exercise: Exercise
    let targetSets: Int
    let targetReps: ClosedRange<Int>
    let targetWeight: Double?
    
    init(
        id: UUID = UUID(),
        exercise: Exercise,
        targetSets: Int,
        targetReps: ClosedRange<Int>,
        targetWeight: Double? = nil
    ) {
        self.id = id
        self.exercise = exercise
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.targetWeight = targetWeight
    }
}

// Note: ClosedRange already conforms to Codable in Swift standard library
// Custom conformance removed to avoid conflicts
