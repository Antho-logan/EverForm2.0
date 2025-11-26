//
//  TrainingModels.swift
//  EverForm
//
//  Created by Gemini on 18/11/2025.
//  Updated by Assistant on 21/11/2025.
//

import Foundation
import SwiftUI

// MARK: - Enums

enum BodyFocus: String, CaseIterable, Identifiable {
    case upperBody = "Upper Body"
    case lowerBody = "Lower Body"
    case fullBody = "Full Body"
    case push = "Push"
    case pull = "Pull"
    case cardio = "Cardio"
    case mobility = "Mobility"
    case rest = "Rest"
    
    var id: String { rawValue }
}

enum TrainingStyle: String, CaseIterable, Identifiable {
    case strength = "Strength"
    case hypertrophy = "Hypertrophy"
    case cardio = "Cardio"
    case mobility = "Mobility"
    case conditioning = "Conditioning"
    case recovery = "Recovery"
    
    var id: String { rawValue }
}

enum MuscleGroup: String, CaseIterable, Identifiable {
    case quads, glutes, hamstrings, calves, legs
    case chest, back, shoulders, biceps, triceps, forearms
    case core, abs, obliques
    case cardio, fullBody, spine
    
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}

enum ExerciseDifficulty: String, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

// MARK: - Domain Models

struct TrainingDay: Identifiable {
    let id = UUID()
    let date: Date
    var isRestDay: Bool
    var focusTitle: String // "Lower Body Strength"
    var bodyFocus: BodyFocus
    var style: TrainingStyle
    var durationMinutes: Int
    var sections: [TrainingSection]
    var isCompleted: Bool = false
    var difficulty: ExerciseDifficulty = .intermediate
    
    // Helpers
    var label: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    var dayLetter: String {
        String(label.prefix(1))
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
        }
    }

struct TrainingSection: Identifiable {
    let id = UUID()
    var title: String // "Warm-Up", "Main Set", "Finisher"
    var exercises: [TrainingExercise]
}

struct TrainingExercise: Identifiable {
    let id = UUID()
    var name: String
    var sublabel: String? // "Spine, Core"
    var sets: Int?
    var reps: String? // "10", "8-12"
    var duration: String? // "30s", "2 min"
    var primaryMuscles: [MuscleGroup]
    var secondaryMuscles: [MuscleGroup]
    var difficulty: ExerciseDifficulty = .intermediate
    var videoURL: URL?
    
    // Detail content
    var tempo: String = "2-0-1-0"
    var rest: String = "60s"
    var breathing: String = "Exhale on exertion"
    var safety: String = "Keep core engaged"
    var technique: [String] = []
    var coachCue: String?
    
    // Display helper
    var volumeString: String {
        if let d = duration { return d }
        if let s = sets, let r = reps { return "\(s) sets × \(r)" }
        if let r = reps { return r }
        return ""
    }
}

// MARK: - Sample Data Provider

