import SwiftUI

struct SleepRecoveryView: View {
	@State private var model = SleepRecoveryViewModel()
	@State private var route: String? = nil
	var body: some View {
		ZStack { Theme.bg.ignoresSafeArea() }
		.overlay(
			ScrollView {
				VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
					Theme.h1("Sleep & Recovery")
					EFCard {
						VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
							Text("Last Night"); HStack { Spacer(); Text("\(String(format: "%.1f", model.lastNightHours)) h") }
							Text("7-Day Avg"); HStack { Spacer(); Text("\(String(format: "%.1f", model.sevenDayAvg)) h") }
							Text("Sleep Debt"); HStack { Spacer(); Text("\(Int(model.sleepDebtHours)) h") }
						}
					}
					EFCard {
						VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
							Text("Readiness").font(Theme.Typography.heading)
							if let r = model.latestReadiness { HStack { Text("Score"); Spacer(); Text("\(r.score)") } ; Text(r.advice).foregroundColor(Theme.textSecondary) }
							else { Text("No data").foregroundColor(Theme.textSecondary) }
						}
					}
					HStack(spacing: Theme.Spacing.md) {
						EFButton(title: "Wind-Down", style: .primary, fullWidth: true, accessibilityId: "winddown_button") { route = "wind" }
						EFButton(title: "Morning Light", style: .secondary, fullWidth: true, accessibilityId: "morning_button") { route = "morning" }
					}
					HStack(spacing: Theme.Spacing.md) {
						EFButton(title: "Readiness", style: .secondary, fullWidth: true, accessibilityId: "readiness_button") { route = "ready" }
						EFButton(title: "History", style: .ghost, fullWidth: true, accessibilityId: "sleep_history_button") { route = "history" }
					}
				}
				.padding(.horizontal, Theme.Spacing.lg)
				.padding(.vertical, Theme.Spacing.xl)
			}
		)
		.onAppear { DebugLog.info("SleepRecoveryView onAppear"); TelemetryService.track("sleep_open"); model.load() }
		.navigationDestination(item: $route) { r in
			buildRoute(r)
		}
	}

	@ViewBuilder private func buildRoute(_ r: String) -> some View {
		switch r {
		case "wind": WindDownView(model: WindDownViewModel())
		case "morning": MorningLightView(model: MorningLightViewModel())
		case "ready": ReadinessView(model: ReadinessViewModel())
		case "history": SleepHistoryView(model: SleepHistoryViewModel())
		default: Text(r)
		}
	}
}
