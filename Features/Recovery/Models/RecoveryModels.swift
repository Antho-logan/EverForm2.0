//
//  RecoveryModels.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

import Foundation
import SwiftUI

// MARK: - Enums

enum RecoveryTimeRange: String, CaseIterable, Identifiable {
    case today = "Today"
    case week = "Week"
    
    var id: String { rawValue }
}

enum RecoveryGoal: String, Codable, CaseIterable {
    case optimal = "optimal"
    case fixInsomnia = "fix_insomnia"
    case postCut = "post_cut"
    case stressControl = "stress_control"
    
    var displayName: String {
        switch self {
        case .optimal: return "Optimal Recovery"
        case .fixInsomnia: return "Fix Insomnia"
        case .postCut: return "Post-Cut Recovery"
        case .stressControl: return "Stress Control"
        }
    }
}

// MARK: - Core Types

enum RecoveryAction: String, CaseIterable, Hashable, Identifiable {
    case restDay = "Rest Day"
    case mobility = "Mobility"
    case massage = "Massage"
    case sauna = "Sauna"
    case coldPlunge = "Cold Plunge"
    case breathwork = "Breathwork"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .restDay: return "bed.double.fill"
        case .mobility: return "figure.flexibility"
        case .massage: return "hand.raised.fill"
        case .sauna: return "thermometer.sun.fill"
        case .coldPlunge: return "snowflake"
        case .breathwork: return "lungs.fill"
        }
    }
}

struct SleepStageBreakdown: Identifiable, Equatable {
    let id = UUID()

    // Store raw minutes for each stage
    let deepMinutes: Int
    let remMinutes: Int
    let lightMinutes: Int
    let awakeMinutes: Int
    
    var total: Int { deepMinutes + remMinutes + lightMinutes + awakeMinutes }
}

struct DailyRecoveryLog: Identifiable {
    let id = UUID()
    let date: Date
    
    // Sleep
    let totalSleepMinutes: Int
    let sleepScore: Int         // 0–100
    let efficiencyPercent: Int  // 0–100
    let sleepStages: SleepStageBreakdown
    
    // Active recovery
    var completedActions: Set<RecoveryAction>
    
    // Insights
    var coachInsight: String
    
    // MARK: - Helpers
    
    var formattedDuration: String {
        let hours = totalSleepMinutes / 60
        let minutes = totalSleepMinutes % 60
        return "\(hours)h \(minutes)m"
    }
    
    var qualityLabel: String {
        if sleepScore >= 85 { return "Excellent" }
        if sleepScore >= 70 { return "Good" }
        if sleepScore >= 50 { return "Fair" }
        return "Poor"
    }
    
    var scoreColor: Color {
        if sleepScore >= 80 { return DesignSystem.Colors.success }
        if sleepScore >= 60 { return DesignSystem.Colors.warning }
        return DesignSystem.Colors.error
    }
    
    var efficiencyDouble: Double {
        Double(efficiencyPercent) / 100.0
    }
}

// MARK: - API / AI Models

struct RecoveryProfile: Codable {
    let userId: String
    var goal: RecoveryGoal
    var targetSleepMinutes: Int
    var preferredBedtime: String?
    var preferredWakeTime: String?
    var caffeineCutoffHour: Int?
    var timezone: String
    let createdAt: String
    let updatedAt: String
}

struct RecoveryProfileUpdatePayload: Codable {
    var goal: RecoveryGoal?
    var targetSleepMinutes: Int?
    var preferredBedtime: String?
    var preferredWakeTime: String?
    var caffeineCutoffHour: Int?
    var timezone: String?
}

// MARK: - Daily Insights

struct RecoveryDailyInsights: Codable {
    let headline: String
    let summary: String
    let recoveryScore: Int
    let sleepConsistency: Int
    let nervousSystemLoad: String // 'low', 'medium', 'high'
    let keyIssues: [String]
    let todayFocusTags: [String]
}

// MARK: - Smart Day Plan

struct RecoveryPlanStep: Codable, Identifiable {
    var id: UUID { UUID() } // Client-side ID for SwiftUI loops
    let title: String
    let description: String
    let relativeMinutes: Int?
    
    enum CodingKeys: String, CodingKey {
        case title, description, relativeMinutes
    }
}

struct RecoveryDayPlan: Codable {
    let date: String
    let headline: String
    let planType: String // 'nightly', 'reset', 'maintenance'
    let steps: [RecoveryPlanStep]
}
