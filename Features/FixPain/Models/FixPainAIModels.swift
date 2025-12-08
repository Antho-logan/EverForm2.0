//
//  FixPainAIModels.swift
//  EverForm
//
//  Created by Assistant on 07/12/2025.
//

import Foundation

enum PainTriageLevelDTO: String, Codable {
    case selfManage = "self_manage"
    case caution = "caution"
    case seeDoctorSoon = "see_doctor_soon"
}

struct PainAiSectionItemDTO: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    let title: String
    let description: String
    let iconKey: String?
    let durationMinutes: Int?

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case iconKey
        case durationMinutes
    }
}

struct PainAiPlanDTO: Codable, Equatable {
    let triageLevel: PainTriageLevelDTO
    let showDoctorBanner: Bool
    let doctorBannerTitle: String?
    let doctorBannerBody: String?
    let riskReasons: [String]

    let summaryTitle: String
    let summaryBody: String

    let likelyTissues: [String]
    let aggravatingThemes: [String]

    let warmupAndMobility: [PainAiSectionItemDTO]
    let strengthAndActivation: [PainAiSectionItemDTO]
    let recoveryAdvice: [PainAiSectionItemDTO]

    let safetyNotes: [String]
    let disclaimer: String
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case triageLevel
        case showDoctorBanner
        case doctorBannerTitle
        case doctorBannerBody
        case riskReasons
        case summaryTitle
        case summaryBody
        case likelyTissues
        case aggravatingThemes
        case warmupAndMobility
        case strengthAndActivation
        case recoveryAdvice
        case safetyNotes
        case disclaimer
        case createdAt
    }
}

