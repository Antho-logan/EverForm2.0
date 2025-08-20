import Foundation
import Observation

@Observable final class MobilityViewModel {
	private let storage = MobilityStorageService()
	private(set) var routines: [MobilityRoutine] = []

	func load() {
		storage.seedIfNeeded()
		routines = storage.listRoutines()
	}
}







