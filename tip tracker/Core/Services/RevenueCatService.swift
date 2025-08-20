import Foundation

/// RevenueCat service stub. No network calls.
enum RevenueCatService {
	static private(set) var isPro: Bool = false
	static func configure(apiKey: String) {
		DebugLog.info("RevenueCat configured with apiKey=(hidden)")
	}
}

