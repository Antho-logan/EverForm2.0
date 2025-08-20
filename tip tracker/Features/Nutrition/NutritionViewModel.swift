import Foundation
import Observation

@Observable final class NutritionViewModel {
	private let storage = NutritionStorageService()
	private let targetService = NutritionTargetService()

	private(set) var todayTotals: MacroTotals = .init(kcal: 0, protein: 0, carbs: 0, fat: 0)
	private(set) var weekAvgKcal: Double = 0
	private(set) var monthAvgKcal: Double = 0
	private(set) var targets: NutritionTargets = .init(kcal: 0, proteinG: 0, carbsG: 0, fatG: 0)

	func load() {
		DebugLog.info("NutritionVM load")
		targets = targetService.currentTargets()
		refreshNumbers()
	}

	func refreshNumbers() {
		todayTotals = storage.totals(for: Date())
		weekAvgKcal = storage.rollingAvg(days: 7)
		monthAvgKcal = storage.rollingAvg(days: 30)
	}
}







