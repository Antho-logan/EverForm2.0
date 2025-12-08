//
//  NutritionBackendModels.swift
//  EverForm
//
//  Mirrors the backend TypeScript definitions for Nutrition AI.
//

import Foundation

// MARK: - Nutrition Profile

enum NutritionProfileGoal: String, Codable, CaseIterable {
    case maintenance
    case fatLoss = "fat_loss"
    case recomposition
    case muscleGain = "muscle_gain"
    case performance
    case longevity
}

enum NutritionDietType: String, Codable, CaseIterable {
    case omnivore
    case highProtein = "high_protein"
    case mediterranean
    case vegetarian
    case vegan
    case lowCarb = "low_carb"
    case lowFat = "low_fat"
}

struct NutritionConstraints: Codable {
    var glutenFree: Bool?
    var dairyFree: Bool?
    var nutAllergy: Bool?
    var halal: Bool?
    var kosher: Bool?
    var pescatarian: Bool?
}

struct BiohackerNutritionFlags: Codable {
    var fastingWindowStart: String? // "HH:MM"
    var fastingWindowEnd: String?   // "HH:MM"
    var caffeineCutoffHour: Int?    // 0-23
    var lateMealCutoffHour: Int?    // 0-23
}

struct NutritionProfile: Codable {
    let userId: String
    let goal: NutritionProfileGoal
    let calorieTarget: Int
    let proteinTargetG: Int
    let carbTargetG: Int
    let fatTargetG: Int
    let dietType: NutritionDietType
    let constraints: NutritionConstraints
    let biohackerFlags: BiohackerNutritionFlags?
    let createdAt: String
    let updatedAt: String
}

struct NutritionProfileUpdate: Codable {
    var goal: NutritionProfileGoal?
    var calorieTarget: Int?
    var proteinTargetG: Int?
    var carbTargetG: Int?
    var fatTargetG: Int?
    var dietType: NutritionDietType?
    var constraints: NutritionConstraints?
    var biohackerFlags: BiohackerNutritionFlags?
}

// MARK: - Shared Summaries

struct MacroSummary: Codable {
    let target: Double
    let consumed: Double
    let remaining: Double
    let unit: String
}

struct MicroSummary: Codable {
    let key: String
    let label: String
    let unit: String
    let target: Double?
    let consumed: Double?
}

struct DailyNutritionSummary: Codable {
    let date: String
    let energy: MacroSummary
    let protein: MacroSummary
    let carbs: MacroSummary
    let fat: MacroSummary
    let micros: [MicroSummary]
}

// MARK: - AI Insights

struct NutritionAction: Codable, Identifiable {
    var id: String { label }
    let label: String
    let detail: String
}

struct DailyNutritionInsights: Codable {
    let headline: String
    let summary: String
    let actions: [NutritionAction]
    let micronutrientInsights: [NutritionAction]?
}

struct NutritionInsightsResponse: Codable {
    let profile: NutritionProfile
    let summary: DailyNutritionSummary
    let insights: DailyNutritionInsights
}

// MARK: - Smart Day Plan

struct MealMacros: Codable {
    let kcal: Int
    let proteinG: Double
    let carbsG: Double
    let fatG: Double
}

struct SuggestedMeal: Codable, Identifiable {
    var id: String { name + slot } // Computed ID for SwiftUI
    let slot: String // 'breakfast' | 'lunch' | 'dinner' | 'snack' | 'any'
    let name: String
    let macros: MealMacros
    let difficulty: String // 'easy' | 'moderate' | 'hard'
    let prepTimeMinutes: Int?
    let ingredients: [String]?
    let notes: String?
}

struct SmartDayPlan: Codable {
    let date: String
    let remaining: MealMacros
    let meals: [SuggestedMeal]
}

struct SmartDayPlanResponse: Codable {
    let profile: NutritionProfile
    let summary: DailyNutritionSummary
    let plan: SmartDayPlan
}

struct SmartDayPlanRequest: Codable {
    let date: String? // YYYY-MM-DD
}
