//
//  FixPainService.swift
//  EverForm
//
//  Created by Assistant on 07/12/2025.
//

import Foundation

struct PainAssessmentInputDTO: Encodable {
    let bodyRegion: String
    let side: String
    let painDuration: String
    let painIntensity: Int
    let painCharacter: [String]
    let aggravatingFactors: [String]
    let relievingFactors: [String]
    let activityContext: [String]
    let redFlags: [String]
    let functionalLimitations: [String]
    let notes: String?
    let photoUrl: String?
}

final class FixPainService {
    private let client: BackendClient

    init(client: BackendClient = .shared) {
        self.client = client
    }

    func submitAssessment(_ input: PainAssessmentInputDTO) async throws -> PainAiPlanDTO {
        try await client.post(
            "pain/assessment/complete",
            body: input
        )
    }

    func fetchLatestPlan() async throws -> PainAiPlanDTO {
        try await client.get(
            "pain/assessment/latest"
        )
    }
}

