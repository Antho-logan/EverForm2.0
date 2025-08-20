import Foundation
import Observation

@Observable final class WorkoutSessionViewModel {
	let template: TrainingTemplate
	let dayIndex: Int
	private let storage: TrainingStorageService

	private(set) var startDate: Date = Date()
	private(set) var isRunning: Bool = true
	private(set) var elapsedSec: Int = 0
	var note: String = ""

	// Map exerciseId -> array of logs per set index
	private(set) var exerciseLogs: [UUID: [WorkoutSetLog]] = [:]

	private var timer: Timer?

	init(template: TrainingTemplate, dayIndex: Int, storage: TrainingStorageService) {
		self.template = template
		self.dayIndex = dayIndex
		self.storage = storage
		startTimer()
	}

	deinit { timer?.invalidate() }

	func startTimer() {
		isRunning = true
		timer?.invalidate()
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
			guard let self else { return }
			self.elapsedSec += 1
		}
		DebugLog.info("Session timer started")
	}

	func pauseTimer() {
		isRunning = false
		timer?.invalidate()
		DebugLog.info("Session timer paused at \(elapsedSec)s")
	}

	func toggleTimer() { isRunning ? pauseTimer() : startTimer() }

	func setDone(exercise: WorkoutExercise, setIndex: Int, reps: Int, loadKG: Double?, rpe: Double?, restUsed: Int?) {
		var arr = exerciseLogs[exercise.id] ?? []
		if arr.count <= setIndex { arr += Array(repeating: WorkoutSetLog(repsDone: 0), count: setIndex - arr.count + 1) }
		arr[setIndex] = WorkoutSetLog(repsDone: reps, loadKG: loadKG, rpe: rpe, restUsedSec: restUsed)
		exerciseLogs[exercise.id] = arr
		DebugLog.info("Set logged ex=\(exercise.displayName) idx=\(setIndex) reps=\(reps)")
	}

	func finish() {
		timer?.invalidate()
		let items = template.weekDays[dayIndex] ?? []
		let exerciseLogsOut: [WorkoutExerciseLog] = items.map { ex in
			let logs = exerciseLogs[ex.id] ?? []
			return WorkoutExerciseLog(exerciseName: ex.displayName, sets: logs)
		}
		let log = WorkoutLog(durationSec: elapsedSec, notes: note.isEmpty ? nil : note, exercises: exerciseLogsOut)
		storage.saveWorkoutLog(log)
		TelemetryService.track("training_finish", props: ["templateId": template.id.uuidString, "duration": String(elapsedSec)])
		DebugLog.info("Workout finished duration=\(elapsedSec)s noteLen=\(note.count)")
	}
}







