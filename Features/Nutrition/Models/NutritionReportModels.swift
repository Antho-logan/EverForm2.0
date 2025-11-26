//
//  NutritionReportModels.swift
//  EverForm
//
//  Extended nutrient/report models used across Nutrition screens.
//

import Foundation

struct NutrientTarget: Identifiable, Codable {
  let id: UUID
  let name: String
  let unit: String
  let currentAmount: Double
  let targetAmount: Double

  var progress: Double {
    guard targetAmount > 0 else { return 0 }
    return min(currentAmount / targetAmount, 1.0)
  }

  var displayValue: String {
    if currentAmount == 0 { return "No Data" }
    return String(format: "%.1f %@", currentAmount, unit)
  }

  init(id: UUID = UUID(), name: String, unit: String, currentAmount: Double, targetAmount: Double) {
    self.id = id
    self.name = name
    self.unit = unit
    self.currentAmount = currentAmount
    self.targetAmount = targetAmount
  }
}

struct NutrientGroup: Identifiable, Codable {
  let id: UUID
  let title: String
  let nutrients: [NutrientTarget]

  init(id: UUID = UUID(), title: String, nutrients: [NutrientTarget]) {
    self.id = id
    self.title = title
    self.nutrients = nutrients
  }
}

struct BiohackingScore: Identifiable, Codable {
  let id: UUID
  let title: String
  let score: Int
  let description: String

  init(id: UUID = UUID(), title: String, score: Int, description: String) {
    self.id = id
    self.title = title
    self.score = score
    self.description = description
  }
}

struct NutritionReportSummary {
  let macroTargets: [NutrientTarget]
  let highlightedTargets: [NutrientTarget]
  let nutrientGroups: [NutrientGroup]
  let biohackingScores: [BiohackingScore]

  static func mock() -> NutritionReportSummary {
    NutritionReportSummary(
      macroTargets: [
        NutrientTarget(name: "Energy", unit: "kcal", currentAmount: 1850, targetAmount: 2600),
        NutrientTarget(name: "Protein", unit: "g", currentAmount: 140, targetAmount: 180),
        NutrientTarget(name: "Net Carbs", unit: "g", currentAmount: 120, targetAmount: 280),
        NutrientTarget(name: "Fat", unit: "g", currentAmount: 65, targetAmount: 80),
      ],
      highlightedTargets: [
        NutrientTarget(name: "Fiber", unit: "g", currentAmount: 12, targetAmount: 30),
        NutrientTarget(name: "Iron", unit: "mg", currentAmount: 8, targetAmount: 18),
        NutrientTarget(name: "Calcium", unit: "mg", currentAmount: 400, targetAmount: 1000),
        NutrientTarget(name: "Vit C", unit: "mg", currentAmount: 45, targetAmount: 90),
        NutrientTarget(name: "Vit D", unit: "IU", currentAmount: 200, targetAmount: 600),
        NutrientTarget(name: "Magnesium", unit: "mg", currentAmount: 150, targetAmount: 400),
      ],
      nutrientGroups: [
        NutrientGroup(
          title: "Vitamins",
          nutrients: [
            NutrientTarget(name: "Vitamin A", unit: "IU", currentAmount: 1200, targetAmount: 3000),
            NutrientTarget(name: "Vitamin C", unit: "mg", currentAmount: 45, targetAmount: 90),
            NutrientTarget(name: "Vitamin D", unit: "IU", currentAmount: 200, targetAmount: 600),
            NutrientTarget(name: "Vitamin E", unit: "mg", currentAmount: 5, targetAmount: 15),
            NutrientTarget(name: "Vitamin K", unit: "µg", currentAmount: 30, targetAmount: 120),
          ]),
        NutrientGroup(
          title: "Minerals",
          nutrients: [
            NutrientTarget(name: "Calcium", unit: "mg", currentAmount: 400, targetAmount: 1000),
            NutrientTarget(name: "Iron", unit: "mg", currentAmount: 8, targetAmount: 18),
            NutrientTarget(name: "Magnesium", unit: "mg", currentAmount: 150, targetAmount: 400),
            NutrientTarget(name: "Potassium", unit: "mg", currentAmount: 2100, targetAmount: 4700),
            NutrientTarget(name: "Zinc", unit: "mg", currentAmount: 6, targetAmount: 11),
          ]),
      ],
      biohackingScores: [
        BiohackingScore(
          title: "Recovery", score: 78, description: "Good protein intake, but magnesium is low."),
        BiohackingScore(
          title: "Metabolic", score: 85, description: "Stable blood sugar predicted."),
        BiohackingScore(
          title: "Sleep Support", score: 62, description: "Increase tryptophan and magnesium."),
        BiohackingScore(
          title: "Brain Fuel", score: 90, description: "Excellent Omega-3 and hydration."),
      ]
    )
  }
}
