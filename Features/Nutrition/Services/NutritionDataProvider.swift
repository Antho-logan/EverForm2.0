//
//  NutritionDataProvider.swift
//  EverForm
//
//  Lightweight data provider protocol + mock for Nutrition screens.
//

import Foundation

protocol NutritionDataProvider {
  func fetchDaySummary(date: Date) async -> EFNutritionDaySummary
  func fetchWeekSummary(for date: Date) async -> [EFNutritionDaySummary]
  func fetchReportSummary(for date: Date) async -> NutritionReportSummary
  func fetchDiaryEntries(for date: Date) async -> [MealEntry]
  func fetchFoodSuggestions(for target: NutritionSuggestionTarget?) async
    -> [NutritionRecommendationGroup]
  func searchFoods(byNutrient nutrient: String) async -> [NutritionSuggestedFood]
}

final class MockNutritionDataProvider: NutritionDataProvider {

  func fetchDaySummary(date: Date) async -> EFNutritionDaySummary {
    try? await Task.sleep(nanoseconds: 200_000_000)
    return EFNutritionDaySummary.mockToday()
  }

  func fetchWeekSummary(for date: Date) async -> [EFNutritionDaySummary] {
    let calendar = Calendar.current
    return (0..<7).compactMap { offset in
      guard let targetDate = calendar.date(byAdding: .day, value: -offset, to: date) else {
        return nil
      }
      var summary = EFNutritionDaySummary.mockToday()
      summary.date = targetDate
      return summary
    }
  }

  func fetchReportSummary(for date: Date) async -> NutritionReportSummary {
    try? await Task.sleep(nanoseconds: 150_000_000)
    return NutritionReportSummary.mock()
  }

  func fetchDiaryEntries(for date: Date) async -> [MealEntry] {
    let calendar = Calendar.current
    let breakfastTime = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: date) ?? date
    let lunchTime = calendar.date(bySettingHour: 12, minute: 30, second: 0, of: date) ?? date
    let snackTime = calendar.date(bySettingHour: 16, minute: 0, second: 0, of: date) ?? date

    let breakfast = MealEntry(
      date: date,
      time: breakfastTime,
      itemRef: FoodItem(
        name: "Overnight Oats", per100g: NutritionPer100g(kcal: 380, protein: 18, carbs: 55, fat: 9)
      ),
      quantityGrams: 120,
      source: .search
    )
    let lunch = MealEntry(
      date: date,
      time: lunchTime,
      itemRef: FoodItem(
        name: "Grilled Chicken Bowl",
        per100g: NutritionPer100g(kcal: 180, protein: 28, carbs: 14, fat: 3)
      ),
      quantityGrams: 180,
      source: .scan
    )
    let snack = MealEntry(
      date: date,
      time: snackTime,
      itemRef: FoodItem(
        name: "Greek Yogurt", per100g: NutritionPer100g(kcal: 90, protein: 17, carbs: 6, fat: 0)
      ),
      quantityGrams: 150,
      source: .quickAdd
    )
    return [breakfast, lunch, snack]
  }

  func fetchFoodSuggestions(for target: NutritionSuggestionTarget?) async
    -> [NutritionRecommendationGroup]
  {
    let protein = NutritionRecommendationGroup(
      title: "High in Protein",
      description: "Add these to close the protein gap",
      foods: [
        NutritionSuggestedFood(name: "Salmon Fillet", calories: 280, protein: 32, carbs: 0, fat: 16),
        NutritionSuggestedFood(
          name: "Greek Yogurt", calories: 120, protein: 20, carbs: 6, fat: 0),
        NutritionSuggestedFood(name: "Tofu Stir-fry", calories: 210, protein: 18, carbs: 12, fat: 9),
      ]
    )

    let magnesium = NutritionRecommendationGroup(
      title: "High in Magnesium",
      description: "Support sleep and recovery",
      foods: [
        NutritionSuggestedFood(name: "Pumpkin Seeds", calories: 170, protein: 9, carbs: 4, fat: 14),
        NutritionSuggestedFood(name: "Spinach", calories: 40, protein: 5, carbs: 7, fat: 1),
        NutritionSuggestedFood(
          name: "Dark Chocolate (85%)", calories: 190, protein: 3, carbs: 12, fat: 15),
      ]
    )

    let lowCarb = NutritionRecommendationGroup(
      title: "Low-carb snacks",
      description: "Keep blood sugar steady",
      foods: [
        NutritionSuggestedFood(name: "Boiled Eggs", calories: 140, protein: 12, carbs: 1, fat: 9),
        NutritionSuggestedFood(name: "Turkey Roll-ups", calories: 110, protein: 14, carbs: 2, fat: 5),
        NutritionSuggestedFood(name: "Cottage Cheese", calories: 90, protein: 13, carbs: 3, fat: 2),
      ]
    )

    switch target {
    case .highProtein?: return [protein]
    case .highMagnesium?: return [magnesium]
    case .lowCarb?: return [lowCarb]
    case .recovery?: return [magnesium]
    case .none: return [protein, magnesium, lowCarb]
    }
  }

  func searchFoods(byNutrient nutrient: String) async -> [NutritionSuggestedFood] {
    let candidates = [
      NutritionSuggestedFood(name: "Lentils", calories: 230, protein: 18, carbs: 40, fat: 2),
      NutritionSuggestedFood(name: "Mackerel", calories: 230, protein: 21, carbs: 0, fat: 15),
      NutritionSuggestedFood(name: "Swiss Chard", calories: 35, protein: 3, carbs: 7, fat: 0),
      NutritionSuggestedFood(name: "Quinoa", calories: 210, protein: 8, carbs: 39, fat: 4),
      NutritionSuggestedFood(name: "Tempeh", calories: 200, protein: 20, carbs: 10, fat: 9),
    ]

    guard !nutrient.isEmpty else { return candidates }
    return candidates.filter { $0.name.lowercased().contains(nutrient.lowercased()) }
  }
}
