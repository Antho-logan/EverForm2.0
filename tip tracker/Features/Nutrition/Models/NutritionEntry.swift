//
// NutritionEntry.swift
// EverForm Scanner V2
//
// Core nutrition data model for logged meals and scanned foods.
// Assumptions: Time-stamped entries, flexible source tracking, macro-focused.
//

import Foundation

struct NutritionEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    let source: String // "scan", "manual", "barcode", "plate_ai"
    let name: String
    let calories: Int
    let protein: Double // grams
    let carbs: Double // grams
    let fat: Double // grams
    let serving: String?
    
    // Optional detailed nutrients
    let fiber: Double?
    let sugar: Double?
    let sodium: Double? // mg
    let saturatedFat: Double?
    
    // Metadata
    let confidence: Double? // 0.0-1.0 for AI estimates
    let barcode: String?
    let ingredientScore: String? // A, B, C grade
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        source: String,
        name: String,
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double,
        serving: String? = nil,
        fiber: Double? = nil,
        sugar: Double? = nil,
        sodium: Double? = nil,
        saturatedFat: Double? = nil,
        confidence: Double? = nil,
        barcode: String? = nil,
        ingredientScore: String? = nil
    ) {
        self.id = id
        self.date = date
        self.source = source
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.serving = serving
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
        self.saturatedFat = saturatedFat
        self.confidence = confidence
        self.barcode = barcode
        self.ingredientScore = ingredientScore
    }
    
    // MARK: - Computed Properties
    
    var totalMacros: Double {
        return protein + carbs + fat
    }
    
    var proteinPercent: Int {
        guard totalMacros > 0 else { return 0 }
        return Int((protein / totalMacros) * 100)
    }
    
    var carbsPercent: Int {
        guard totalMacros > 0 else { return 0 }
        return Int((carbs / totalMacros) * 100)
    }
    
    var fatPercent: Int {
        guard totalMacros > 0 else { return 0 }
        return Int((fat / totalMacros) * 100)
    }
    
    var isFromScan: Bool {
        return ["scan", "barcode", "plate_ai"].contains(source)
    }
    
    var hasIngredientScore: Bool {
        return ingredientScore != nil
    }
    
    var displaySource: String {
        switch source {
        case "scan": return "Scanned"
        case "barcode": return "Barcode"
        case "plate_ai": return "Plate AI"
        case "manual": return "Manual"
        default: return source.capitalized
        }
    }
    
    // MARK: - Factory Methods
    
    static func fromScanResult(_ scanResult: ScanResult) -> NutritionEntry {
        switch scanResult {
        case .calorie(let product, let macro):
            return NutritionEntry(
                source: "scan",
                name: product.productName,
                calories: macro.calories,
                protein: macro.protein,
                carbs: macro.carbs,
                fat: macro.fat,
                barcode: product.barcode
            )
        case .ingredients(let product, _):
            return NutritionEntry(
                source: "scan",
                name: product.productName,
                calories: 0,
                protein: 0.0,
                carbs: 0.0,
                fat: 0.0,
                barcode: product.barcode
            )
        case .plateAI(let estimate):
            return NutritionEntry(
                source: "plate_ai",
                name: "Estimated Meal",
                calories: estimate.total.calories,
                protein: estimate.total.protein,
                carbs: estimate.total.carbs,
                fat: estimate.total.fat
            )
        }
    }
}

// MARK: - Sample Data

extension NutritionEntry {
    static let sampleEntries: [NutritionEntry] = [
        NutritionEntry(
            source: "barcode",
            name: "Greek Yogurt",
            calories: 100,
            protein: 15.0,
            carbs: 6.0,
            fat: 0.0,
            serving: "1 container",
            ingredientScore: "A"
        ),
        NutritionEntry(
            source: "plate_ai",
            name: "Grilled Chicken Salad",
            calories: 350,
            protein: 35.0,
            carbs: 15.0,
            fat: 18.0,
            confidence: 0.75
        ),
        NutritionEntry(
            source: "scan",
            name: "Protein Bar",
            calories: 200,
            protein: 20.0,
            carbs: 25.0,
            fat: 6.0,
            serving: "1 bar",
            ingredientScore: "B"
        )
    ]
}
