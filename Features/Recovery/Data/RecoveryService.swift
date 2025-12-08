//
//  RecoveryService.swift
//  EverForm
//
//  Created by Assistant on 07/12/2025.
//

import Foundation

protocol RecoveryServiceProtocol {
    func fetchProfile() async throws -> RecoveryProfile
    func updateProfile(_ payload: RecoveryProfileUpdatePayload) async throws -> RecoveryProfile
    func fetchTodayInsights() async throws -> RecoveryDailyInsights
    func fetchDayPlan(for date: Date?) async throws -> RecoveryDayPlan
}

final class RecoveryService: RecoveryServiceProtocol {
    static let shared = RecoveryService()
    private let client = BackendClient.shared
    
    private init() {}
    
    func fetchProfile() async throws -> RecoveryProfile {
        return try await client.get("recovery/profile")
    }
    
    func updateProfile(_ payload: RecoveryProfileUpdatePayload) async throws -> RecoveryProfile {
        return try await client.put("recovery/profile", body: payload)
    }
    
    func fetchTodayInsights() async throws -> RecoveryDailyInsights {
        return try await client.get("recovery/insights/today")
    }
    
    func fetchDayPlan(for date: Date? = nil) async throws -> RecoveryDayPlan {
        var body: [String: String] = [:]
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            body["date"] = formatter.string(from: date)
        }
        
        return try await client.post("recovery/plan/day", body: body)
    }
}

