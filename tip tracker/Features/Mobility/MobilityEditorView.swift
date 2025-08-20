import SwiftUI

struct MobilityEditorView: View {
	@State var model: MobilityEditorViewModel
	@Environment(\.dismiss) private var dismiss
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
				Theme.h1("Build Routine")
				TextField("Routine name", text: $model.name).textFieldStyle(.roundedBorder)
				EFCard {
					VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
						Text("Library").font(Theme.Typography.heading)
						ForEach(model.library) { m in
							Button(action: { model.addMove(m) }) { HStack { Text(m.name); Spacer(); Text(m.targetArea).foregroundColor(Theme.textSecondary) } }
							.buttonStyle(.plain)
						}
					}
				}
				EFCard {
					VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
						Text("Selected Moves").font(Theme.Typography.heading)
						ForEach(Array(model.moves.enumerated()), id: \.offset) { i, m in
							HStack { Text(m.name); Spacer(); Text("\(m.holdSec)s") }
						}
					}
				}
				EFButton(title: "Save Routine", style: .primary, fullWidth: true, accessibilityId: "save_routine_button") { model.save(); TelemetryService.track("mobility_saved_routine"); dismiss() }
			}
			.padding(.horizontal, Theme.Spacing.lg)
			.padding(.vertical, Theme.Spacing.xl)
		}
	}
}







