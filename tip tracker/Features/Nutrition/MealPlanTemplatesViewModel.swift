import Foundation
import Observation

struct MealPlan: Identifiable, Hashable {
	let id = UUID()
	let title: String
	let summary: String
}

@Observable final class MealPlanTemplatesViewModel {
	private(set) var plans: [MealPlan] = [
		MealPlan(title: "Mediterranean", summary: "Oats + yogurt; Chicken salad; Salmon + potatoes; fruit & nuts"),
		MealPlan(title: "High-Protein", summary: "Eggs; Chicken & rice; Greek yogurt; Protein shake; almonds"),
		MealPlan(title: "Keto", summary: "Eggs + avocado; Salmon + greens; Beef + olive oil; nuts & cheese")
	]
}







