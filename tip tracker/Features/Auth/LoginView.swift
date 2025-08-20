import SwiftUI

struct LoginView: View {
	@State private var email: String = ""
	@State private var password: String = ""
	@State private var showError: Bool = false
	@State private var toProfile: Bool = false
	@State private var toMain: Bool = false
	private let session = SessionStore()
	private let profile = ProfileService()

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
				EFCard {
					VStack(alignment: .leading, spacing: Theme.Spacing.md) {
						Text("Log in").font(Theme.Typography.heading)
						TextField("Email", text: $email)
							.textContentType(.emailAddress)
							.keyboardType(.emailAddress)
						SecureField("Password", text: $password)
						EFButton(title: "Log in", style: .primary, fullWidth: true, accessibilityId: "login_primary_button") { onTapLogin() }
						if showError { Text("Please enter email and password").foregroundColor(.red) }
					}
				}

				EFDividerLabel(text: "Or continue with")
				VStack(spacing: Theme.Spacing.sm) {
					EFSocialButton(provider: .apple, title: "Sign in with Apple", accessibilityId: "login_social_apple") {
						TelemetryService.track("auth_social_tap", props: ["provider": "apple"])
						_ = session.socialLogin(provider: .apple); routeAfterAuth()
					}
					EFSocialButton(provider: .google, title: "Sign in with Google", accessibilityId: "login_social_google") {
						TelemetryService.track("auth_social_tap", props: ["provider": "google"])
						_ = session.socialLogin(provider: .google); routeAfterAuth()
					}
					EFSocialButton(provider: .facebook, title: "Sign in with Facebook", accessibilityId: "login_social_facebook") {
						TelemetryService.track("auth_social_tap", props: ["provider": "facebook"])
						_ = session.socialLogin(provider: .facebook); routeAfterAuth()
					}
				}
				Text("You can continue as guest to explore.")
					.font(.footnote)
					.foregroundColor(Theme.textSecondary)
			}
			.padding(.horizontal, Theme.Spacing.lg)
			.padding(.vertical, Theme.Spacing.xl)
		}
		.safeAreaInset(edge: .bottom) {
			EFButton(title: "Continue as Guest", style: .ghost, fullWidth: true, accessibilityId: "login_continue_guest_button") {
				TelemetryService.track("auth_guest_tap")
				session.guestLogin(); routeAfterAuth()
			}
			.padding(.horizontal, Theme.Spacing.xl)
			.padding(.vertical, Theme.Spacing.md)
		}
		.navigationDestination(isPresented: $toProfile) { OnboardingProfileView(model: profile) }
		.navigationDestination(isPresented: $toMain) { MainMenuView(model: MainMenuViewModel()) }
		.onAppear { DebugLog.info("LoginView onAppear") }
	}

	private func onTapLogin() {
		DebugLog.info("onTapLogin")
		guard !email.isEmpty, !password.isEmpty else {
			showError = true
			DebugLog.error("Login validation failed")
			return
		}
		let ok = session.login(email: email, password: password)
		guard ok else { showError = true; return }
		routeAfterAuth()
	}

	private func routeAfterAuth() {
		if profile.hasCompletedOnboarding { toMain = true } else { toProfile = true }
	}
}
