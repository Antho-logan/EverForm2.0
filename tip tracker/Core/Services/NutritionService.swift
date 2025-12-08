//
//  NutritionService.swift
//  EverForm
//
//  Service layer for Nutrition AI features.
//

import Foundation

final class NutritionService {
    static let shared = NutritionService()
    private let client = BackendClient.shared
    
    private init() {}
    
    // MARK: - Profile
    
    func fetchNutritionProfile() async throws -> NutritionProfile {
        return try await client.get("nutrition/profile")
    }
    
    func updateNutritionProfile(_ update: NutritionProfileUpdate) async throws -> NutritionProfile {
        return try await client.put("nutrition/profile", body: update)
    }
    
    // MARK: - AI Insights
    
    func fetchTodayInsights() async throws -> NutritionInsightsResponse {
        return try await client.get("nutrition/insights/today")
    }
    
    // MARK: - Smart Day Plan
    
    func fetchSmartDayPlan(date: Date? = nil) async throws -> SmartDayPlanResponse {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = date.map { formatter.string(from: $0) }
        
        let request = SmartDayPlanRequest(date: dateString)
        return try await client.post("nutrition/plan/day", body: request)
    }
    
    // MARK: - Search (Temporary)
    
    func searchTopFoods(nutrient: String) async throws -> [SuggestedMeal] {
        // Reusing the plan endpoint pattern for now as requested, 
        // but realistically this would be a separate search endpoint.
        // We'll just return a mock list to simulate the "AI" search experience.
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1s fake delay
        
        return [
            SuggestedMeal(slot: "snack", name: "High \(nutrient) Bowl", macros: MealMacros(kcal: 300, proteinG: 20, carbsG: 30, fatG: 10), difficulty: "easy", prepTimeMinutes: 5, ingredients: ["Ingredient A", "Ingredient B"], notes: "Rich in \(nutrient)"),
            SuggestedMeal(slot: "lunch", name: "\(nutrient) Power Salad", macros: MealMacros(kcal: 450, proteinG: 30, carbsG: 15, fatG: 20), difficulty: "moderate", prepTimeMinutes: 15, ingredients: ["Greens", "Protein Source"], notes: "Great for boosting \(nutrient)")
        ]
    }
}
