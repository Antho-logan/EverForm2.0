//
//  MobilityModels.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

import Foundation
import SwiftUI

// MARK: - Enums

enum MobilityGoal: String, CaseIterable, Identifiable, Codable {
    case performance = "Perform better at my sport(s)"
    case injuryRisk = "Reduce my risks of injury"
    case recovery = "Improve my recovery"
    case wellness = "Increase my global wellness"
    case mobility = "Improve my mobility and flexibility"
    case feelBetter = "Feel better in my body"
    case consistency = "Become consistent with my mobility work"
    case other = "Other"
    
    var id: String { rawValue }
}

enum MobilityEquipment: String, CaseIterable, Identifiable, Codable {
    case ball = "Ball"
    case foamRoller = "Foam roller"
    case band = "Band"
    case pvcPipe = "PVC pipe / dowel"
    case percussionGun = "Percussion gun"
    case none = "None"
    
    var id: String { rawValue }
}

enum MobilitySport: String, CaseIterable, Identifiable, Codable {
    case crossfit = "CrossFit"
    case functional = "Functional fitness"
    case boxing = "Boxing"
    case football = "Football"
    case bodybuilding = "Bodybuilding"
    case powerlifting = "Powerlifting"
    case running = "Running"
    case other = "Other"
    
    var id: String { rawValue }
}

enum MobilityBodyArea: String, CaseIterable, Identifiable, Codable {
    case shoulders = "Shoulders"
    case hips = "Hips"
    case ankles = "Ankles"
    case spine = "Spine"
    case fullBody = "Full Body"
    case thoracic = "Thoracic"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .shoulders: return "figure.arms.open"
        case .hips: return "figure.core.training"
        case .ankles: return "shoe.2"
        case .spine: return "figure.stand"
        case .fullBody: return "figure.flexibility"
        case .thoracic: return "lungs"
        }
    }
}

enum MobilityTestDifficulty: String, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

enum MobilityLevel: String, CaseIterable, Codable {
    case veryLow = "Very Low"
    case low = "Low"
    case average = "Average"
    case good = "Good"
    case excellent = "Excellent"
    
    var color: Color {
        switch self {
        case .veryLow: return DesignSystem.Colors.error
        case .low: return DesignSystem.Colors.warning
        case .average: return DesignSystem.Colors.info
        case .good: return DesignSystem.Colors.success
        case .excellent: return DesignSystem.Colors.accent
        }
    }
}

// MARK: - Models

struct MobilityTest: Identifiable, Codable {
    let id: UUID
    let name: String
    let bodyArea: MobilityBodyArea
    let shortDescription: String
    let instructions: [String]
    let difficulty: MobilityTestDifficulty
    let estimatedDurationMinutes: Int
    let resultScaleDescription: String
}

struct MobilityTestResult: Identifiable, Codable {
    let id: UUID
    let testId: UUID
    let score: Int // 1-5
    let date: Date
}

struct MobilityScoreSummary: Codable {
    var overallScore: Int // 0-100
    var level: MobilityLevel
    var areaScores: [MobilityBodyArea: Int] // 0-100 per area
}

struct MobilityRoutine: Identifiable, Codable {
    let id: UUID
    let title: String
    let subtitle: String
    let type: RoutineType
    let durationMinutes: Int
    let focusAreas: [MobilityBodyArea]
    let steps: [MobilityRoutineStep]
    
    enum RoutineType: String, Codable {
        case daily = "Daily"
        case activate = "Activate"
        case recover = "Recover"
        case deepReset = "Deep Reset"
    }
}

struct MobilityRoutineStep: Identifiable, Codable {
    let id: UUID
    let name: String
    let durationSeconds: Int
    let description: String?
}
