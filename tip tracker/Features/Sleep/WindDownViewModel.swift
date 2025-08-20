import Foundation
import Observation

@Observable final class WindDownViewModel {
	private let storage = RecoveryStorageService()
	let protocols: [WindDownProtocol]
	var selectedIndex: Int = 0
	var isRunning: Bool = false
	var currentStepIndex: Int = 0
	var remainingSec: Int = 0
	private var timer: Timer?

	init() { self.protocols = storage.defaultWindDowns() }
	deinit { timer?.invalidate() }

	func start() {
		guard !protocols.isEmpty else { return }
		let step = protocols[selectedIndex].steps[currentStepIndex]
		remainingSec = step.minutes * 60
		isRunning = true
		TelemetryService.track("winddown_start")
		tick()
	}
	private func tick() {
		timer?.invalidate()
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
			guard let self else { return }
			guard self.isRunning else { t.invalidate(); return }
			self.remainingSec = max(0, self.remainingSec - 1)
			if self.remainingSec == 0 { self.advance() }
		}
	}
	func advance() {
		let p = protocols[selectedIndex]
		if currentStepIndex + 1 < p.steps.count {
			currentStepIndex += 1
			remainingSec = p.steps[currentStepIndex].minutes * 60
			tick()
		} else { complete() }
	}
	func complete() {
		isRunning = false
		storage.logWinddownCompletion()
	}
}







