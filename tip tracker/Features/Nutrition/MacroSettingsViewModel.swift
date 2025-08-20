import Foundation
import Observation

@Observable final class MacroSettingsViewModel {
	private let targetService = NutritionTargetService()
	var activity: ActivityLevel = .moderate
	var goal: NutritionGoal = .recomp
	var proteinPerKg: Double = 2.0
	var targets: NutritionTargets = .init(kcal: 0, proteinG: 0, carbsG: 0, fatG: 0)

	func onAppear() {
		activity = targetService.getActivityLevel()
		goal = targetService.getGoal()
		proteinPerKg = targetService.getProteinPerKg(defaultForGender: "male")
		targets = targetService.currentTargets()
	}

	func save() {
		targetService.setActivityLevel(activity)
		targetService.setGoal(goal)
		targetService.setProteinPerKg(proteinPerKg)
		// Recompute defaults after changes
		targets = targetService.currentTargets()
	}
}







