import SwiftUI

struct TrainingTemplateDetailView: View {
	let model: TrainingTemplateDetailViewModel
	@State private var expandedDays: Set<Int> = []
	@State private var route: String? = nil

	var body: some View {
		List {
			Section { header }
			ForEach(model.sortedDays, id: \.self) { day in
				DisclosureGroup(isExpanded: Binding(get: { expandedDays.contains(day) }, set: { isOpen in
					if isOpen { expandedDays.insert(day) } else { expandedDays.remove(day) }
				})) {
					if let items = model.template.weekDays[day] {
						ForEach(items) { ex in
							VStack(alignment: .leading, spacing: 4) {
								Text(ex.displayName).font(.subheadline).bold()
								Text(ex.sets.map { "\($0.targetReps)x reps" }.joined(separator: ", "))
									.font(.caption)
									.foregroundColor(.secondary)
							}
						}
					}
				} label: {
					HStack {
						Text("Day \(day)")
						Spacer()
						Button("Start Day \(day)") { route = "start_\(day)" }
					}
				}
			}
		}
		.navigationTitle(model.template.title)
		.navigationDestination(item: $route) { value in
			routeView(value)
		}
		.onAppear { DebugLog.info("TemplateDetail onAppear title=\(model.template.title)") }
	}

	private var header: some View {
		HStack { Text(model.template.title).bold(); Spacer(); Text(model.template.focus.rawValue).foregroundColor(.secondary) }
	}

	@ViewBuilder private func routeView(_ value: String) -> some View {
		if value.hasPrefix("start_") {
			let comps = value.split(separator: "_")
			if let last = comps.last, let day = Int(last) {
				let vm = TrainingViewModel().startWorkoutSession(template: model.template, dayIndex: day)
				WorkoutSessionView(model: vm)
			} else { Text("Template not found") }
		} else { Text(value) }
	}
}
