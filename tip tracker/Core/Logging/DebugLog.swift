import Foundation

/// Centralized debug logging. Active in DEBUG builds only.
enum DebugLog {
	static func info(_ message: String) {
		#if DEBUG
		print("[INFO] \(message)")
		#endif
	}
	static func error(_ message: String) {
		#if DEBUG
		print("[ERROR] \(message)")
		#endif
	}
}

