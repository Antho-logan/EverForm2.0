//
//  Exercise.swift
//  EverForm
//
//  Core exercise model for training workouts
//  Applied: P-ARCH, C-SIMPLE, R-LOGS
//

import Foundation

struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let bodyPart: String
    let isSuperset: Bool?
    
    init(
        id: UUID = UUID(),
        name: String,
        bodyPart: String,
        isSuperset: Bool? = nil
    ) {
        self.id = id
        self.name = name
        self.bodyPart = bodyPart
        self.isSuperset = isSuperset
    }
}

// MARK: - Sample Exercises
extension Exercise {
    static let benchPress = Exercise(name: "Bench Press", bodyPart: "Chest")
    static let pullUps = Exercise(name: "Pull-ups", bodyPart: "Back")
    static let overheadPress = Exercise(name: "Overhead Press", bodyPart: "Shoulders")
    static let rows = Exercise(name: "Rows", bodyPart: "Back")
    static let dips = Exercise(name: "Dips", bodyPart: "Chest")
    static let facePulls = Exercise(name: "Face Pulls", bodyPart: "Shoulders")
    
    // Default rest duration based on body part
    var defaultRestSec: Int {
        switch bodyPart {
        case "Chest", "Back", "Legs":
            return 120 // 2 minutes for compound movements
        case "Shoulders", "Arms":
            return 90  // 1.5 minutes for smaller muscle groups
        default:
            return 60  // 1 minute default
        }
    }
}


