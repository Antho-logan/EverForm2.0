//
//  JournalModels.swift
//  EverForm
//
//  Journal data models for demo storage
//

import Foundation

// MARK: - Training Models

struct JournalTrainingEntry: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let type: JournalTrainingType
    let durationMin: Int?
    let notes: String?
    let exercises: [JournalExercise]

    init(date: Date = Date(), type: JournalTrainingType = .strength, durationMin: Int? = nil, notes: String? = nil, exercises: [JournalExercise] = []) {
        self.date = date
        self.type = type
        self.durationMin = durationMin
        self.notes = notes
        self.exercises = exercises
    }
}

enum JournalTrainingType: String, CaseIterable, Codable {
    case strength = "Strength"
    case cardio = "Cardio"
    case hiit = "HIIT"
    case mobility = "Mobility"
}

struct JournalExercise: Identifiable, Codable {
    let id = UUID()
    var name: String
    var sets: Int
    var reps: Int
    var weight: Double?

    init(name: String = "", sets: Int = 3, reps: Int = 10, weight: Double? = nil) {
        self.name = name
        self.sets = sets
        self.reps = reps
        self.weight = weight
    }
}

// MARK: - Nutrition Models

struct JournalMealEntry: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let mealType: JournalMealType
    let items: [JournalFoodItem]

    var totalCalories: Int {
        items.compactMap(\.calories).reduce(0, +)
    }

    var totalProtein: Double {
        items.compactMap(\.protein).reduce(0, +)
    }

    var totalCarbs: Double {
        items.compactMap(\.carbs).reduce(0, +)
    }

    var totalFat: Double {
        items.compactMap(\.fat).reduce(0, +)
    }

    init(date: Date = Date(), mealType: JournalMealType = .breakfast, items: [JournalFoodItem] = []) {
        self.date = date
        self.mealType = mealType
        self.items = items
    }
}

enum JournalMealType: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
}

struct JournalFoodItem: Identifiable, Codable {
    let id = UUID()
    var name: String
    var calories: Int?
    var protein: Double?
    var carbs: Double?
    var fat: Double?

    init(name: String = "", calories: Int? = nil, protein: Double? = nil, carbs: Double? = nil, fat: Double? = nil) {
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
    }
}

// MARK: - Recovery Models

struct JournalRecoveryEntry: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let bedtime: Date?
    let routine: [JournalRecoveryStep]
    let durationMin: Int?

    init(date: Date = Date(), bedtime: Date? = nil, routine: [JournalRecoveryStep] = [], durationMin: Int? = nil) {
        self.date = date
        self.bedtime = bedtime
        self.routine = routine
        self.durationMin = durationMin
    }
}

struct JournalRecoveryStep: Identifiable, Codable {
    let id = UUID()
    var title: String
    var done: Bool

    init(title: String, done: Bool = false) {
        self.title = title
        self.done = done
    }

    static let defaultSteps = [
        JournalRecoveryStep(title: "Dim the lights"),
        JournalRecoveryStep(title: "Put devices away"),
        JournalRecoveryStep(title: "Deep breathing"),
        JournalRecoveryStep(title: "Light stretching"),
        JournalRecoveryStep(title: "Read or meditate")
    ]
}

// MARK: - Mobility Models

struct JournalMobilityEntry: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let focusAreas: [JournalBodyRegion]
    let durationMin: Int?
    let routine: [JournalMobilityStep]

    init(date: Date = Date(), focusAreas: [JournalBodyRegion] = [], durationMin: Int? = nil, routine: [JournalMobilityStep] = []) {
        self.date = date
        self.focusAreas = focusAreas
        self.durationMin = durationMin
        self.routine = routine
    }
}

enum JournalBodyRegion: String, CaseIterable, Codable {
    case back = "Back"
    case neck = "Neck"
    case knees = "Knees"
    case shoulders = "Shoulders"
    case hips = "Hips"
    case ankles = "Ankles"
    case wrists = "Wrists"
    case spine = "Spine"
}

struct JournalMobilityStep: Identifiable, Codable {
    let id = UUID()
    var title: String
    var repsOrSecs: String

    init(title: String, repsOrSecs: String = "30s") {
        self.title = title
        self.repsOrSecs = repsOrSecs
    }

    static let defaultSteps = [
        JournalMobilityStep(title: "Hip circles", repsOrSecs: "10x each"),
        JournalMobilityStep(title: "Shoulder rolls", repsOrSecs: "10x"),
        JournalMobilityStep(title: "Cat-cow stretch", repsOrSecs: "60s"),
        JournalMobilityStep(title: "Neck rotations", repsOrSecs: "5x each"),
        JournalMobilityStep(title: "Ankle circles", repsOrSecs: "10x each")
    ]
}
