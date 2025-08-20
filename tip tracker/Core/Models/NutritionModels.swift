import Foundation

public struct MacroPer100g: Codable, Hashable {
	public var kcal: Double
	public var protein: Double
	public var carbs: Double
	public var fat: Double
}

public struct FoodItem: Codable, Identifiable, Hashable {
	public let id: UUID
	public var name: String
	public var per100g: MacroPer100g
	public var notes: String?
}

public struct MealEntry: Codable, Identifiable, Hashable {
	public let id: UUID
	public var date: Date // normalized to start-of-day
	public var foodId: UUID
	public var grams: Double
	public init(id: UUID = UUID(), date: Date, foodId: UUID, grams: Double) {
		self.id = id
		self.date = date
		self.foodId = foodId
		self.grams = grams
	}
}

public struct NutritionTargets: Codable, Hashable {
	public var kcal: Int
	public var proteinG: Int
	public var carbsG: Int
	public var fatG: Int
	public var proteinPct: Double?
	public var carbPct: Double?
	public var fatPct: Double?
}

public enum ActivityLevel: String, Codable, CaseIterable, Identifiable, CustomStringConvertible {
	case sedentary
	case light
	case moderate
	case high
	case athlete
	public var id: String { rawValue }
	public var description: String { rawValue.capitalized }
	public var multiplier: Double {
		switch self {
		case .sedentary: return 1.2
		case .light: return 1.375
		case .moderate: return 1.55
		case .high: return 1.725
		case .athlete: return 1.9
		}
	}
}

public enum NutritionGoal: String, Codable, CaseIterable, Identifiable, CustomStringConvertible {
	case lose
	case recomp
	case gain
	public var id: String { rawValue }
	public var description: String { rawValue.capitalized }
}

public struct MacroTotals: Hashable {
	public var kcal: Double
	public var protein: Double
	public var carbs: Double
	public var fat: Double
}

public enum NutritionAggregation: String, CaseIterable, Identifiable, CustomStringConvertible {
	case daily
	case weekly
	case monthly
	public var id: String { rawValue }
	public var description: String { rawValue.capitalized }
}







