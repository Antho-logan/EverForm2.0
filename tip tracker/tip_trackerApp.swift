import SwiftUI
import Observation

@main
struct TipTrackerApp: App {
	@State private var sessionStore = SessionStore()
	@State private var profileService = ProfileService()

	init() {
		let env = Bundle.main.object(forInfoDictionaryKey: "AppEnvironment") as? String ?? "dev"
		let telemetryId = Bundle.main.object(forInfoDictionaryKey: "TelemetryAppID") as? String ?? ""
		let revenueKey = Bundle.main.object(forInfoDictionaryKey: "RevenueCatAPIKey") as? String ?? ""
		DebugLog.info("[Boot] APP_ENV=\(env)")
		TelemetryService.configure(appID: telemetryId)
		RevenueCatService.configure(apiKey: revenueKey)
	}

	var body: some Scene {
		WindowGroup {
			RootRouterView(sessionStore: sessionStore, profileService: profileService)
		}
	}
}

struct RootRouterView: View {
	let sessionStore: SessionStore
	let profileService: ProfileService

	@State private var path = NavigationPath()

	var body: some View {
		NavigationStack(path: $path) {
			Group {
				if sessionStore.isLoggedIn == false {
					HomeView()
						.navigationDestination(for: String.self) { route in
							destination(for: route)
						}
				} else if profileService.hasCompletedOnboarding == false {
					OnboardingProfileView(model: profileService)
						.navigationDestination(for: String.self) { route in
							destination(for: route)
						}
				} else {
					MainMenuView(model: MainMenuViewModel())
				}
			}
		}
		.onAppear {
			DebugLog.info("[Boot] Routing isLoggedIn=\(sessionStore.isLoggedIn) hasCompletedOnboarding=\(profileService.hasCompletedOnboarding)")
		}
	}

	@ViewBuilder
	private func destination(for route: String) -> some View {
		switch route {
		case "Login": LoginView()
		case "CreateAccount": CreateAccountView()
		case "OnboardingProfile": OnboardingProfileView(model: profileService)
		case "OnboardingPreferences": OnboardingPreferencesView(model: PreferenceService())
		case "MainMenu": MainMenuView(model: MainMenuViewModel())
		default: Text(route)
		}
	}
}

