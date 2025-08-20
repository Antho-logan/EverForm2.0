import Foundation
import Observation

@Observable final class SleepHistoryViewModel {
	private let storage = RecoveryStorageService()
	private(set) var winddowns: [Date] = []
	private(set) var mornings: [Date] = []
	private(set) var readiness: [ReadinessEntry] = []

	func load() {
		winddowns = storage.listWinddownCompletions().sorted(by: >)
		mornings = storage.listMorningCompletions().sorted(by: >)
		readiness = storage.listReadiness().sorted { $0.date > $1.date }
	}
}







