//
//  TrainingService.swift
//  EverForm
//
//  Ephemeral workout state management
//  Assumptions: In-memory only, simple set/rep tracking
//

import Foundation
import SwiftUI

struct WorkoutExercise: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let targetSets: Int
    let targetReps: String
    var completedSets: Int = 0
    var isCompleted: Bool { completedSets >= targetSets }
}

struct WorkoutPlan: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let estimatedDuration: Int // minutes
    var exercises: [WorkoutExercise]
}

struct WorkoutSummary {
    let title: String
    let duration: TimeInterval
    let exercisesCompleted: Int
    let totalExercises: Int
    let date: Date
}

@Observable
final class TrainingService {
    var currentWorkout: WorkoutPlan?
    var workoutStartTime: Date?
    var isWorkoutActive: Bool { currentWorkout != nil && workoutStartTime != nil }
    var restTimer: Int = 0 // seconds
    var isResting: Bool = false
    
    // Mock workout plans
    private let workoutPlans = [
        WorkoutPlan(
            title: "Upper Power",
            estimatedDuration: 75,
            exercises: [
                WorkoutExercise(name: "Bench Press", targetSets: 4, targetReps: "6-8"),
                WorkoutExercise(name: "Pull-ups", targetSets: 4, targetReps: "8-10"),
                WorkoutExercise(name: "Overhead Press", targetSets: 3, targetReps: "6-8"),
                WorkoutExercise(name: "Barbell Rows", targetSets: 3, targetReps: "8-10"),
                WorkoutExercise(name: "Dips", targetSets: 3, targetReps: "10-12"),
                WorkoutExercise(name: "Face Pulls", targetSets: 3, targetReps: "12-15")
            ]
        ),
        WorkoutPlan(
            title: "Lower Strength",
            estimatedDuration: 60,
            exercises: [
                WorkoutExercise(name: "Squats", targetSets: 4, targetReps: "5-6"),
                WorkoutExercise(name: "Romanian Deadlifts", targetSets: 3, targetReps: "8-10"),
                WorkoutExercise(name: "Bulgarian Split Squats", targetSets: 3, targetReps: "10-12"),
                WorkoutExercise(name: "Hip Thrusts", targetSets: 3, targetReps: "12-15"),
                WorkoutExercise(name: "Calf Raises", targetSets: 3, targetReps: "15-20"),
                WorkoutExercise(name: "Plank", targetSets: 3, targetReps: "60s")
            ]
        )
    ]
    
    init() {
        DebugLog.info("TrainingService initialized")
    }
    
    func getTodaysWorkout() -> WorkoutPlan {
        // Simple alternating logic based on day of week
        let dayOfWeek = Calendar.current.component(.weekday, from: Date())
        let isUpperDay = dayOfWeek % 2 == 0
        return isUpperDay ? workoutPlans[0] : workoutPlans[1]
    }
    
    func startWorkout(_ workout: WorkoutPlan? = nil) {
        let plan = workout ?? getTodaysWorkout()
        currentWorkout = plan
        workoutStartTime = Date()
        
        DebugLog.info("Started workout: \(plan.title)")
        TelemetryService.shared.track("qa_tap", properties: ["action": "start_workout"])
        TelemetryService.shared.track("workout_started", properties: ["title": plan.title])
    }
    
    func completeSet(for exerciseId: UUID) {
        guard let workout = currentWorkout else { return }
        
        if let index = workout.exercises.firstIndex(where: { $0.id == exerciseId }) {
            let exercise = workout.exercises[index]
            if exercise.completedSets < exercise.targetSets {
                currentWorkout?.exercises[index].completedSets += 1
                
                DebugLog.info("Completed set for \(exercise.name): \(exercise.completedSets)/\(exercise.targetSets)")
                
                // Start rest timer if not the last set
                if exercise.completedSets < exercise.targetSets {
                    startRestTimer()
                }
            }
        }
    }
    
    func startRestTimer(duration: Int = 90) {
        restTimer = duration
        isResting = true
        
        // Simple countdown (in real app would use Timer)
        DebugLog.info("Rest timer started: \(duration)s")
    }
    
    func skipRest() {
        restTimer = 0
        isResting = false
        DebugLog.info("Rest skipped")
    }
    
    func finishWorkout() -> WorkoutSummary? {
        guard let workout = currentWorkout,
              let startTime = workoutStartTime else { return nil }
        
        let duration = Date().timeIntervalSince(startTime)
        let completedExercises = workout.exercises.filter { $0.isCompleted }.count
        
        let summary = WorkoutSummary(
            title: workout.title,
            duration: duration,
            exercisesCompleted: completedExercises,
            totalExercises: workout.exercises.count,
            date: Date()
        )
        
        // Reset state
        currentWorkout = nil
        workoutStartTime = nil
        restTimer = 0
        isResting = false
        
        DebugLog.info("Workout completed: \(summary.title) - \(completedExercises)/\(summary.totalExercises) exercises")
        TelemetryService.shared.track("qa_complete", properties: ["action": "workout"])
        TelemetryService.shared.track("workout_completed", properties: [
            "title": summary.title,
            "duration_minutes": "\(Int(duration / 60))",
            "exercises_completed": "\(completedExercises)"
        ])
        
        return summary
    }
    
    func cancelWorkout() {
        DebugLog.info("Workout cancelled")
        currentWorkout = nil
        workoutStartTime = nil
        restTimer = 0
        isResting = false
    }
}
