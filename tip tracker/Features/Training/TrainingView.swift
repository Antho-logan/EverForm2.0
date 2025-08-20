import SwiftUI

struct TrainingView: View {
	@State private var model = TrainingViewModel()
	@State private var route: String? = nil
	@State private var selectedTemplate: TrainingTemplate? = nil

	var body: some View {
		ZStack { Theme.bg.ignoresSafeArea() }
		.overlay(
			ScrollView {
				VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
					EFSegmented(segments: TrainingFocus.allCases.map { $0.rawValue }, selection: Binding(
						get: { model.selectedFocus.rawValue },
						set: { raw in if let f = TrainingFocus(rawValue: raw) { model.selectFocus(f) } }
					))
					.accessibilityLabel("training_focus_segment")

					LazyVStack(spacing: Theme.Spacing.md) {
						ForEach(model.filteredTemplates) { tpl in
							EFCard {
								VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
									HStack { Text(tpl.title).font(Theme.Typography.heading); Spacer(); Text(tpl.focus.rawValue).foregroundColor(Theme.textSecondary) }
									HStack(spacing: Theme.Spacing.sm) {
										ForEach([1,3,5,7], id: \.self) { d in
											let count = tpl.weekDays[d]?.count ?? 0
											Text("Day \(d): \(count) ex").font(Theme.Typography.caption)
												.padding(6)
												.background(Theme.surface)
												.cornerRadius(6)
										}
									}
									HStack {
										EFButton(title: "View Template", style: .secondary, accessibilityId: "view_template_button_\(tpl.id.uuidString)") {
											selectedTemplate = tpl; route = "template"
										}
										Spacer()
										EFButton(title: "Start Workout", style: .primary, accessibilityId: "start_workout_button_\(tpl.id.uuidString)") {
											selectedTemplate = tpl; route = "start_day_1"
										}
									}
								}
							}
						}
						.padding(.horizontal, Theme.Spacing.xl)
					}
				}
			}
		)
		.onAppear {
			DebugLog.info("TrainingView onAppear")
			model.load()
		}
		.navigationDestination(item: $route) { value in
			routeView(value)
		}
	}

	@ViewBuilder private func routeView(_ value: String) -> some View {
		switch value {
		case "template":
			if let tpl = selectedTemplate {
				TrainingTemplateDetailView(model: TrainingTemplateDetailViewModel(template: tpl))
			} else {
				Text("Template not found")
			}
		case "start_day_1":
			if let tpl = selectedTemplate {
				let vm = model.startWorkoutSession(template: tpl, dayIndex: 1)
				WorkoutSessionView(model: vm)
			} else { Text("Template not found") }
		case "history":
			TrainingHistoryView(model: model.historyViewModel())
		default:
			Text(value)
		}
	}
}
