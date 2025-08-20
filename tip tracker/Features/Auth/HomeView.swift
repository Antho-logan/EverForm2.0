import SwiftUI

struct HomeView: View {
	var body: some View {
		ZStack { Theme.bg.ignoresSafeArea() }
		.overlay(
			VStack(spacing: Theme.Spacing.xl) {
				VStack(spacing: Theme.Spacing.sm) {
					Theme.h1("EverForm")
					Theme.body("Build your best self. Biohack your routines.")
				}
				HStack(spacing: Theme.Spacing.md) {
					NavigationLink(value: "Login") {
						EFButton(title: "Log in", style: .primary, fullWidth: true, accessibilityId: "log_in_button") {}
					}
					NavigationLink(value: "CreateAccount") {
						EFButton(title: "Create account", style: .secondary, fullWidth: true, accessibilityId: "create_account_button") {}
					}
				}

				EFDividerLabel(text: "Or continue with")
				VStack(spacing: Theme.Spacing.sm) {
					EFSocialButton(provider: .apple, title: "Sign in with Apple", accessibilityId: "social_apple") {
						TelemetryService.track("auth_social_tap", props: ["provider": "apple"])
						let s = SessionStore(); _ = s.socialLogin(provider: .apple)
					}
					EFSocialButton(provider: .google, title: "Sign in with Google", accessibilityId: "social_google") {
						TelemetryService.track("auth_social_tap", props: ["provider": "google"])
						let s = SessionStore(); _ = s.socialLogin(provider: .google)
					}
					EFSocialButton(provider: .facebook, title: "Sign in with Facebook", accessibilityId: "social_facebook") {
						TelemetryService.track("auth_social_tap", props: ["provider": "facebook"])
						let s = SessionStore(); _ = s.socialLogin(provider: .facebook)
					}
				}
			}
			.padding(.horizontal, Theme.Spacing.xl)
		)
		.safeAreaInset(edge: .bottom) {
			EFButton(title: "Continue as Guest", style: .ghost, fullWidth: true, accessibilityId: "continue_guest_button") {
				TelemetryService.track("auth_guest_tap")
				let session = SessionStore(); session.guestLogin()
			}
			.padding(.horizontal, Theme.Spacing.xl)
			.padding(.vertical, Theme.Spacing.md)
		}
		.onAppear { DebugLog.info("HomeView onAppear") }
	}
}
