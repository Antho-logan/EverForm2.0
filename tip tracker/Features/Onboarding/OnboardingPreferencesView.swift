import SwiftUI

struct OnboardingPreferencesView: View {
	let model: PreferenceService

	var body: some View {
		Form {
			Section(header: Text("Appearance")) {
				Text("Theme: \(model.theme)")
				Text("Accent: \(model.accent)")
			}
			Section(header: Text("Health")) {
				Toggle("Allow Analytics", isOn: .constant(model.allowAnalytics))
				Toggle("Allow Health Import", isOn: .constant(model.allowHealthImport))
			}
			Section {
				EFButton(title: "Save", style: .primary, fullWidth: true, accessibilityId: "onboarding_prefs_save_button") {
					model.save()
				}
			}
		}
		.navigationTitle("Preferences")
	}
}


