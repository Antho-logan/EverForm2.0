import SwiftUI

struct MobilityView: View {
	@State private var model = MobilityViewModel()
	@State private var route: String? = nil
	@State private var selected: MobilityRoutine? = nil
	var body: some View {
		ZStack { Theme.bg.ignoresSafeArea() }
		.overlay(
			ScrollView {
				VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
					Theme.h1("Mobility")
					ForEach(model.routines) { r in
						EFCard {
							HStack { Text(r.name).font(Theme.Typography.heading); Spacer(); Text("\(r.durationMin)m") }
							EFButton(title: "Start", style: .primary, fullWidth: true, accessibilityId: "mob_start_\(r.id)") {
								selected = r; route = "play"
							}
						}
					}
					EFButton(title: "Build Routine", style: .secondary, fullWidth: true, accessibilityId: "mob_build_button") { route = "edit" }
				}
				.padding(.horizontal, Theme.Spacing.lg)
				.padding(.vertical, Theme.Spacing.xl)
			}
		)
		.onAppear { DebugLog.info("MobilityView onAppear"); TelemetryService.track("mobility_open"); model.load() }
		.navigationDestination(item: $route) { r in
			buildRoute(r)
		}
	}
	@ViewBuilder private func buildRoute(_ r: String) -> some View {
		switch r {
		case "play": if let s = selected { FlowPlayerView(model: FlowPlayerViewModel(routine: s)) } else { Text("No routine") }
		case "edit": MobilityEditorView(model: MobilityEditorViewModel())
		default: Text(r)
		}
	}
}
