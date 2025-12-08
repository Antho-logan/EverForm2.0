//
//  BreathworkAiDTOs.swift
//  EverForm
//
//  Created by Assistant on 07/12/2025.
//

import Foundation

// MARK: - API DTOs

struct BreathworkAiTodaySuggestionDTO: Codable, Equatable {
    let suggestedPatternId: String?
    let suggestedPatternName: String
    let suggestedRounds: Int
    let suggestedMinutes: Int
    let suggestionReason: String
    let focusTags: [String]
    
    func toViewData() -> BreathworkAiTodaySuggestionViewData {
        return BreathworkAiTodaySuggestionViewData(
            title: "AI Suggestion for Today",
            patternName: suggestedPatternName,
            doseText: "\(suggestedPatternName) · \(suggestedRounds) rounds · \(suggestedMinutes) min",
            reason: suggestionReason,
            focusTags: focusTags,
            suggestedPatternId: suggestedPatternId,
            suggestedRounds: suggestedRounds,
            suggestedMinutes: suggestedMinutes
        )
    }
}

struct BreathworkAiWeeklyInsightDTO: Codable, Equatable {
    let periodStart: String
    let periodEnd: String
    let totalSessions: Int
    let totalMinutes: Int
    let streakDays: Int
    let trendLabel: String            // "up" | "down" | "flat"
    let insightText: String
    let focusTags: [String]
    let recommendedFocus: String
    
    func toViewData() -> BreathworkAiWeeklyInsightViewData {
        return BreathworkAiWeeklyInsightViewData(
            headline: "Weekly Insight",
            statsSummary: "\(totalSessions) sessions · \(totalMinutes) min · \(streakDays)-day streak",
            insightText: insightText,
            recommendedFocus: recommendedFocus,
            focusTags: focusTags,
            periodLabel: "Last 7 days",
            trendLabel: trendLabel
        )
    }
}

// MARK: - View Data

struct BreathworkAiTodaySuggestionViewData: Equatable {
    let title: String
    let patternName: String
    let doseText: String
    let reason: String
    let focusTags: [String]
    
    // Config data to apply
    let suggestedPatternId: String?
    let suggestedRounds: Int
    let suggestedMinutes: Int
}

struct BreathworkAiWeeklyInsightViewData: Equatable {
    let headline: String
    let statsSummary: String
    let insightText: String
    let recommendedFocus: String
    let focusTags: [String]
    let periodLabel: String
    let trendLabel: String
}

