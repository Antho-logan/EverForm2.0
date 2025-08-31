import Foundation

enum ScanMode: String, CaseIterable, Hashable, Identifiable {
    case calorie, ingredients, plateAI
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .calorie: return "Calorie"
        case .ingredients: return "Ingredients"
        case .plateAI: return "Plate AI"
        }
    }
    
    var icon: String {
        switch self {
        case .calorie: return "barcode.viewfinder"
        case .ingredients: return "list.bullet.rectangle"
        case .plateAI: return "camera.viewfinder"
        }
    }
    
    var instructionText: String {
        switch self {
        case .calorie: return "Scan barcode or nutrition label"
        case .ingredients: return "Scan ingredient list"
        case .plateAI: return "Capture your plate"
        }
    }
    
    var captureButtonTitle: String {
        switch self {
        case .calorie: return "Scan"
        case .ingredients: return "Scan"
        case .plateAI: return "Capture"
        }
    }
    
    var supportsBarcode: Bool {
        switch self {
        case .calorie: return true
        case .ingredients: return false
        case .plateAI: return false
        }
    }
    
    var supportsOCR: Bool {
        switch self {
        case .calorie: return true
        case .ingredients: return true
        case .plateAI: return false
        }
    }
}

struct NutritionMacro: Codable, Hashable {
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
}

struct ProductInfo: Codable, Hashable {
    var productName: String
    var brand: String?
    var barcode: String?
}

enum Verdict: String, Codable, Hashable { case good, caution, avoid }

struct IngredientAssessment: Codable, Hashable, Identifiable {
    var id = UUID()
    var name: String
    var verdict: Verdict
    var reasons: [String]
}

struct PlateFood: Codable, Hashable, Identifiable {
    var id = UUID()
    var name: String
    var grams: Double
    var macro: NutritionMacro
}

struct PlateEstimate: Codable, Hashable {
    var items: [PlateFood]
    var total: NutritionMacro
}

/// Canonical result for all scan modes
enum ScanResult: Hashable {
    case calorie(product: ProductInfo, macro: NutritionMacro)
    case ingredients(product: ProductInfo, items: [IngredientAssessment])
    case plateAI(estimate: PlateEstimate)
}

// Convenience accessors so views never reach into associated values directly.
extension ScanResult {
    var productName: String? {
        switch self {
        case .calorie(let product, _): return product.productName
        case .ingredients(let product, _): return product.productName
        case .plateAI: return "Plate Estimate"
        }
    }
    var macro: NutritionMacro? {
        switch self {
        case .calorie(_, let macro): return macro
        case .ingredients: return nil
        case .plateAI(let estimate): return estimate.total
        }
    }
    var ingredients: [IngredientAssessment]? {
        if case let .ingredients(_, items) = self { return items }
        return nil
    }
    var scanSource: String {
        switch self {
        case .calorie: return "calorie_scan"
        case .ingredients: return "ingredients_scan"
        case .plateAI: return "plate_ai"
        }
    }
}
