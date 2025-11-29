//
//  BackendModels.swift
//  EverForm
//
//  Codable types that mirror backend JSON payloads
//

import Foundation

// MARK: - Profile
struct BackendProfile: Codable {
    let id: String?
    let user_id: String
    let full_name: String?
    let email: String?
    let date_of_birth: String?
    let gender: String?
    let height_cm: Double?
    let weight_kg: Double?
    let activity_level: String?
    let primary_goal: String?
    let goal_type: String?
    let body_fat: Double?
}

struct BackendOnboardingAnswer: Codable {
    let question_key: String
    let answer_text: String?
    let answer_numeric: Double?
    let metadata: [String: String]?
}

// MARK: - Nutrition
struct BackendMeal: Codable, Identifiable {
    let id: String
    let user_id: String
    let meal_type: String
    let title: String
    let kcal: Int?
    let protein_g: Double?
    let carbs_g: Double?
    let fat_g: Double?
    let logged_at: Date
    let source: String?
}

struct BackendNutritionSummary: Codable {
    let date: String
    let totals: BackendNutritionTotals
    let meals: [BackendMeal]
}

struct BackendNutritionTotals: Codable {
    let kcal: Int
    let protein: Double
    let carbs: Double
    let fat: Double
}

// MARK: - Training
struct BackendTrainingSet: Codable {
    let exercise: String
    let reps: Int
    let weight: Double?
    let rpe: Double?
    let notes: String?
}

struct BackendTrainingSession: Codable, Identifiable {
    let id: String
    let user_id: String
    let title: String
    let status: String
    let duration_minutes: Int?
    let performed_at: Date?
    let notes: String?
    let training_sets: [BackendTrainingSet]?
}

// MARK: - Recovery / Pain
struct BackendPainCheck: Codable, Identifiable {
    let id: String
    let user_id: String
    let area: String
    let severity: Int
    let description: String?
    let created_at: Date?
}

struct BackendRecoveryLog: Codable, Identifiable {
    let id: String
    let user_id: String
    let sleep_hours: Double?
    let sleep_score: Int?
    let stress_level: Int?
    let notes: String?
    let logged_at: Date?
}

struct BackendRecoveryRecent: Codable {
    let recoveryLog: BackendRecoveryLog?
    let recentPainCheck: BackendPainCheck?
}

// MARK: - Breathwork / Mobility / Lookmax
struct BackendBreathworkSession: Codable, Identifiable {
    let id: String
    let user_id: String
    let technique: String
    let duration_minutes: Int?
    let completed_at: Date?
}

struct BackendMobilitySession: Codable, Identifiable {
    let id: String
    let user_id: String
    let routine_id: String?
    let status: String
    let performed_at: Date?
}

struct BackendLookmaxRoutine: Codable, Identifiable {
    let id: String
    let user_id: String
    let category: String
    let plan_json: [String: AnyCodable]?
    let notes: String?
    let created_at: Date?
}

struct BackendLookmaxAction: Codable, Identifiable {
    let id: String
    let user_id: String
    let session_id: String
    let action: String
    let notes: String?
}

// MARK: - Coach / AI
struct BackendCoachResponse: Codable {
    let reply: String
}

struct BackendAIPlanResponse: Codable {
    let plan: [String: AnyCodable]
    let storedPlan: [String: AnyCodable]?
}

// MARK: - Scan
struct BackendScanResponse: Decodable {
    let meal: BackendMeal?
    let analysis: BackendScanAnalysis
}

struct BackendScanAnalysis: Decodable {
    let mode: String
    let calories: Int?
    let protein: Int?
    let carbs: Int?
    let fat: Int?
    let confidence: Double?
    let ingredients: [BackendScanIngredient]?
    let notes: String?
    let description: String?
    let mealType: String?
    let caloriesEstimate: Int?
}

struct BackendScanIngredient: Decodable {
    let name: String
    let confidence: Double
}

// MARK: - Utility

/// Lightweight wrapper to decode unknown JSON payloads.
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else if let dictVal = try? container.decode([String: AnyCodable].self) {
            value = dictVal
        } else if let arrayVal = try? container.decode([AnyCodable].self) {
            value = arrayVal
        } else {
            value = ()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let intVal as Int: try container.encode(intVal)
        case let doubleVal as Double: try container.encode(doubleVal)
        case let boolVal as Bool: try container.encode(boolVal)
        case let stringVal as String: try container.encode(stringVal)
        case let dictVal as [String: AnyCodable]: try container.encode(dictVal)
        case let arrayVal as [AnyCodable]: try container.encode(arrayVal)
        default: try container.encodeNil()
        }
    }
}
