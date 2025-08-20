import Foundation
import Observation

@Observable final class TrainingHistoryViewModel {
	private let storage: TrainingStorageService
	private(set) var logs: [WorkoutLog] = []

	init(storage: TrainingStorageService) { self.storage = storage }

	func load() {
		logs = Array(storage.listWorkoutLogs().prefix(20))
	}
}