struct TrainingSampleData {
    static func generateWeek(startingFrom startDate: Date = Date()) -> [TrainingDay] {
        let calendar = Calendar.current
        // Adjust startDate to start of week (Monday) if needed, or just generate 7 days from today
        // For this mock, let's assume we generate a week surrounding today
        
        var days: [TrainingDay] = []
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startDate) {
                let day = createMockDay(for: date, index: i)
                days.append(day)
            }
        }
        return days
    }
    
    private static func createMockDay(for date: Date, index: Int) -> TrainingDay {
        // Simple 4-day split + Cardio + Rest logic
        // 0: Lower Body
        // 1: Upper Body Push
        // 2: Rest
        // 3: Upper Body Pull
        // 4: Shoulders & Abs
        // 5: Cardio
        // 6: Rest
        
        let weekday = Calendar.current.component(.weekday, from: date)
        // weekday 1 = Sunday. Let's align roughly with M-T-W-T-F-S-S logic
        
        // Determine type based on index for deterministic mock
        switch index % 7 {
        case 0: // Mon: Lower Body
            return TrainingDay(
                date: date,
                isRestDay: false,
                focusTitle: "Lower Body Strength",
                bodyFocus: .lowerBody,
                style: .strength,
                durationMinutes: 45,
                sections: [
                    TrainingSection(title: "Warm-Up", exercises: [
                        TrainingExercise(name: "World's Greatest Stretch", sublabel: "Hips, Thoracic", reps: "5/side", primaryMuscles: [.glutes, .back], secondaryMuscles: [.shoulders], coachCue: "Open chest towards the ceiling."),
                        TrainingExercise(name: "Glute Bridges", sublabel: "Activation", sets: 2, reps: "15", primaryMuscles: [.glutes], secondaryMuscles: [.hamstrings], coachCue: "Squeeze at the top.")
                    ]),
                    TrainingSection(title: "Main Set", exercises: [
                        TrainingExercise(name: "Goblet Squat", sublabel: "Quads", sets: 3, reps: "8-10", primaryMuscles: [.quads], secondaryMuscles: [.glutes, .core], coachCue: "Keep chest up, weight in heels."),
                        TrainingExercise(name: "Romanian Deadlift", sublabel: "Hamstrings", sets: 3, reps: "10-12", primaryMuscles: [.hamstrings], secondaryMuscles: [.glutes, .back], coachCue: "Hinge at hips, keep back flat.")
                    ]),
                    TrainingSection(title: "Finisher", exercises: [
                        TrainingExercise(name: "Calf Raises", sublabel: "Isolation", sets: 3, reps: "15", primaryMuscles: [.calves], secondaryMuscles: [], coachCue: "Full range of motion.")
                    ])
                ]
            )
        case 1: // Tue: Push
            return TrainingDay(
                date: date,
                isRestDay: false,
                focusTitle: "Push – Chest & Triceps",
                bodyFocus: .push,
                style: .hypertrophy,
                durationMinutes: 40,
                sections: [
                    TrainingSection(title: "Warm-Up", exercises: [
                        TrainingExercise(name: "Band Pull-Aparts", sublabel: "Shoulders", reps: "20", primaryMuscles: [.shoulders], secondaryMuscles: [.back], coachCue: "Squeeze shoulder blades.")
                    ]),
                    TrainingSection(title: "Main Set", exercises: [
                        TrainingExercise(name: "Dumbbell Bench Press", sublabel: "Chest", sets: 3, reps: "10-12", primaryMuscles: [.chest], secondaryMuscles: [.triceps], coachCue: "Control the descent."),
                        TrainingExercise(name: "Overhead Press", sublabel: "Shoulders", sets: 3, reps: "8-10", primaryMuscles: [.shoulders], secondaryMuscles: [.triceps], coachCue: "Brace core, press straight up.")
                    ])
                ]
            )
        case 2: // Wed: Rest
            return TrainingDay(
                date: date,
                isRestDay: true,
                focusTitle: "Rest & Recovery",
                bodyFocus: .rest,
                style: .recovery,
                durationMinutes: 0,
                sections: []
            )
        case 3: // Thu: Pull
            return TrainingDay(
                date: date,
                isRestDay: false,
                focusTitle: "Pull – Back & Biceps",
                bodyFocus: .pull,
                style: .strength,
                durationMinutes: 45,
                sections: [
                    TrainingSection(title: "Main Set", exercises: [
                        TrainingExercise(name: "Pull-Ups", sublabel: "Back", sets: 3, reps: "AMRAP", primaryMuscles: [.back], secondaryMuscles: [.biceps], coachCue: "Drive elbows down."),
                        TrainingExercise(name: "Single-Arm Row", sublabel: "Lats", sets: 3, reps: "10/side", primaryMuscles: [.back], secondaryMuscles: [.biceps], coachCue: "Pull to hip pocket.")
                    ])
                ]
            )
        case 4: // Fri: Shoulders/Abs
            return TrainingDay(
                date: date,
                isRestDay: false,
                focusTitle: "Shoulders & Abs",
                bodyFocus: .upperBody,
                style: .hypertrophy,
                durationMinutes: 35,
                sections: [
                    TrainingSection(title: "Main Set", exercises: [
                        TrainingExercise(name: "Lateral Raises", sublabel: "Delts", sets: 3, reps: "15", primaryMuscles: [.shoulders], secondaryMuscles: [], coachCue: "Lead with elbows."),
                        TrainingExercise(name: "Plank", sublabel: "Core", sets: 3, duration: "60s", primaryMuscles: [.core], secondaryMuscles: [.shoulders], coachCue: "Glutes tight, body straight.")
                    ])
                ]
            )
        case 5: // Sat: Cardio
            return TrainingDay(
                date: date,
                isRestDay: false,
                focusTitle: "Zone 2 Cardio",
                bodyFocus: .cardio,
                style: .cardio,
                durationMinutes: 30,
                sections: [
                    TrainingSection(title: "Session", exercises: [
                        TrainingExercise(name: "Treadmill / Jog", sublabel: "Steady State", duration: "30 min", primaryMuscles: [.cardio], secondaryMuscles: [.legs], coachCue: "Maintain conversation pace.")
                    ])
        ]
            )
        default: // Sun: Rest
            return TrainingDay(
            date: date,
                isRestDay: true,
                focusTitle: "Active Recovery",
                bodyFocus: .mobility,
                style: .mobility,
                durationMinutes: 20,
            sections: [
                    TrainingSection(title: "Routine", exercises: [
                        TrainingExercise(name: "Full Body Flow", sublabel: "Yoga", duration: "20 min", primaryMuscles: [.fullBody], secondaryMuscles: [], coachCue: "Breathe deeply.")
                    ])
                ]
            )
        }
    }
}

