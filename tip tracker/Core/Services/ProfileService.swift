import Foundation
import Observation

struct Profile {
	var gender: String = ""
	var goal: String = ""
	var unitSystem: String = "metric"
	var heightCm: Double = 0
	var weightKg: Double = 0
	var bodyFatPercent: Double? = nil
}

/// Stores basic profile data. Stubbed persistence for Part A.
@Observable final class ProfileService {
	private let defaults = UserDefaults.standard
	private let keyOnboarding = "profile.hasCompletedOnboarding"

	var profile = Profile()
	var hasCompletedOnboarding: Bool {
		get { defaults.bool(forKey: keyOnboarding) }
		set { defaults.set(newValue, forKey: keyOnboarding) }
	}

	func saveProfile() {
		DebugLog.info("Profile saved: gender=\(profile.gender) goal=\(profile.goal) height=\(profile.heightCm)cm weight=\(profile.weightKg)kg")
	}

	func markOnboardingComplete() {
		hasCompletedOnboarding = true
		DebugLog.info("Onboarding marked complete")
	}

	func resetOnboarding() {
		hasCompletedOnboarding = false
		DebugLog.info("Onboarding reset")
	}
}

