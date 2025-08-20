import Foundation
import Observation

@Observable final class CalorieTrendsViewModel {
	private let storage = NutritionStorageService()
	private(set) var last30: [(date: Date, kcal: Double)] = []
	private(set) var avg7: Double = 0
	private(set) var avg30: Double = 0

	func onAppear() {
		let end = Calendar.current.startOfDay(for: Date())
		let start = Calendar.current.date(byAdding: .day, value: -29, to: end) ?? end
		let di = DateInterval(start: start, end: end)
		let map = storage.dailyTotals(range: di)
		last30 = map.keys.sorted().map { ($0, map[$0]?.kcal ?? 0) }
		avg7 = storage.rollingAvg(days: 7)
		avg30 = storage.rollingAvg(days: 30)
	}
}







