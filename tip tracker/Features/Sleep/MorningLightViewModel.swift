import Foundation
import Observation

@Observable final class MorningLightViewModel {
	private let storage = RecoveryStorageService()
	var sunlightRemainingSec: Int = 15 * 60
	var caffeineDelayRemainingSec: Int = 60 * 60
	var sunRunning: Bool = false
	var caffeineRunning: Bool = false
	private var sunTimer: Timer?
	private var cafTimer: Timer?

	deinit { sunTimer?.invalidate(); cafTimer?.invalidate() }

	func startSunlight() {
		sunRunning = true
		TelemetryService.track("morning_start")
		sunTimer?.invalidate()
		sunTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
			guard let self else { return }
			guard self.sunRunning else { t.invalidate(); return }
			self.sunlightRemainingSec = max(0, self.sunlightRemainingSec - 1)
			if self.sunlightRemainingSec == 0 { self.sunRunning = false; self.storage.logMorningCompletion() }
		}
	}
	func startCaffeineDelay() {
		caffeineRunning = true
		cafTimer?.invalidate()
		cafTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] t in
			guard let self else { return }
			guard self.caffeineRunning else { t.invalidate(); return }
			self.caffeineDelayRemainingSec = max(0, self.caffeineDelayRemainingSec - 1)
			if self.caffeineDelayRemainingSec == 0 { self.caffeineRunning = false }
		}
	}
}







