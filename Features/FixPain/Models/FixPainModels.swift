//
//  FixPainModels.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import Foundation

// MARK: - Assessment Model

struct FixPainAssessment: Identifiable, Codable {
    var id: UUID = .init()
    var createdAt: Date = .init()

    var region: PainRegion?
    var side: PainSide?
    var intensity: Double = 5.0   // 0–10, using Double for Slider compatibility
    var quality: PainQuality?
    var onset: PainOnset?
    var durationInDays: Int = 1
    
    // Red Flags / Aggravating Factors
    var movementWorse: Bool = false
    var restWorse: Bool = false
    var numbnessOrTingling: Bool = false
    var nightPain: Bool = false
    var recentTrauma: Bool = false
    var feverOrIllness: Bool = false

    // Context
    var activityLevel: ActivityLevel?
    var recentTrainingChange: TrainingLoadChange?
    var postureStrain: Bool = false
    var stressLevel: StressLevel?

    var notes: String = ""
    var attachedImageData: Data? // photo of painful area (optional)
}

// MARK: - Enums

enum PainRegion: String, CaseIterable, Codable, Identifiable {
    case neck = "Neck"
    case shoulder = "Shoulder"
    case upperBack = "Upper Back"
    case lowerBack = "Lower Back"
    case hip = "Hip"
    case knee = "Knee"
    case ankle = "Ankle"
    case foot = "Foot"
    case elbow = "Elbow"
    case wrist = "Wrist"
    case hand = "Hand"
    
    var id: String { rawValue }
}

enum PainSide: String, CaseIterable, Codable, Identifiable {
    case left = "Left"
    case right = "Right"
    case both = "Both"
    case central = "Center"
    
    var id: String { rawValue }
}

enum PainQuality: String, CaseIterable, Codable, Identifiable {
    case sharp = "Sharp"
    case dull = "Dull"
    case burning = "Burning"
    case stabbing = "Stabbing"
    case throbbing = "Throbbing"
    case stiff = "Stiff"
    case ache = "Ache"
    
    var id: String { rawValue }
}

enum PainOnset: String, CaseIterable, Codable, Identifiable {
    case sudden = "Sudden"
    case gradual = "Gradual"
    case afterInjury = "After Injury"
    case afterWorkout = "After Workout"
    
    var id: String { rawValue }
}

enum ActivityLevel: String, CaseIterable, Codable, Identifiable {
    case mostlySedentary = "Sedentary"
    case lightlyActive = "Lightly Active"
    case training3xWeek = "Training 3x"
    case training5xWeek = "Training 5x+"
    case athlete = "Athlete"
    
    var id: String { rawValue }
}

enum TrainingLoadChange: String, CaseIterable, Codable, Identifiable {
    case same = "Same"
    case slightlyIncreased = "Increased"
    case doubled = "Doubled"
    case returnedAfterBreak = "Returned"
    
    var id: String { rawValue }
}

enum StressLevel: String, CaseIterable, Codable, Identifiable {
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case extreme = "Extreme"
    
    var id: String { rawValue }
}

// MARK: - Plan Models

enum RiskLevel: String, Codable {
    case selfCareOk
    case caution
    case seeDoctorASAP
}

struct FixPainPlan: Identifiable {
    var id = UUID()
    var dateGenerated: Date = Date()
    var riskLevel: RiskLevel
    var explanation: String

    var warmupAndMobility: [PainExercise]
    var strengthAndActivation: [PainExercise]
    var recoveryAdvice: [RecoveryAdvice]
    var whenToStop: [String]
    var whenToSeeDoctor: [String]
}

struct PainExercise: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var sets: Int?
    var reps: Int?
    var holdSeconds: Int?
    var sideSpecific: Bool
    var estimatedDurationMinutes: Int?
}

struct RecoveryAdvice: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var icon: String = "cross.case.fill"
}

