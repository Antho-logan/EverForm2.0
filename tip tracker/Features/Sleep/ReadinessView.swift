import SwiftUI

struct ReadinessView: View {
	@State var model: ReadinessViewModel
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
				Theme.h1("Readiness")
				EFCard {
					VStack(alignment: .leading, spacing: Theme.Spacing.md) {
						HStack { Text("Resting Heart Rate"); Spacer(); Stepper(value: $model.rhr, in: 30...100) { Text("\(model.rhr) bpm") } }
						HStack { Text("Heart Rate Variability"); Spacer(); Stepper(value: $model.hrv, in: 10...150) { Text("\(model.hrv) ms") } }
						HStack { Text("Sleep Hours"); Spacer(); Stepper(value: $model.sleepHours, in: 0...12, step: 0.5) { Text(String(format: "%.1f h", model.sleepHours)) } }
						EFButton(title: "Save", style: .primary, fullWidth: true, accessibilityId: "readiness_save_button") { model.compute(); model.save() }
					}
				}
				if let s = model.score {
					EFCard {
						VStack(alignment: .leading, spacing: Theme.Spacing.sm) { HStack { Text("Score"); Spacer(); Text("\(s.score)") }; Text(s.advice) }
					}
				}
				/* Future integrations:
				- Apple Health: read HRV/RHR and sleep hours
				- Oura / WHOOP: import readiness metrics via SDK
				*/
			}
			.padding(.horizontal, Theme.Spacing.lg)
			.padding(.vertical, Theme.Spacing.xl)
		}
	}
}







