import SwiftUI

struct SettingsView: View {
	@State private var showDone: Bool = false
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		ZStack { Theme.bg.ignoresSafeArea() }
		.overlay(
			ScrollView {
				VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
					Theme.h1("Settings")

					EFCard {
						VStack(alignment: .leading, spacing: Theme.Spacing.md) {
							Text("Danger Zone")
								.font(Theme.Typography.subbody)
								.foregroundColor(Theme.warning)
							EFButton(title: "Reset App State", style: .secondary, fullWidth: true, accessibilityId: "reset_app_state_button") {
								resetApp()
							}
						}
					}

					#if DEBUG
					EFCard {
						VStack(alignment: .leading, spacing: Theme.Spacing.md) {
							Text("Developer")
								.font(Theme.Typography.subbody)
								.foregroundColor(Theme.textSecondary)
							EFButton(title: "Quick → Onboarding", style: .ghost, fullWidth: true, accessibilityId: "dev_quick_onboarding_button") {
								quickToOnboarding()
							}
						}
					}
					#endif
				}
				.padding(.horizontal, Theme.Spacing.lg)
				.padding(.vertical, Theme.Spacing.xl)
			}
		)
		.alert("Done", isPresented: $showDone) { Button("OK", role: .cancel) { dismiss() } } message: { Text("Operation completed") }
		.onAppear { DebugLog.info("SettingsView onAppear") }
	}

	private func resetApp() {
		DebugLog.info("Settings: Reset App State")
		SessionStore().logout()
		ProfileService().resetOnboarding()
		showDone = true
	}

	private func quickToOnboarding() {
		DebugLog.info("Settings: Quick → Onboarding")
		let defaults = UserDefaults.standard
		defaults.set(true, forKey: "session.isLoggedIn")
		defaults.set(false, forKey: "profile.hasCompletedOnboarding")
		showDone = true
	}
}
