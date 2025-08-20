import SwiftUI

struct OnboardingProfileView: View {
	let model: ProfileService

	var body: some View {
		VStack(spacing: Theme.Spacing.lg) {
			Text("Profile Onboarding")
				.font(Theme.Typography.heading)
			Text("Collect basic profile info here.")
			EFButton(title: "Mark Complete", style: .primary, fullWidth: false, accessibilityId: "onboarding_profile_complete_button") {
				model.markOnboardingComplete()
			}
		}
		.padding()
		navigationTitle("Onboarding")
	}
}


