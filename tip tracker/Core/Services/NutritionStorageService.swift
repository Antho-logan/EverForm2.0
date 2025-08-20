import Foundation

final class NutritionStorageService {
	private let fileManager = FileManager.default
	private let mealsFilename = "meals.json"
	private let dirName = "nutrition"
	private var cachedFoods: [FoodItem] = []
	private var foodById: [UUID: FoodItem] = [:]

	init() {
		loadFoods()
	}

	private var baseURL: URL {
		let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
		let dir = docs.appendingPathComponent(dirName, isDirectory: true)
		if !fileManager.fileExists(atPath: dir.path) {
			try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
			DebugLog.info("Created nutrition dir at \(dir.path)")
		}
		return dir
	}

	private var mealsURL: URL { baseURL.appendingPathComponent(mealsFilename) }

	private func normalize(_ date: Date) -> Date {
		Calendar.current.startOfDay(for: date)
	}

	// MARK: - Foods
	private func loadFoods() {
		if let url = Bundle.main.url(forResource: "foods", withExtension: "json") {
			do {
				let data = try Data(contentsOf: url)
				let foods = try JSONDecoder().decode([FoodItem].self, from: data)
				self.cachedFoods = foods
				self.foodById = Dictionary(uniqueKeysWithValues: foods.map { ($0.id, $0) })
				DebugLog.info("Loaded foods.json (\(foods.count) items)")
			} catch {
				DebugLog.error("Failed to load foods.json: \(error.localizedDescription)")
			}
		} else {
			DebugLog.error("foods.json not found in bundle")
		}
	}

	func searchFoods(query: String) -> [FoodItem] {
		let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
		guard !q.isEmpty else { return Array(cachedFoods.prefix(20)) }
		return cachedFoods.filter { $0.name.lowercased().contains(q) }.prefix(25).map { $0 }
	}

	// MARK: - Meals persistence
	private func loadAllMeals() -> [MealEntry] {
		guard fileManager.fileExists(atPath: mealsURL.path) else { return [] }
		do {
			let data = try Data(contentsOf: mealsURL)
			return try JSONDecoder().decode([MealEntry].self, from: data)
		} catch {
			DebugLog.error("Failed reading meals: \(error.localizedDescription)")
			return []
		}
	}

	private func saveAllMeals(_ meals: [MealEntry]) {
		do {
			let data = try JSONEncoder().encode(meals)
			try data.write(to: mealsURL, options: .atomic)
			DebugLog.info("Saved meals count=\(meals.count)")
		} catch {
			DebugLog.error("Failed saving meals: \(error.localizedDescription)")
		}
	}

	func listMeals(on date: Date) -> [MealEntry] {
		let day = normalize(date)
		return loadAllMeals().filter { normalize($0.date) == day }
	}

	func addMeal(_ entry: MealEntry) {
		var all = loadAllMeals()
		all.append(entry)
		saveAllMeals(all)
	}

	func deleteMeal(id: UUID) {
		var all = loadAllMeals()
		all.removeAll { $0.id == id }
		saveAllMeals(all)
	}

	// MARK: - Totals & Aggregations
	func totals(for date: Date) -> MacroTotals {
		let meals = listMeals(on: date)
		var totals = MacroTotals(kcal: 0, protein: 0, carbs: 0, fat: 0)
		for m in meals {
			guard let food = foodById[m.foodId] else { continue }
			let factor = m.grams / 100.0
			totals.kcal += food.per100g.kcal * factor
			totals.protein += food.per100g.protein * factor
			totals.carbs += food.per100g.carbs * factor
			totals.fat += food.per100g.fat * factor
		}
		return totals
	}

	func dailyTotals(range: DateInterval) -> [Date: MacroTotals] {
		var map: [Date: MacroTotals] = [:]
		var day = normalize(range.start)
		while day <= range.end {
			map[day] = totals(for: day)
			guard let next = Calendar.current.date(byAdding: .day, value: 1, to: day) else { break }
			day = next
		}
		return map
	}

	func rollingAvg(days: Int) -> Double {
		let end = normalize(Date())
		guard let start = Calendar.current.date(byAdding: .day, value: -(days - 1), to: end) else { return 0 }
		let di = DateInterval(start: start, end: end)
		let map = dailyTotals(range: di)
		let sum = map.values.reduce(0) { $0 + $1.kcal }
		return map.isEmpty ? 0 : sum / Double(map.count)
	}
}







