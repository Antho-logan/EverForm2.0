import SwiftUI

struct MealPlanTemplatesView: View {
	let model: MealPlanTemplatesViewModel
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
				Theme.h1("Meal Plans")
				ForEach(model.plans) { plan in
					EFCard {
						VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
							Text(plan.title).font(Theme.Typography.heading)
							Text(plan.summary).foregroundColor(Theme.textSecondary)
						}
					}
				}
			}
			.padding(.horizontal, Theme.Spacing.lg)
			.padding(.vertical, Theme.Spacing.xl)
		}
	}
}







