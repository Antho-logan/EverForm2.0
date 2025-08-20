import SwiftUI

struct WindDownView: View {
	@State var model: WindDownViewModel
	var body: some View {
		VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
			Theme.h1("Wind-Down")
			Picker("", selection: $model.selectedIndex) {
				ForEach(Array(model.protocols.enumerated()), id: \.offset) { i, p in Text(p.name).tag(i) }
			}
			.pickerStyle(.segmented)
			EFCard {
				let p = model.protocols[model.selectedIndex]
				VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
					ForEach(Array(p.steps.enumerated()), id: \.offset) { idx, s in
						HStack {
							Text(s.title)
							Spacer()
							Text("\(s.minutes)m")
						}
						.opacity(idx < model.currentStepIndex ? 0.5 : 1)
					}
				}
			}
			if model.isRunning {
				let step = model.protocols[model.selectedIndex].steps[model.currentStepIndex]
				Text("\(step.title)").font(Theme.Typography.heading)
				Text("\(model.remainingSec)s")
				HStack { EFButton(title: "Next", style: .secondary, fullWidth: true, accessibilityId: "wind_next_button") { model.advance() } }
			} else {
				EFButton(title: "Start", style: .primary, fullWidth: true, accessibilityId: "wind_start_button") { model.start() }
			}
		}
		.padding(.horizontal, Theme.Spacing.lg)
		.padding(.vertical, Theme.Spacing.xl)
	}
}







