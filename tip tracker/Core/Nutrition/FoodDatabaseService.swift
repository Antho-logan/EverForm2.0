//
//  FoodDatabaseService.swift
//  EverForm
//
//  Local food database service with mock data for simulator safety
//  Applied: P-ARCH, C-SIMPLE, R-LOGS, SEC-SAFE
//

import Foundation

@Observable
final class FoodDatabaseService {
    private let mockFoods: [FoodItem]
    
    init() {
        // Initialize with mock food database
        self.mockFoods = Self.createMockFoodDatabase()
        DebugLog.info("FoodDatabaseService initialized with \(mockFoods.count) foods")
    }
    
    /// Search foods by name (case-insensitive, partial match)
    func search(name: String) -> [FoodItem] {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return Array(mockFoods.prefix(10)) // Return first 10 for empty search
        }
        
        let searchTerm = name.lowercased()
        let results = mockFoods.filter { food in
            food.name.lowercased().contains(searchTerm) ||
            food.brand?.lowercased().contains(searchTerm) == true
        }
        
        DebugLog.info("Food search for '\(name)': \(results.count) results")
        return Array(results.prefix(20)) // Limit to 20 results
    }
    
    /// Find food by barcode
    func findByBarcode(_ barcode: String) -> FoodItem? {
        let result = mockFoods.first { $0.barcode == barcode }
        
        if let food = result {
            DebugLog.info("Found food by barcode \(barcode): \(food.displayName)")
        } else {
            DebugLog.info("No food found for barcode: \(barcode)")
        }
        
        return result
    }
    
    /// Get random food item (for testing)
    func randomFood() -> FoodItem {
        return mockFoods.randomElement() ?? mockFoods[0]
    }
    
    /// Get all foods (for debugging)
    func allFoods() -> [FoodItem] {
        return mockFoods
    }
}

// MARK: - Mock Database