// MARK: - View Model

class TrainingViewModel: ObservableObject {
    @Published var schedule: [TrainingDay] = []
    @Published var selectedDay: TrainingDay?
    
    init() {
        // TODO: replace mock TrainingSampleData with AI-generated plan
        loadSchedule()
    }
    
    func loadSchedule() {
        let today = Date()
        // Generate days around today so user sees relevant days
        // Let's start 2 days ago
        let startDate = Calendar.current.date(byAdding: .day, value: -2, to: today) ?? today
        self.schedule = TrainingSampleData.generateWeek(startingFrom: startDate)
        
        // Select today
        self.selectedDay = schedule.first(where: { $0.isToday }) ?? schedule.first
    }
    
    func select(day: TrainingDay) {
        selectedDay = day
    }
    
    func toggleRest(for day: TrainingDay) {
        // Logic to toggle rest day state locally for UI
        if let index = schedule.firstIndex(where: { $0.id == day.id }) {
            var updated = schedule[index]
            updated.isRestDay.toggle()
            // If toggling to rest, clear sections or replace with rest placeholder
            if updated.isRestDay {
                updated.focusTitle = "Rest & Recovery"
                updated.bodyFocus = .rest
                updated.style = .recovery
                updated.sections = []
            } else {
                // If toggling back, we'd ideally restore original, but for mock we just set a default
                updated.focusTitle = "Freestyle Workout"
                updated.bodyFocus = .fullBody
                updated.style = .conditioning
                updated.sections = [
                    TrainingSection(title: "Circuit", exercises: [
                        TrainingExercise(name: "Burpees", sublabel: "Full Body", sets: 3, reps: "10", primaryMuscles: [.fullBody], secondaryMuscles: [], coachCue: "Explosive movement.")
                    ])
                ]
            }
            schedule[index] = updated
            if selectedDay?.id == day.id {
                selectedDay = updated
            }
        }
    }
}
