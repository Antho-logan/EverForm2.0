import SwiftUI

struct MainMenuView: View {
	let model: MainMenuViewModel

	let tiles: [String] = [
		"Training", "Nutrition", "Sleep & Recovery", "Mobility", "Supplements", "Progress", "Settings"
	]

	@State private var route: String? = nil

	var body: some View {
		ZStack { Theme.bg.ignoresSafeArea() }
		.overlay(
			ScrollView {
				VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
					Theme.h1("Main Menu")
					LazyVStack(spacing: 0) {
						ForEach(tiles, id: \.self) { tile in
							EFTile(systemImage: icon(for: tile), title: tile) {
								onTap(tile)
							}
							.accessibilityLabel("tile_\(tile)")
						}
					}
				}
				.padding(.horizontal, Theme.Spacing.xl)
			}
		)
		.onAppear { DebugLog.info("MainMenuView onAppear") }
		.navigationDestination(item: $route) { value in
			view(for: value)
		}
	}

	private func onTap(_ tile: String) {
		model.didSelect(tile: tile)
		TelemetryService.track("nav_tile_tap", props: ["tile": tile])
		route = tile
	}

	private func icon(for tile: String) -> String {
		switch tile {
		case "Training": return "figure.strengthtraining.traditional"
		case "Nutrition": return "carrot"
		case "Sleep & Recovery": return "bed.double"
		case "Mobility": return "figure.cooldown"
		case "Supplements": return "pills"
		case "Progress": return "chart.bar"
		case "Settings": return "gear"
		default: return "square"
		}
	}

	@ViewBuilder
	private func view(for tile: String) -> some View {
		switch tile {
		case "Training": TrainingView()
		case "Nutrition": NutritionView()
		case "Sleep & Recovery": SleepRecoveryView()
		case "Mobility": MobilityView()
		case "Supplements": SupplementsView()
		case "Progress": ProgressViewScreen()
		case "Settings": SettingsView()
		default: Text(tile)
		}
	}
}