extension FoodDatabaseService {
    private static func createMockFoodDatabase() -> [FoodItem] {
        return [
            // Fruits
            FoodItem(
                name: "Banana",
                barcode: "1234567890123",
                per100g: NutritionPer100g(kcal: 89, protein: 1.1, carbs: 22.8, fat: 0.3),
                perServing: NutritionPerServing(kcal: 105, protein: 1.3, carbs: 27.0, fat: 0.4, servingGrams: 118)
            ),
            
            FoodItem(
                name: "Apple",
                barcode: "1234567890124",
                per100g: NutritionPer100g(kcal: 52, protein: 0.3, carbs: 13.8, fat: 0.2),
                perServing: NutritionPerServing(kcal: 95, protein: 0.5, carbs: 25.0, fat: 0.3, servingGrams: 182)
            ),
            
            FoodItem(
                name: "Orange",
                per100g: NutritionPer100g(kcal: 47, protein: 0.9, carbs: 11.8, fat: 0.1),
                perServing: NutritionPerServing(kcal: 62, protein: 1.2, carbs: 15.4, fat: 0.2, servingGrams: 131)
            ),
            
            // Proteins
            FoodItem(
                name: "Chicken Breast",
                brand: "Raw, Skinless",
                barcode: "2234567890123",
                per100g: NutritionPer100g(kcal: 165, protein: 31.0, carbs: 0.0, fat: 3.6)
            ),
            
            FoodItem(
                name: "Salmon",
                brand: "Atlantic, Raw",
                per100g: NutritionPer100g(kcal: 208, protein: 25.4, carbs: 0.0, fat: 12.4)
            ),
            
            FoodItem(
                name: "Eggs",
                brand: "Large",
                barcode: "2234567890124",
                per100g: NutritionPer100g(kcal: 155, protein: 13.0, carbs: 1.1, fat: 11.0),
                perServing: NutritionPerServing(kcal: 78, protein: 6.5, carbs: 0.6, fat: 5.5, servingGrams: 50)
            ),
            
            FoodItem(
                name: "Greek Yogurt",
                brand: "Plain, Non-fat",
                per100g: NutritionPer100g(kcal: 59, protein: 10.0, carbs: 3.6, fat: 0.4),
                perServing: NutritionPerServing(kcal: 100, protein: 17.0, carbs: 6.0, fat: 0.7, servingGrams: 170)
            ),
            
            // Carbohydrates
            FoodItem(
                name: "Brown Rice",
                brand: "Cooked",
                per100g: NutritionPer100g(kcal: 112, protein: 2.6, carbs: 22.0, fat: 0.9),
                perServing: NutritionPerServing(kcal: 216, protein: 5.0, carbs: 42.0, fat: 1.8, servingGrams: 195)
            ),
            
            FoodItem(
                name: "White Rice",
                brand: "Cooked",
                per100g: NutritionPer100g(kcal: 130, protein: 2.7, carbs: 28.0, fat: 0.3),
                perServing: NutritionPerServing(kcal: 205, protein: 4.3, carbs: 44.5, fat: 0.4, servingGrams: 158)
            ),
            
            FoodItem(
                name: "Oats",
                brand: "Rolled, Dry",
                barcode: "3234567890123",
                per100g: NutritionPer100g(kcal: 389, protein: 16.9, carbs: 66.3, fat: 6.9),
                perServing: NutritionPerServing(kcal: 150, protein: 6.5, carbs: 25.6, fat: 2.7, servingGrams: 40)
            ),
            
            FoodItem(
                name: "Whole Wheat Bread",
                brand: "Slice",
                per100g: NutritionPer100g(kcal: 247, protein: 13.0, carbs: 41.0, fat: 4.2),
                perServing: NutritionPerServing(kcal: 69, protein: 3.6, carbs: 11.5, fat: 1.2, servingGrams: 28)
            ),
            
            // Nuts & Seeds
            FoodItem(
                name: "Almonds",
                barcode: "4234567890123",
                per100g: NutritionPer100g(kcal: 579, protein: 21.2, carbs: 21.6, fat: 49.9),
                perServing: NutritionPerServing(kcal: 161, protein: 5.9, carbs: 6.0, fat: 13.9, servingGrams: 28)
            ),
            
            FoodItem(
                name: "Walnuts",
                per100g: NutritionPer100g(kcal: 654, protein: 15.2, carbs: 13.7, fat: 65.2),
                perServing: NutritionPerServing(kcal: 185, protein: 4.3, carbs: 3.9, fat: 18.5, servingGrams: 28)
            ),
            
            FoodItem(
                name: "Peanut Butter",
                brand: "Natural",
                per100g: NutritionPer100g(kcal: 588, protein: 25.1, carbs: 19.6, fat: 50.0),
                perServing: NutritionPerServing(kcal: 188, protein: 8.0, carbs: 6.3, fat: 16.0, servingGrams: 32)
            ),
            
            // Dairy
            FoodItem(
                name: "Whole Milk",
                per100g: NutritionPer100g(kcal: 61, protein: 3.2, carbs: 4.8, fat: 3.3),
                perServing: NutritionPerServing(kcal: 149, protein: 7.9, carbs: 11.7, fat: 8.0, servingGrams: 244)
            ),
            
            FoodItem(
                name: "Cheddar Cheese",
                per100g: NutritionPer100g(kcal: 403, protein: 24.9, carbs: 1.3, fat: 33.1),
                perServing: NutritionPerServing(kcal: 113, protein: 7.0, carbs: 0.4, fat: 9.3, servingGrams: 28)
            ),
            
            // Vegetables
            FoodItem(
                name: "Broccoli",
                brand: "Raw",
                per100g: NutritionPer100g(kcal: 34, protein: 2.8, carbs: 6.6, fat: 0.4),
                perServing: NutritionPerServing(kcal: 25, protein: 2.0, carbs: 4.8, fat: 0.3, servingGrams: 71)
            ),
            
            FoodItem(
                name: "Spinach",
                brand: "Raw",
                per100g: NutritionPer100g(kcal: 23, protein: 2.9, carbs: 3.6, fat: 0.4),
                perServing: NutritionPerServing(kcal: 7, protein: 0.9, carbs: 1.1, fat: 0.1, servingGrams: 30)
            ),
            
            FoodItem(
                name: "Sweet Potato",
                brand: "Baked",
                per100g: NutritionPer100g(kcal: 90, protein: 2.0, carbs: 20.7, fat: 0.2),
                perServing: NutritionPerServing(kcal: 112, protein: 2.5, carbs: 25.8, fat: 0.2, servingGrams: 124)
            ),
            
            // Legumes
            FoodItem(
                name: "Black Beans",
                brand: "Cooked",
                per100g: NutritionPer100g(kcal: 132, protein: 8.9, carbs: 23.0, fat: 0.5),
                perServing: NutritionPerServing(kcal: 227, protein: 15.2, carbs: 39.6, fat: 0.9, servingGrams: 172)
            ),
            
            FoodItem(
                name: "Chickpeas",
                brand: "Cooked",
                per100g: NutritionPer100g(kcal: 164, protein: 8.9, carbs: 27.4, fat: 2.6),
                perServing: NutritionPerServing(kcal: 269, protein: 14.5, carbs: 44.9, fat: 4.2, servingGrams: 164)
            ),
            
            // Oils & Fats
            FoodItem(
                name: "Olive Oil",
                brand: "Extra Virgin",
                per100g: NutritionPer100g(kcal: 884, protein: 0.0, carbs: 0.0, fat: 100.0),
                perServing: NutritionPerServing(kcal: 119, protein: 0.0, carbs: 0.0, fat: 13.5, servingGrams: 13.5)
            ),
            
            FoodItem(
                name: "Avocado",
                per100g: NutritionPer100g(kcal: 160, protein: 2.0, carbs: 8.5, fat: 14.7),
                perServing: NutritionPerServing(kcal: 322, protein: 4.0, carbs: 17.1, fat: 29.5, servingGrams: 201)
            ),
            
            // Beverages
            FoodItem(
                name: "Orange Juice",
                brand: "100% Pure",
                per100g: NutritionPer100g(kcal: 45, protein: 0.7, carbs: 10.4, fat: 0.2),
                perServing: NutritionPerServing(kcal: 112, protein: 1.7, carbs: 25.8, fat: 0.5, servingGrams: 248)
            ),
            
            // Snacks
            FoodItem(
                name: "Dark Chocolate",
                brand: "70-85% Cacao",
                per100g: NutritionPer100g(kcal: 598, protein: 7.9, carbs: 45.9, fat: 42.6),
                perServing: NutritionPerServing(kcal: 170, protein: 2.2, carbs: 13.0, fat: 12.1, servingGrams: 28)
            ),
            
            // Processed Foods
            FoodItem(
                name: "Pasta",
                brand: "Whole Wheat, Cooked",
                per100g: NutritionPer100g(kcal: 124, protein: 5.3, carbs: 25.0, fat: 1.1),
                perServing: NutritionPerServing(kcal: 174, protein: 7.5, carbs: 35.2, fat: 1.5, servingGrams: 140)
            ),
            
            FoodItem(
                name: "Quinoa",
                brand: "Cooked",
                per100g: NutritionPer100g(kcal: 120, protein: 4.4, carbs: 21.3, fat: 1.9),
                perServing: NutritionPerServing(kcal: 222, protein: 8.1, carbs: 39.4, fat: 3.6, servingGrams: 185)
            ),
            
            // Condiments
            FoodItem(
                name: "Honey",
                per100g: NutritionPer100g(kcal: 304, protein: 0.3, carbs: 82.4, fat: 0.0),
                perServing: NutritionPerServing(kcal: 64, protein: 0.1, carbs: 17.3, fat: 0.0, servingGrams: 21)
            ),
            
            FoodItem(
                name: "Ketchup",
                per100g: NutritionPer100g(kcal: 112, protein: 1.2, carbs: 27.4, fat: 0.1),
                perServing: NutritionPerServing(kcal: 20, protein: 0.2, carbs: 4.9, fat: 0.0, servingGrams: 17)
            )
        ]
    }
}











