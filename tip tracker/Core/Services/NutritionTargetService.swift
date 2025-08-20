import Foundation

final class NutritionTargetService {
	private let defaults = UserDefaults.standard
	private let keyTargets = "nutrition.targets"
	private let keyActivity = "nutrition.activityLevel"
	private let keyGoal = "nutrition.goal"
	private let keyProteinPerKg = "nutrition.proteinPerKg"

	func currentTargets() -> NutritionTargets {
		if let data = defaults.data(forKey: keyTargets), let t = try? JSONDecoder().decode(NutritionTargets.self, from: data) {
			return t
		}
		let base = computeDefaultTargets()
		saveTargets(base)
		return base
	}

	func updateTargets(kcal: Int, proteinG: Int, carbsG: Int, fatG: Int, proteinPct: Double? = nil, carbPct: Double? = nil, fatPct: Double? = nil) {
		let t = NutritionTargets(kcal: kcal, proteinG: proteinG, carbsG: carbsG, fatG: fatG, proteinPct: proteinPct, carbPct: carbPct, fatPct: fatPct)
		saveTargets(t)
	}

	func setActivityLevel(_ level: ActivityLevel) { defaults.set(level.rawValue, forKey: keyActivity) }
	func getActivityLevel() -> ActivityLevel { ActivityLevel(rawValue: defaults.string(forKey: keyActivity) ?? "moderate") ?? .moderate }

	func setGoal(_ goal: NutritionGoal) { defaults.set(goal.rawValue, forKey: keyGoal) }
	func getGoal() -> NutritionGoal { NutritionGoal(rawValue: defaults.string(forKey: keyGoal) ?? "recomp") ?? .recomp }

	func setProteinPerKg(_ val: Double) { defaults.set(val, forKey: keyProteinPerKg) }
	func getProteinPerKg(defaultForGender gender: String) -> Double {
		if defaults.object(forKey: keyProteinPerKg) != nil { return defaults.double(forKey: keyProteinPerKg) }
		return gender.lowercased() == "female" ? 1.8 : 2.0
	}

	private func saveTargets(_ t: NutritionTargets) {
		if let data = try? JSONEncoder().encode(t) { defaults.set(data, forKey: keyTargets) }
		DebugLog.info("Saved nutrition targets kcal=\(t.kcal) P=\(t.proteinG) C=\(t.carbsG) F=\(t.fatG)")
	}

	private func computeDefaultTargets() -> NutritionTargets {
		let profile = readProfile()
		let activity = getActivityLevel()
		let goal = getGoal()
		let proteinPerKg = getProteinPerKg(defaultForGender: profile.gender)

		let bmr = mifflinStJeor(weightKg: profile.weightKg, heightCm: profile.heightCm, ageYears: profile.ageYears, gender: profile.gender)
		var tdee = bmr * activity.multiplier
		switch goal {
		case .lose: tdee *= 0.85
		case .recomp: break
		case .gain: tdee *= 1.10
		}
		let kcal = Int(round(tdee))
		let proteinG = Int(round(proteinPerKg * profile.weightKg))
		// remaining calories after protein
		let remainingKcal = max(0, kcal - proteinG * 4)
		// default split: 50% carbs, 50% fat from remaining kcal
		let carbsKcal = remainingKcal * 2 / 3 // approx 66% carbs, 34% fat
		let fatKcal = remainingKcal - carbsKcal
		let carbsG = Int(round(Double(carbsKcal) / 4.0))
		let fatG = Int(round(Double(fatKcal) / 9.0))
		return NutritionTargets(kcal: kcal, proteinG: proteinG, carbsG: carbsG, fatG: fatG, proteinPct: nil, carbPct: nil, fatPct: nil)
	}

	private func mifflinStJeor(weightKg: Double, heightCm: Double, ageYears: Int, gender: String) -> Double {
		let s = gender.lowercased() == "female" ? -161.0 : 5.0
		return 10.0 * weightKg + 6.25 * heightCm - 5.0 * Double(ageYears) + s
	}

	private func readProfile() -> (gender: String, heightCm: Double, weightKg: Double, ageYears: Int) {
		let d = UserDefaults.standard
		let gender = (d.string(forKey: "profile.gender") ?? "male")
		let height = d.double(forKey: "profile.heightCm"); let heightCm = height > 0 ? height : 175
		let weight = d.double(forKey: "profile.weightKg"); let weightKg = weight > 0 ? weight : 75
		let age = d.integer(forKey: "profile.ageYears"); let ageYears = age > 0 ? age : 30
		return (gender, heightCm, weightKg, ageYears)
	}
}







