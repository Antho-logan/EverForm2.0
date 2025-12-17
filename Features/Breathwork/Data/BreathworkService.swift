//
//  BreathworkService.swift
//  EverForm
//
//  Created by Assistant on 07/12/2025.
//

import Foundation

protocol BreathworkAiServicing {
    func fetchAiTodaySuggestion() async throws -> BreathworkAiTodaySuggestionDTO
    func fetchAiWeeklyInsight(from: Date?, to: Date?) async throws -> BreathworkAiWeeklyInsightDTO
}

final class BreathworkService: BreathworkAiServicing {
    static let shared = BreathworkService()
    private let client = BackendClient.shared
    
    private init() {}
    
    func fetchAiTodaySuggestion() async throws -> BreathworkAiTodaySuggestionDTO {
        return try await client.get("breathwork/ai/today")
    }
    
    func fetchAiWeeklyInsight(from: Date? = nil, to: Date? = nil) async throws -> BreathworkAiWeeklyInsightDTO {
        var query: [String: String] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let from = from {
            query["from"] = formatter.string(from: from)
        }
        if let to = to {
            query["to"] = formatter.string(from: to)
        }
        
        return try await client.get("breathwork/ai/weekly-insight", query: query)
    }
}





