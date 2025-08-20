import Foundation
import Observation

@Observable final class MealLoggerViewModel {
	private let storage = NutritionStorageService()
	var query: String = ""
	private(set) var results: [FoodItem] = []
	var grams: Double = 100
	var selectedFood: FoodItem? = nil
	private(set) var todayMeals: [MealEntry] = []

	func onAppear() {
		DebugLog.info("MealLogger onAppear")
		search()
		reloadToday()
	}

	func search() {
		results = storage.searchFoods(query: query)
	}

	func select(food: FoodItem) {
		selectedFood = food
	}

	func addSelectedToToday() {
		guard let food = selectedFood else { return }
		let entry = MealEntry(date: Date(), foodId: food.id, grams: grams)
		storage.addMeal(entry)
		reloadToday()
	}

	func deleteMeal(id: UUID) {
		storage.deleteMeal(id: id)
		reloadToday()
	}

	func computedTotalsForSelected() -> MacroTotals {
		guard let food = selectedFood else { return .init(kcal: 0, protein: 0, carbs: 0, fat: 0) }
		let factor = grams / 100.0
		return .init(
			kcal: food.per100g.kcal * factor,
			protein: food.per100g.protein * factor,
			carbs: food.per100g.carbs * factor,
			fat: food.per100g.fat * factor
		)
	}

	private func reloadToday() {
		todayMeals = storage.listMeals(on: Date())
	}
}







