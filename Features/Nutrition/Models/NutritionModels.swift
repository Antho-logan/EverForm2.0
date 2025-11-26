//
//  NutritionModels.swift
//  EverForm
//
//  Created by Gemini on 18/11/2025.
//

import Foundation

// MARK: - Enums

enum DietGoal: String, Codable, CaseIterable {
    case fatLoss = "Fat Loss"
    case maintenance = "Maintenance"
    case muscleGain = "Muscle Gain"
}

enum DietType: String, Codable, CaseIterable {
    case balanced = "Balanced"
    case highProtein = "High Protein"
    case lowCarb = "Low Carb"
    case plantBased = "Plant-Based"
    case keto = "Keto"
    case custom = "Custom"
}

enum MealType: String, CaseIterable, Identifiable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.stars.fill"
        case .snack: return "carrot.fill"
        }
    }
}

// MARK: - Profile

struct UserNutritionProfile: Codable {
    var dailyCalorieTarget: Int
    var proteinTarget: Int   // grams
    var carbsTarget: Int     // grams
    var fatTarget: Int       // grams
    var dietGoal: DietGoal
    var dietType: DietType
    
    static func mock() -> UserNutritionProfile {
        UserNutritionProfile(
            dailyCalorieTarget: 2600,
            proteinTarget: 180,
            carbsTarget: 280,
            fatTarget: 80,
            dietGoal: .muscleGain,
            dietType: .highProtein
        )
    }
}

// MARK: - Food & Meals

enum EFFoodItemType: String, Codable {
    case balanced, highProtein, lowCarb, plantBased, keto, custom
}

struct EFFoodItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var quantityDescription: String // "150g", "1 cup", etc.
    var calories: Int
    var protein: Int
    var carbs: Int
    var fat: Int
    var isCheat: Bool

    init(id: UUID = UUID(),
         name: String,
         quantityDescription: String,
         calories: Int,
         protein: Int,
         carbs: Int,
         fat: Int,
         isCheat: Bool = false) {
        self.id = id
        self.name = name
        self.quantityDescription = quantityDescription
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.isCheat = isCheat
    }
}

struct EFMeal: Identifiable, Codable {
    let id: UUID
    var type: MealType
    var items: [EFFoodItem]

    init(id: UUID = UUID(), type: MealType, items: [EFFoodItem] = []) {
        self.id = id
        self.type = type
        self.items = items
    }

    var totalCalories: Int { items.map(\.calories).reduce(0, +) }
    var totalProtein: Int { items.map(\.protein).reduce(0, +) }
    var totalCarbs: Int { items.map(\.carbs).reduce(0, +) }
    var totalFat: Int { items.map(\.fat).reduce(0, +) }
    
    var summaryText: String {
        if items.isEmpty { return "No items logged" }
        let count = items.count
        return "\(count) item\(count == 1 ? "" : "s")"
    }
}

// MARK: - Daily Summary

struct EFNutritionDaySummary: Identifiable, Codable {
    let id: UUID
    var date: Date
    var meals: [EFMeal]

    init(id: UUID = UUID(), date: Date, meals: [EFMeal]) {
        self.id = id
        self.date = date
        self.meals = meals
    }

    var caloriesConsumed: Int { meals.map(\.totalCalories).reduce(0, +) }
    var protein: Int { meals.map(\.totalProtein).reduce(0, +) }
    var carbs: Int { meals.map(\.totalCarbs).reduce(0, +) }
    var fat: Int { meals.map(\.totalFat).reduce(0, +) }
    
    static func mockToday() -> EFNutritionDaySummary {
        EFNutritionDaySummary(date: Date(), meals: [
            EFMeal(type: .breakfast, items: [
                EFFoodItem(name: "Oatmeal & Berries", quantityDescription: "1 bowl", calories: 450, protein: 12, carbs: 60, fat: 8),
                EFFoodItem(name: "Protein Shake", quantityDescription: "1 scoop", calories: 120, protein: 24, carbs: 3, fat: 1)
            ]),
            EFMeal(type: .lunch, items: [
                EFFoodItem(name: "Chicken Salad", quantityDescription: "Large", calories: 550, protein: 45, carbs: 15, fat: 25)
            ]),
            EFMeal(type: .dinner, items: []),
            EFMeal(type: .snack, items: [
                EFFoodItem(name: "Almonds", quantityDescription: "30g", calories: 180, protein: 6, carbs: 6, fat: 15)
            ])
        ])
    }
}

enum NutritionPeriod: String, CaseIterable {
    case today = "Today"
    case week = "Week"
}

// MARK: - Suggestions & Tools

enum NutritionSuggestionTarget: String, CaseIterable, Identifiable {
    case highProtein = "High Protein"
    case highMagnesium = "High Magnesium"
    case lowCarb = "Low-carb Snacks"
    case recovery = "Recovery Support"

    var id: String { rawValue }

    var prompt: String {
        switch self {
        case .highProtein: return "Close your protein gap with lean options."
        case .highMagnesium: return "Ease stress and sleep with magnesium-rich foods."
        case .lowCarb: return "Stable energy with low-carb snacks."
        case .recovery: return "Reduce soreness with anti-inflammatory picks."
        }
    }
}

struct NutritionSuggestedFood: Identifiable, Codable {
    let id: UUID
    let name: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fat: Int

    init(
        id: UUID = UUID(),
        name: String,
        calories: Int,
        protein: Int,
        carbs: Int,
        fat: Int
    ) {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
    }

    var macroLine: String {
        "P \(protein)g • C \(carbs)g • F \(fat)g"
    }
}

struct NutritionRecommendationGroup: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String?
    let foods: [NutritionSuggestedFood]

    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        foods: [NutritionSuggestedFood]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.foods = foods
    }
}

struct CustomMealTemplate: Identifiable, Codable {
    let id: UUID
    let name: String
    let kcal: Int
    let items: [String]

    init(id: UUID = UUID(), name: String, kcal: Int, items: [String]) {
        self.id = id
        self.name = name
        self.kcal = kcal
        self.items = items
    }
}

struct RepeatItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let detail: String
    let schedule: String

    init(id: UUID = UUID(), title: String, detail: String, schedule: String) {
        self.id = id
        self.title = title
        self.detail = detail
        self.schedule = schedule
    }
}
