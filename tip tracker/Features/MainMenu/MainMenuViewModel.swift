import Foundation
import Observation

@Observable final class MainMenuViewModel {
	func didSelect(tile: String) {
		DebugLog.info("MainMenu tile selected: \(tile)")
	}
}

