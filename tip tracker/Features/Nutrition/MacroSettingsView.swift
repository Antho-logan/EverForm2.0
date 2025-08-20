import SwiftUI

struct MacroSettingsView: View {
	let model: MacroSettingsViewModel
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
				Theme.h1("Macro Targets")
				EFCard {
					VStack(alignment: .leading, spacing: Theme.Spacing.md) {
						Text("Activity Level").font(Theme.Typography.subbody)
						Picker("", selection: Binding(get: { model.activity }, set: { model.activity = $0 })) {
							ForEach(ActivityLevel.allCases) { lvl in Text(lvl.description).tag(lvl) }
						}
					}
				}
				EFCard {
					VStack(alignment: .leading, spacing: Theme.Spacing.md) {
						Text("Goal").font(Theme.Typography.subbody)
						Picker("", selection: Binding(get: { model.goal }, set: { model.goal = $0 })) {
							ForEach(NutritionGoal.allCases) { g in Text(g.description).tag(g) }
						}
					}
				}
				EFCard {
					VStack(alignment: .leading, spacing: Theme.Spacing.md) {
						Text("Protein g/kg").font(Theme.Typography.subbody)
						Stepper(value: Binding(get: { model.proteinPerKg }, set: { model.proteinPerKg = $0 }), in: 1.2...3.0, step: 0.1) {
							Text(String(format: "%.1f g/kg", model.proteinPerKg))
						}
					}
				}
				EFCard {
					VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
						Text("Computed Targets").font(Theme.Typography.heading)
						HStack { Text("Calories"); Spacer(); Text("\(model.targets.kcal)") }
						HStack { Text("Protein"); Spacer(); Text("\(model.targets.proteinG) g") }
						HStack { Text("Carbs"); Spacer(); Text("\(model.targets.carbsG) g") }
						HStack { Text("Fat"); Spacer(); Text("\(model.targets.fatG) g") }
					}
				}
				EFButton(title: "Save", style: .primary, fullWidth: true, accessibilityId: "save_targets_button") {
					model.save(); dismiss()
				}
			}
			.padding(.horizontal, Theme.Spacing.lg)
			.padding(.vertical, Theme.Spacing.xl)
		}
		.onAppear { model.onAppear() }
	}
}







