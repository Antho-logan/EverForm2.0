//
//  MockWorkouts.swift
//  EverForm
//
//  Mock workout data for development and testing
//  Applied: P-ARCH, C-SIMPLE, R-LOGS
//

import Foundation

struct MockWorkouts {
    /// Upper Power workout matching dashboard text
    static let hybridUpper = Workout(
        title: "Upper Power",
        estDurationMin: 75,
        exercises: [
            ExerciseBlock(
                exercise: .benchPress,
                targetSets: 3,
                targetReps: 8...12,
                targetWeight: 60.0
            ),
            ExerciseBlock(
                exercise: .pullUps,
                targetSets: 3,
                targetReps: 6...10,
                targetWeight: nil // Bodyweight
            ),
            ExerciseBlock(
                exercise: .overheadPress,
                targetSets: 3,
                targetReps: 8...12,
                targetWeight: 40.0
            ),
            ExerciseBlock(
                exercise: .rows,
                targetSets: 3,
                targetReps: 10...15,
                targetWeight: 50.0
            ),
            ExerciseBlock(
                exercise: .dips,
                targetSets: 2,
                targetReps: 8...12,
                targetWeight: nil // Bodyweight
            ),
            ExerciseBlock(
                exercise: .facePulls,
                targetSets: 2,
                targetReps: 15...20,
                targetWeight: 15.0
            )
        ]
    )
    
    /// Lower Power workout for variety
    static let lowerPower = Workout(
        title: "Lower Power",
        estDurationMin: 60,
        exercises: [
            ExerciseBlock(
                exercise: Exercise(name: "Squats", bodyPart: "Legs"),
                targetSets: 3,
                targetReps: 6...10,
                targetWeight: 80.0
            ),
            ExerciseBlock(
                exercise: Exercise(name: "Romanian Deadlifts", bodyPart: "Legs"),
                targetSets: 3,
                targetReps: 8...12,
                targetWeight: 70.0
            ),
            ExerciseBlock(
                exercise: Exercise(name: "Bulgarian Split Squats", bodyPart: "Legs"),
                targetSets: 2,
                targetReps: 10...15,
                targetWeight: 20.0
            ),
            ExerciseBlock(
                exercise: Exercise(name: "Calf Raises", bodyPart: "Legs"),
                targetSets: 3,
                targetReps: 15...20,
                targetWeight: 40.0
            )
        ]
    )
    
    /// All available mock workouts
    static let all: [Workout] = [
        hybridUpper,
        lowerPower
    ]
    
    /// Get default workout (matches dashboard)
    static var defaultWorkout: Workout {
        hybridUpper
    }
}


