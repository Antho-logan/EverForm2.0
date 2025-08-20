import SwiftUI

struct WorkoutSessionView: View {
	@State private var model: WorkoutSessionViewModel
	@Environment(\.dismiss) private var dismiss

	init(model: WorkoutSessionViewModel) { _model = State(initialValue: model) }

	var body: some View {
		VStack(spacing: 12) {
			header
			ScrollView {
				LazyVStack(spacing: 12) {
					ForEach(model.template.weekDays[model.dayIndex] ?? []) { ex in
						exerciseSection(ex)
					}
				}
			}
			HStack {
				TextField("Notes", text: $model.note, axis: .vertical)
					.textFieldStyle(.roundedBorder)
			}
			.padding(.horizontal)
			Button("Finish Workout") { onFinish() }
				.buttonStyle(.borderedProminent)
				.accessibilityLabel("finish_workout_button")
		}
		.padding(.vertical)
		.navigationTitle("Session")
		.onAppear { DebugLog.info("WorkoutSessionView onAppear day=\(model.dayIndex)") }
	}

	private var header: some View {
		HStack {
			Text("\(model.template.title) — Day \(model.dayIndex)")
				.font(.headline)
			Spacer()
			Text(model.isRunning ? "Running" : "Paused")
			Button(action: { model.toggleTimer() }) { Text(model.isRunning ? "Pause" : "Resume") }
			Text(timeString(model.elapsedSec)).monospacedDigit()
		}
		.padding(.horizontal)
	}

	@ViewBuilder private func exerciseSection(_ ex: WorkoutExercise) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(ex.displayName).bold()
			ForEach(Array(ex.sets.enumerated()), id: \.offset) { index, s in
				SetInputRow(exercise: ex, setIndex: index, target: s, onDone: { reps, load, rpe in
					model.setDone(exercise: ex, setIndex: index, reps: reps, loadKG: load, rpe: rpe, restUsed: s.restSec)
				})
			}
		}
		.padding()
		.background(RoundedRectangle(cornerRadius: 10).fill(Theme.accent.opacity(0.06)))
		.padding(.horizontal)
	}

	private func onFinish() {
		model.finish()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { dismiss() }
	}

	private func timeString(_ seconds: Int) -> String {
		let m = seconds / 60, s = seconds % 60
		return String(format: "%02d:%02d", m, s)
	}
}

private struct SetInputRow: View {
	let exercise: WorkoutExercise
	let setIndex: Int
	let target: SetEntry
	var onDone: (Int, Double?, Double?) -> Void
	@State private var reps: String = ""
	@State private var load: String = ""
	@State private var rpe: String = ""

	var body: some View {
		HStack {
			Text("Set \(setIndex+1)").frame(width: 60, alignment: .leading)
			TextField("Reps", text: $reps).keyboardType(.numberPad)
			TextField("Load (kg)", text: $load).keyboardType(.decimalPad)
			TextField("RPE", text: $rpe).keyboardType(.decimalPad)
			Button("Done") { submit() }
		}
	}

	private func submit() {
		let repsInt = Int(reps) ?? 0
		let loadD = Double(load)
		let rpeD = Double(rpe)
		onDone(repsInt, loadD, rpeD)
	}
}







