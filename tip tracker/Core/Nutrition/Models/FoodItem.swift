//
//  FoodItem.swift
//  EverForm
//
//  Food item with nutritional information per 100g and optional serving data
//  Applied: P-ARCH, C-SIMPLE, R-LOGS
//

import Foundation

struct FoodItem: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let brand: String?
    let barcode: String?
    
    // Nutritional info per 100g
    let per100g: NutritionPer100g
    
    // Optional serving information
    let perServing: NutritionPerServing?
    
    init(
        id: UUID = UUID(),
        name: String,
        brand: String? = nil,
        barcode: String? = nil,
        per100g: NutritionPer100g,
        perServing: NutritionPerServing? = nil
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.barcode = barcode
        self.per100g = per100g
        self.perServing = perServing
    }
    
    /// Display name with brand if available
    var displayName: String {
        if let brand = brand {
            return "\(brand) \(name)"
        }
        return name
    }
    
    /// Calculate nutrition for a specific weight in grams
    func nutritionFor(grams: Double) -> NutritionValues {
        let multiplier = grams / 100.0
        return NutritionValues(
            kcal: Int(Double(per100g.kcal) * multiplier),
            protein: Double(per100g.protein) * multiplier,
            carbs: Double(per100g.carbs) * multiplier,
            fat: Double(per100g.fat) * multiplier
        )
    }
}

// MARK: - Supporting Types

struct NutritionPer100g: Codable, Hashable {
    let kcal: Int
    let protein: Double  // grams
    let carbs: Double    // grams
    let fat: Double      // grams
    
    init(kcal: Int, protein: Double, carbs: Double, fat: Double) {
        self.kcal = kcal
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
    }
}

struct NutritionPerServing: Codable, Hashable {
    let kcal: Int
    let protein: Double  // grams
    let carbs: Double    // grams
    let fat: Double      // grams
    let servingGrams: Double  // weight of one serving
    
    init(kcal: Int, protein: Double, carbs: Double, fat: Double, servingGrams: Double) {
        self.kcal = kcal
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.servingGrams = servingGrams
    }
}

struct NutritionValues: Codable, Hashable {
    let kcal: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    
    init(kcal: Int, protein: Double, carbs: Double, fat: Double) {
        self.kcal = kcal
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
    }
    
    /// Add two nutrition values together
    static func + (lhs: NutritionValues, rhs: NutritionValues) -> NutritionValues {
        return NutritionValues(
            kcal: lhs.kcal + rhs.kcal,
            protein: lhs.protein + rhs.protein,
            carbs: lhs.carbs + rhs.carbs,
            fat: lhs.fat + rhs.fat
        )
    }
    
    /// Zero nutrition values
    static var zero: NutritionValues {
        return NutritionValues(kcal: 0, protein: 0, carbs: 0, fat: 0)
    }
}

// MARK: - Sample Food Items

extension FoodItem {
    static let banana = FoodItem(
        name: "Banana",
        per100g: NutritionPer100g(kcal: 89, protein: 1.1, carbs: 22.8, fat: 0.3),
        perServing: NutritionPerServing(kcal: 105, protein: 1.3, carbs: 27.0, fat: 0.4, servingGrams: 118)
    )
    
    static let chickenBreast = FoodItem(
        name: "Chicken Breast",
        brand: "Raw",
        per100g: NutritionPer100g(kcal: 165, protein: 31.0, carbs: 0.0, fat: 3.6)
    )
    
    static let brownRice = FoodItem(
        name: "Brown Rice",
        brand: "Cooked",
        per100g: NutritionPer100g(kcal: 112, protein: 2.6, carbs: 22.0, fat: 0.9),
        perServing: NutritionPerServing(kcal: 216, protein: 5.0, carbs: 42.0, fat: 1.8, servingGrams: 195)
    )
    
    static let almonds = FoodItem(
        name: "Almonds",
        per100g: NutritionPer100g(kcal: 579, protein: 21.2, carbs: 21.6, fat: 49.9),
        perServing: NutritionPerServing(kcal: 161, protein: 5.9, carbs: 6.0, fat: 13.9, servingGrams: 28)
    )
    
    static let wholeMilk = FoodItem(
        name: "Whole Milk",
        per100g: NutritionPer100g(kcal: 61, protein: 3.2, carbs: 4.8, fat: 3.3),
        perServing: NutritionPerServing(kcal: 149, protein: 7.9, carbs: 11.7, fat: 8.0, servingGrams: 244)
    )
}











