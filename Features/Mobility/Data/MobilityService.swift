//
//  MobilityService.swift
//  EverForm
//
//  Created by Assistant on 07/12/2025.
//

import Foundation

protocol MobilityServiceProtocol {
    func submitAssessment(_ input: MobilityAssessmentInputDTO) async throws -> MobilityAssessmentSummaryDTO
    func fetchLatestAssessment() async throws -> MobilityAssessmentSummaryDTO?
    func fetchWeeklyFocus(from: Date?, to: Date?) async throws -> MobilityWeeklyFocusDTO
}

final class MobilityService: MobilityServiceProtocol {
    static let shared = MobilityService()
    private let client = BackendClient.shared
    
    private init() {}
    
    func submitAssessment(_ input: MobilityAssessmentInputDTO) async throws -> MobilityAssessmentSummaryDTO {
        return try await client.post("mobility/assessment/complete", body: input)
    }
    
    func fetchLatestAssessment() async throws -> MobilityAssessmentSummaryDTO? {
        // If backend returns 404 or empty state, map it to nil rather than throwing error if possible.
        // The backend prompt said: "Returns last MobilityAssessmentSummary or an “empty” state."
        // If it's a GET, BackendClient might throw if 404. We should handle that.
        // Assuming BackendClient throws badResponse(404) for not found.
        
        do {
            let summary: MobilityAssessmentSummaryDTO = try await client.get("mobility/assessment/latest")
            return summary
        } catch BackendError.badResponse(let code) where code == 404 {
            return nil
        } catch {
            throw error
        }
    }
    
    func fetchWeeklyFocus(from: Date? = nil, to: Date? = nil) async throws -> MobilityWeeklyFocusDTO {
        var query: [String: String] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let from = from {
            query["from"] = formatter.string(from: from)
        }
        if let to = to {
            query["to"] = formatter.string(from: to)
        }
        
        return try await client.get("mobility/weekly/focus", query: query)
    }
}

