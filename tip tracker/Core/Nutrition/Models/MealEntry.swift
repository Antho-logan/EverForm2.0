//
//  MealEntry.swift
//  EverForm
//
//  Individual meal entry with food item snapshot and quantity
//  Applied: P-ARCH, C-SIMPLE, R-LOGS
//

import Foundation

enum MealEntrySource: String, Codable, CaseIterable {
    case scan = "scan"
    case quickAdd = "quickAdd"
    case search = "search"
    
    var displayName: String {
        switch self {
        case .scan: return "Scan"
        case .quickAdd: return "Quick Add"
        case .search: return "Search"
        }
    }
    
    var iconName: String {
        switch self {
        case .scan: return "camera.viewfinder"
        case .quickAdd: return "plus.circle"
        case .search: return "magnifyingglass"
        }
    }
}

struct MealEntry: Identifiable, Codable {
    let id: UUID
    let date: Date  // Day precision for grouping
    let time: Date  // Full timestamp for ordering within day
    let itemRef: FoodItem  // Snapshot of food item at time of entry
    let quantityGrams: Double
    let source: MealEntrySource
    let notes: String?
    
    // Computed nutrition values (stored for performance)
    let kcal: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        time: Date = Date(),
        itemRef: FoodItem,
        quantityGrams: Double,
        source: MealEntrySource,
        notes: String? = nil
    ) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)  // Normalize to day precision
        self.time = time
        self.itemRef = itemRef
        self.quantityGrams = quantityGrams
        self.source = source
        self.notes = notes
        
        // Calculate nutrition values
        let nutrition = itemRef.nutritionFor(grams: quantityGrams)
        self.kcal = nutrition.kcal
        self.protein = nutrition.protein
        self.carbs = nutrition.carbs
        self.fat = nutrition.fat
    }
    
    /// Formatted time for display (e.g., "2:30 PM")
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    
    /// Formatted quantity for display
    var formattedQuantity: String {
        if quantityGrams < 1000 {
            return String(format: "%.0fg", quantityGrams)
        } else {
            return String(format: "%.1fkg", quantityGrams / 1000)
        }
    }
    
    /// Display name combining food item and quantity
    var displayName: String {
        return "\(itemRef.displayName) (\(formattedQuantity))"
    }
    
    /// Nutrition values as a computed property
    var nutritionValues: NutritionValues {
        return NutritionValues(kcal: kcal, protein: protein, carbs: carbs, fat: fat)
    }
}

// MARK: - Factory Methods

extension MealEntry {
    /// Create a quick add entry with custom nutrition
    static func quickAdd(
        kcal: Int,
        protein: Double? = nil,
        carbs: Double? = nil,
        fat: Double? = nil,
        notes: String? = nil,
        time: Date = Date()
    ) -> MealEntry {
        let foodItem = FoodItem(
            name: "Quick Add",
            per100g: NutritionPer100g(
                kcal: kcal,
                protein: protein ?? 0,
                carbs: carbs ?? 0,
                fat: fat ?? 0
            )
        )
        
        return MealEntry(
            time: time,
            itemRef: foodItem,
            quantityGrams: 100, // Assume 100g for quick add
            source: .quickAdd,
            notes: notes
        )
    }
    
    /// Create entry from scan result with portion multiplier
    static func fromScanResult(
        foodItem: FoodItem,
        portionMultiplier: Double = 1.0,
        time: Date = Date()
    ) -> MealEntry {
        // Calculate quantity based on portion multiplier
        // If food has serving info, use that; otherwise assume 100g base
        let baseGrams = foodItem.perServing?.servingGrams ?? 100.0
        let quantityGrams = baseGrams * portionMultiplier
        
        return MealEntry(
            time: time,
            itemRef: foodItem,
            quantityGrams: quantityGrams,
            source: .scan
        )
    }
}








