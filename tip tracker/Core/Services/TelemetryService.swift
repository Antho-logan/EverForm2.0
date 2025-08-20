import Foundation

/// Telemetry service stub. Strips potential PII by convention.
enum TelemetryService {
	static func configure(appID: String) {
		DebugLog.info("Telemetry configured with appID=(hidden)")
	}
	static func track(_ event: String, props: [String: String] = [:]) {
		DebugLog.info("Telemetry track: \(event) props=\(props)")
	}
}

