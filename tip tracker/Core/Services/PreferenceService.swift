import Foundation
import Observation

/// Stores user preferences. Stubbed persistence for Part A.
@Observable final class PreferenceService {
	var theme: String = "system"
	var accent: String = "indigo"
	var dietStyle: String = "Mediterranean"
	var allowAnalytics: Bool = false
	var allowHealthImport: Bool = false

	func save() {
		DebugLog.info("Preferences saved: theme=\(theme) accent=\(accent) diet=\(dietStyle) analytics=\(allowAnalytics)")
	}
}







