//
//  WorkoutSummary.swift
//  EverForm
//
//  Completed workout summary for history and analytics
//  Applied: P-ARCH, C-SIMPLE, R-LOGS
//

import Foundation

struct WorkoutHistorySummary: Identifiable, Codable {
    let id: UUID
    let date: Date
    let title: String
    let totalVolumeKg: Double
    let totalSets: Int
    let totalReps: Int
    let durationSec: Int
    let notes: String?
    let exerciseSummaries: [ExerciseSummary]
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        title: String,
        totalVolumeKg: Double,
        totalSets: Int,
        totalReps: Int,
        durationSec: Int,
        notes: String? = nil,
        exerciseSummaries: [ExerciseSummary] = []
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.totalVolumeKg = totalVolumeKg
        self.totalSets = totalSets
        self.totalReps = totalReps
        self.durationSec = durationSec
        self.notes = notes
        self.exerciseSummaries = exerciseSummaries
    }
    
    /// Formatted duration (e.g., "45:30")
    var formattedDuration: String {
        let minutes = durationSec / 60
        let seconds = durationSec % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Formatted date for display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    /// Short date for list display
    var shortFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    /// Formatted volume display
    var formattedVolume: String {
        if totalVolumeKg >= 1000 {
            return String(format: "%.1fk kg", totalVolumeKg / 1000)
        } else {
            return String(format: "%.0f kg", totalVolumeKg)
        }
    }
}

// MARK: - Exercise Summary
struct ExerciseSummary: Identifiable, Codable {
    let id: UUID
    let exerciseName: String
    let completedSets: Int
    let totalReps: Int
    let totalVolume: Double
    let bestSet: SetSummary?
    
    init(
        id: UUID = UUID(),
        exerciseName: String,
        completedSets: Int,
        totalReps: Int,
        totalVolume: Double,
        bestSet: SetSummary? = nil
    ) {
        self.id = id
        self.exerciseName = exerciseName
        self.completedSets = completedSets
        self.totalReps = totalReps
        self.totalVolume = totalVolume
        self.bestSet = bestSet
    }
}

// MARK: - Set Summary
struct SetSummary: Codable {
    let reps: Int
    let weight: Double?
    let rpe: Double?
    
    var displayText: String {
        var text = "\(reps) reps"
        if let weight = weight {
            text += " @ \(String(format: "%.0f", weight))kg"
        }
        if let rpe = rpe {
            text += " RPE \(String(format: "%.1f", rpe))"
        }
        return text
    }
}

// MARK: - Factory Methods
extension WorkoutHistorySummary {
    /// Create summary from completed workout session
    static func from(snapshot: WorkoutSessionSnapshot, notes: String? = nil) -> WorkoutHistorySummary {
        let durationSec = snapshot.endTime != nil ? 
            Int(snapshot.endTime!.timeIntervalSince(snapshot.startTime)) : 
            Int(Date().timeIntervalSince(snapshot.startTime))
        
        // Create exercise summaries
        let exerciseSummaries = snapshot.exercises.map { exercise in
            let bestSet = exercise.completedSets.max { a, b in
                // Compare by volume, then by reps
                if let aWeight = a.weight, let bWeight = b.weight {
                    return (aWeight * Double(a.reps)) < (bWeight * Double(b.reps))
                } else {
                    return a.reps < b.reps
                }
            }
            
            return ExerciseSummary(
                exerciseName: exercise.exercise.name,
                completedSets: exercise.completedSets.count,
                totalReps: exercise.totalReps,
                totalVolume: exercise.totalVolume,
                bestSet: bestSet.map { SetSummary(reps: $0.reps, weight: $0.weight, rpe: $0.rpe.map(Double.init)) }
            )
        }
        
        return WorkoutHistorySummary(
            date: snapshot.startedAt,
            title: snapshot.title,
            totalVolumeKg: snapshot.totalVolume,
            totalSets: snapshot.totalCompletedSets,
            totalReps: snapshot.totalReps,
            durationSec: durationSec,
            notes: notes,
            exerciseSummaries: exerciseSummaries
        )
    }
}
