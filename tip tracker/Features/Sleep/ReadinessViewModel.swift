import Foundation
import Observation

@Observable final class ReadinessViewModel {
	private let storage = RecoveryStorageService()
	var rhr: Int = 60
	var hrv: Int = 60
	var sleepHours: Double = 7.0
	private(set) var score: ReadinessScore? = nil

	func compute() {
		let entry = ReadinessEntry(date: Date(), rhr: rhr, hrv: hrv, sleepHours: sleepHours)
		score = storage.computeReadiness(from: entry)
	}
	func save() {
		let entry = ReadinessEntry(date: Date(), rhr: rhr, hrv: hrv, sleepHours: sleepHours)
		storage.addReadiness(entry)
		TelemetryService.track("readiness_saved")
	}
}







