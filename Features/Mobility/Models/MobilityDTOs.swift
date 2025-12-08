//
//  MobilityDTOs.swift
//  EverForm
//
//  Created by Assistant on 07/12/2025.
//

import Foundation

// MARK: - API DTOs

struct MobilityTestResultDTO: Codable, Equatable {
    let testId: String
    let testName: String
    let joint: String      // "hips" | "thoracic" | "shoulders" | "ankles" | "full_body" | "other"
    let rangeOfMotionScore: Int?
    let controlScore: Int?
    let pain: Bool?
    let notes: String?
}

struct MobilityAssessmentInputDTO: Codable, Equatable {
    let tests: [MobilityTestResultDTO]
    let notes: String?
}

struct MobilityProfileDTO: Codable, Equatable {
    let userId: String
    let overallScore: Int
    let hipsScore: Int?
    let thoracicScore: Int?
    let shouldersScore: Int?
    let anklesScore: Int?
    let focusAreas: [String]
    let riskNotes: [String]
    let lastAssessmentAt: String
}

struct MobilityRecommendedRoutineDTO: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let priority: String    // "high" | "medium" | "low"
    let frequencyPerWeek: Int?
}

struct MobilityAssessmentSummaryDTO: Codable, Equatable {
    let profile: MobilityProfileDTO
    let aiSummaryText: String
    let focusTags: [String]
    let recommendedRoutines: [MobilityRecommendedRoutineDTO]
    let weeklyPlanText: String
}

struct MobilityWeeklyFocusDTO: Codable, Equatable {
    let averageScore: Int?
    let fromDate: String
    let toDate: String
    let focusTitle: String
    let focusTags: [String]
    let warnings: [String]
    let coachInsight: String
}

