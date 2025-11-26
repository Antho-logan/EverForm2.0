//
//  BreathworkModels.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import Foundation
import SwiftUI

enum BreathworkPatternType: String, Codable, CaseIterable, Identifiable {
    case wimHof = "Wim Hof Classic"
    case box = "Box Breathing"
    case fourSevenEight = "4-7-8 Sleep"
    case coherent = "Coherent Breathing"
    case quickReset = "Quick Reset"
    case calm = "Calm"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .wimHof: return "wind"
        case .box: return "square"
        case .fourSevenEight: return "moon.stars.fill"
        case .coherent: return "waveform.path.ecg"
        case .quickReset: return "bolt.fill"
        case .calm: return "leaf.fill"
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .wimHof: return [.blue, .cyan]
        case .box: return [.indigo, .purple]
        case .fourSevenEight: return [.indigo, .blue.opacity(0.8)]
        case .coherent: return [.teal, .green]
        case .quickReset: return [.orange, .red]
        case .calm: return [.green, .mint]
        }
    }
}

enum BreathPhaseType: String, Codable {
    case inhale = "Inhale"
    case hold = "Hold"
    case exhale = "Exhale"
    case retention = "Retention"
}

struct BreathPhase: Identifiable, Codable {
    let id: UUID
    var type: BreathPhaseType
    var durationSeconds: Double
    var instruction: String?
    
    init(id: UUID = UUID(), type: BreathPhaseType, durationSeconds: Double, instruction: String? = nil) {
        self.id = id
        self.type = type
        self.durationSeconds = durationSeconds
        self.instruction = instruction
    }
}

struct BreathworkPattern: Identifiable, Codable {
    let id: UUID
    var type: BreathworkPatternType
    var displayName: String
    var description: String
    var targetEffect: String        // Calm, Sleep, Energy…
    var defaultRounds: Int
    var phases: [BreathPhase]       // defines one cycle (e.g. Inhale 4, Hold 4, Exhale 4, Hold 4)
    
    var estimatedMinutes: Int {
        let cycleDuration = phases.reduce(0) { $0 + $1.durationSeconds }
        // Approximation if rounds are just cycles
        return Int((cycleDuration * Double(defaultRounds * 6)) / 60.0) // Assuming ~6 breaths/min or cycles depending on pattern
    }
}

struct BreathworkSessionTemplate: Identifiable, Codable {
    let id: UUID
    var pattern: BreathworkPattern
    var rounds: Int
    var totalEstimatedMinutes: Int
}

struct BreathworkSessionLog: Identifiable, Codable {
    let id: UUID
    var date: Date
    var templateId: UUID?
    var patternName: String
    var durationMinutes: Int
    var roundsCompleted: Int
    var longestHoldSeconds: Int
    var notes: String?
}

enum ProgramLevel: String, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
}

struct ProgramDay: Identifiable, Codable {
    let id: UUID
    var dayIndex: Int
    var template: BreathworkSessionTemplate
    var completed: Bool
    var locked: Bool
}

struct BreathworkProgram: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var daysCount: Int
    var dailyMinutes: Int
    var level: ProgramLevel
    var sessions: [ProgramDay]
}

