import SwiftUI

struct MealLoggerView: View {
	let model: MealLoggerViewModel
	@State private var q: String = ""
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
				Theme.h1("Add Meal")
				searchBar
				if let f = model.selectedFood { selectionCard(f) }
				EFCard { todayList }
			}
			.padding(.horizontal, Theme.Spacing.lg)
			.padding(.vertical, Theme.Spacing.xl)
		}
		.onAppear { model.onAppear() }
	}

	private var searchBar: some View {
		VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
			TextField("Search foods…", text: Binding(
				get: { model.query }, set: { model.query = $0; model.search() }
			))
			.textFieldStyle(.roundedBorder)
			LazyVStack(alignment: .leading, spacing: Theme.Spacing.sm) {
				ForEach(model.results, id: \.id) { item in
					Button(action: { model.select(food: item) }) {
						Text(item.name).foregroundColor(Theme.text)
					}
					.buttonStyle(.plain)
				}
			}
		}
	}

	private func selectionCard(_ f: FoodItem) -> some View {
		EFCard {
			VStack(alignment: .leading, spacing: Theme.Spacing.md) {
				Text(f.name).font(Theme.Typography.heading)
				HStack {
					Text("grams")
					Spacer()
					Stepper(value: Binding(get: { model.grams }, set: { model.grams = $0 }), in: 0...2000, step: 10) { Text("\(Int(model.grams)) g") }
				}
				let t = model.computedTotalsForSelected()
				HStack { Text("Calories"); Spacer(); Text("\(Int(t.kcal)) kcal") }
				HStack { Text("Protein"); Spacer(); Text("\(Int(t.protein)) g") }
				HStack { Text("Carbs"); Spacer(); Text("\(Int(t.carbs)) g") }
				HStack { Text("Fat"); Spacer(); Text("\(Int(t.fat)) g") }
				EFButton(title: "Add", style: .primary, fullWidth: true, accessibilityId: "add_food_button") {
					model.addSelectedToToday()
				}
			}
		}
	}

	private var todayList: some View {
		VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
			Text("Today's Meals").font(Theme.Typography.heading)
			LazyVStack(alignment: .leading, spacing: Theme.Spacing.sm) {
				ForEach(model.todayMeals, id: \.id) { meal in
					HStack {
						Text("\(meal.grams, specifier: "%.0f") g")
						Spacer()
						Button("Delete") { model.deleteMeal(id: meal.id) }
					}
				}
			}
		}
	}
}
