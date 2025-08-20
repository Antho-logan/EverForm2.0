import Foundation
import Observation

@Observable final class FlowPlayerViewModel {
	let routine: MobilityRoutine
	private let storage = MobilityStorageService()
	var index: Int = 0
	var remainingSec: Int = 0
	var running: Bool = false
	private var timer: Timer?

	init(routine: MobilityRoutine) {
		self.routine = routine
		prepare()
	}
	deinit { timer?.invalidate() }

	private func prepare() {
		remainingSec = routine.moves.first?.holdSec ?? 0
	}

	func start() {
		running = true
		TelemetryService.track("mobility_flow_start", props: ["routine": routine.name])
		timer?.invalidate()
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
			guard let self else { return }
			guard self.running else { t.invalidate(); return }
			self.remainingSec = max(0, self.remainingSec - 1)
			if self.remainingSec == 0 { self.next() }
		}
	}
	func next() {
		if index + 1 < routine.moves.count {
			index += 1
			remainingSec = routine.moves[index].holdSec
		} else { complete() }
	}
	func back() {
		if index > 0 { index -= 1; remainingSec = routine.moves[index].holdSec }
	}
	func complete() {
		running = false
		let log = MobilitySessionLog(id: UUID(), date: Date(), routineId: routine.id, durationMin: routine.durationMin, notes: nil)
		storage.addLog(log)
	}
}







