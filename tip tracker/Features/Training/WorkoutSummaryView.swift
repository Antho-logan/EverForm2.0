import SwiftUI

struct WorkoutSummaryView: View {
	let log: WorkoutLog
	var body: some View {
		List {
			Section {
				HStack { Text("Date"); Spacer(); Text(log.date.formatted(date: .abbreviated, time: .shortened)) }
				HStack { Text("Duration"); Spacer(); Text(timeString(log.durationSec)) }
				if let notes = log.notes { Text(notes) }
			}
			ForEach(log.exercises, id: \.id) { ex in
				Section(header: Text(ex.exerciseName)) {
					ForEach(ex.sets, id: \.id) { s in
						row(for: s)
					}
				}
			}
		}
		.navigationTitle("Workout Summary")
	}

	private func row(for s: WorkoutSetLog) -> some View {
		HStack {
			Text("Reps: \(s.repsDone)")
			Spacer()
			if let kg = s.loadKG { Text("Load: \(Int(kg))kg") }
			if let r = s.rpe { Text("RPE: \(stringRPE(r))") }
		}
	}

	private func stringRPE(_ r: Double) -> String { String(format: "%.1f", r) }
	private func timeString(_ seconds: Int) -> String { String(format: "%dm %ds", seconds/60, seconds%60) }
}
