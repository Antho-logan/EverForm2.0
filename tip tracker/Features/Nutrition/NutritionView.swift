import SwiftUI

struct NutritionView: View {
	@State private var model = NutritionViewModel()
	@State private var route: String? = nil

	var body: some View {
		ZStack { Theme.bg.ignoresSafeArea() }
		.overlay(
			ScrollView {
				VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
					Theme.h1("Nutrition")

					EFCard { todaySection }
					EFCard { averagesSection }

					HStack(spacing: Theme.Spacing.md) {
						EFButton(title: "Add Meal", style: .primary, fullWidth: true, accessibilityId: "add_meal_button") {
							TelemetryService.track("add_meal_tap")
							route = "logger"
						}
						EFButton(title: "Targets", style: .secondary, fullWidth: true, accessibilityId: "targets_button") {
							TelemetryService.track("targets_tap")
							route = "targets"
						}
					}

					EFButton(title: "Trends", style: .ghost, fullWidth: true, accessibilityId: "trends_button") {
						TelemetryService.track("trends_tap")
						route = "trends"
					}

					EFCard {
						VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
							Text("Meal Plans").font(Theme.Typography.heading)
							EFButton(title: "Open", style: .secondary, fullWidth: true, accessibilityId: "meal_plans_button") {
								route = "plans"
							}
						}
					}
				}
				.padding(.horizontal, Theme.Spacing.lg)
				.padding(.vertical, Theme.Spacing.xl)
			}
		)
		.onAppear { DebugLog.info("NutritionView onAppear"); model.load() }
		.navigationDestination(item: $route) { val in
			buildRoute(val)
		}
	}

	private var todaySection: some View {
		VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
			Text("Today").font(Theme.Typography.heading)
			HStack { Text("Calories"); Spacer(); Text("\(Int(model.todayTotals.kcal)) / \(model.targets.kcal)") }
			HStack { Text("Protein"); Spacer(); Text("\(Int(model.todayTotals.protein))g / \(model.targets.proteinG)g") }
			HStack { Text("Carbs"); Spacer(); Text("\(Int(model.todayTotals.carbs))g / \(model.targets.carbsG)g") }
			HStack { Text("Fat"); Spacer(); Text("\(Int(model.todayTotals.fat))g / \(model.targets.fatG)g") }
		}
	}

	private var averagesSection: some View {
		VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
			Text("Averages").font(Theme.Typography.heading)
			HStack { Text("Week Avg"); Spacer(); Text("\(Int(model.weekAvgKcal)) kcal") }
			HStack { Text("Month Avg"); Spacer(); Text("\(Int(model.monthAvgKcal)) kcal") }
		}
	}

	@ViewBuilder private func buildRoute(_ value: String) -> some View {
		switch value {
		case "logger": MealLoggerView(model: MealLoggerViewModel())
		case "targets": MacroSettingsView(model: MacroSettingsViewModel())
		case "trends": CalorieTrendsView(model: CalorieTrendsViewModel())
		case "plans": MealPlanTemplatesView(model: MealPlanTemplatesViewModel())
		default: Text(value)
		}
	}
}
