import Foundation
import Observation

/// Manages session lifecycle. Stubbed for Part A; no network.
@Observable final class SessionStore {
	private let defaults = UserDefaults.standard
	private let keyIsLoggedIn = "session.isLoggedIn"

	enum SocialProvider: String { case apple, google, facebook }

	var isLoggedIn: Bool {
		get { defaults.bool(forKey: keyIsLoggedIn) }
		set {
			defaults.set(newValue, forKey: keyIsLoggedIn)
			DebugLog.info("Session isLoggedIn changed -> \(newValue)")
		}
	}

	func login(email: String, password: String) -> Bool {
		DebugLog.info("Login attempt (masked)")
		guard !email.isEmpty, !password.isEmpty else {
			DebugLog.error("Login validation failed: empty fields")
			return false
		}
		isLoggedIn = true
		DebugLog.info("Login success; isLoggedIn=true")
		return true
	}

	func signup(email: String, displayName: String, password: String) -> Bool {
		DebugLog.info("Signup attempt (masked)")
		guard !email.isEmpty, !displayName.isEmpty, !password.isEmpty else {
			DebugLog.error("Signup validation failed: empty fields")
			return false
		}
		isLoggedIn = true
		DebugLog.info("Signup success; isLoggedIn=true")
		return true
	}

	func guestLogin() {
		DebugLog.info("Guest login triggered")
		isLoggedIn = true
	}

	func socialLogin(provider: SocialProvider) -> Bool {
		DebugLog.info("Social login stub provider=\(provider.rawValue)")
		isLoggedIn = true
		return true
	}

	func logout() {
		isLoggedIn = false
		DebugLog.info("Logged out; isLoggedIn=false")
	}
}

