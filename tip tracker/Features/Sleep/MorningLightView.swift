import SwiftUI

struct MorningLightView: View {
	@State var model: MorningLightViewModel
	var body: some View {
		VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
			Theme.h1("Morning Light")
			EFCard {
				VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
					Text("Sunlight Timer")
					HStack { Spacer(); Text(timeString(model.sunlightRemainingSec)) }
					EFButton(title: "Start", style: .primary, fullWidth: true, accessibilityId: "morning_sun_start") { model.startSunlight() }
				}
			}
			EFCard {
				VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
					Text("Caffeine Delay")
					HStack { Spacer(); Text(timeString(model.caffeineDelayRemainingSec)) }
					EFButton(title: "Start", style: .secondary, fullWidth: true, accessibilityId: "morning_caf_start") { model.startCaffeineDelay() }
				}
			}
		}
		.padding(.horizontal, Theme.Spacing.lg)
		.padding(.vertical, Theme.Spacing.xl)
	}

	private func timeString(_ sec: Int) -> String {
		String(format: "%02d:%02d", sec/60, sec%60)
	}
}







