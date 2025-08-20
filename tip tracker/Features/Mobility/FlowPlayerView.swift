import SwiftUI

struct FlowPlayerView: View {
	@State var model: FlowPlayerViewModel
	var body: some View {
		VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
			Theme.h1(model.routine.name)
			let move = model.routine.moves[model.index]
			EFCard { VStack(alignment: .leading, spacing: Theme.Spacing.sm) { Text(move.name).font(Theme.Typography.heading); Text(move.targetArea).foregroundColor(Theme.textSecondary); HStack { Spacer(); Text("\(model.remainingSec)s") } } }
			HStack(spacing: Theme.Spacing.md) {
				EFButton(title: "Back", style: .secondary, fullWidth: true, accessibilityId: "flow_back_button") { model.back() }
				EFButton(title: model.running ? "Next" : "Start", style: .primary, fullWidth: true, accessibilityId: "flow_next_button") { model.running ? model.next() : model.start() }
			}
		}
		.padding(.horizontal, Theme.Spacing.lg)
		.padding(.vertical, Theme.Spacing.xl)
	}
}







