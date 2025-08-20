import Foundation
import Observation

@Observable final class SleepRecoveryViewModel {
	private let storage = RecoveryStorageService()
	private(set) var lastNightHours: Double = 0
	private(set) var sevenDayAvg: Double = 0
	private(set) var sleepDebtHours: Double = 0
	private(set) var latestReadiness: ReadinessScore? = nil

	func load() {
		DebugLog.info("SleepRecoveryVM load")
		if let last = storage.latestSleepSummary() { lastNightHours = last.hours }
		sevenDayAvg = storage.sevenDayAverages()
		sleepDebtHours = storage.sleepDebt()
		let entries = storage.listReadiness().sorted { $0.date > $1.date }
		if let e = entries.first { latestReadiness = storage.computeReadiness(from: e) }
	}
}
