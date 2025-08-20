import SwiftUI

struct TrainingHistoryView: View {
	let model: TrainingHistoryViewModel
	@State private var selected: WorkoutLog? = nil
	@State private var route: String? = nil

	var body: some View {
		List(model.logs) { log in
			Button(action: { selected = log; route = "summary" }) {
				HStack {
					Text(log.date.formatted(date: .abbreviated, time: .shortened))
					Spacer()
					Text("\(log.durationSec/60)m")
				}
			}
		}
		.navigationTitle("History")
		.onAppear { model.load() }
		.navigationDestination(item: $route) { value in
			if value == "summary", let log = selected {
				WorkoutSummaryView(log: log)
			} else { Text(value) }
		}
	}
}







