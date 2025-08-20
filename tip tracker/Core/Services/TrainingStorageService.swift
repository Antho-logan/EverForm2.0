import Foundation

/// Simple JSON storage for training templates and workout logs.
/// Data lives in app sandbox; suitable for offline MVP.
final class TrainingStorageService {
	private let fileManager = FileManager.default
	private let seededKey = "training.seeded"
	private let templatesFilename = "templates.json"
	private let workoutsFilename = "workouts.json"

	private var baseURL: URL {
		let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
		let dir = docs.appendingPathComponent("training", isDirectory: true)
		if !fileManager.fileExists(atPath: dir.path) {
			try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
			DebugLog.info("Created training dir at \(dir.path)")
		}
		return dir
	}

	private var templatesURL: URL { baseURL.appendingPathComponent(templatesFilename) }
	private var workoutsURL: URL { baseURL.appendingPathComponent(workoutsFilename) }

	func loadDefaultTemplatesIfNeeded() {
		let defaults = UserDefaults.standard
		guard defaults.bool(forKey: seededKey) == false || !fileManager.fileExists(atPath: templatesURL.path) else {
			return
		}
		let seed = seedTemplates()
		do {
			let data = try JSONEncoder().encode(seed)
			try data.write(to: templatesURL, options: .atomic)
			defaults.set(true, forKey: seededKey)
			DebugLog.info("Seeded default training templates: count=\(seed.count)")
		} catch {
			DebugLog.error("Failed seeding templates: \(error.localizedDescription)")
		}
	}

	func listTemplates() -> [TrainingTemplate] {
		do {
			let data = try Data(contentsOf: templatesURL)
			let decoded = try JSONDecoder().decode([TrainingTemplate].self, from: data)
			return decoded
		} catch {
			DebugLog.error("listTemplates error: \(error.localizedDescription)")
			return []
		}
	}

	func getTemplate(id: UUID) -> TrainingTemplate? {
		listTemplates().first { $0.id == id }
	}

	func saveWorkoutLog(_ log: WorkoutLog) {
		var logs = listWorkoutLogs()
		logs.insert(log, at: 0)
		do {
			let data = try JSONEncoder().encode(logs)
			try data.write(to: workoutsURL, options: .atomic)
			DebugLog.info("Saved workout log id=\(log.id) duration=\(log.durationSec)s")
		} catch {
			DebugLog.error("Failed to save workout: \(error.localizedDescription)")
		}
	}

	func listWorkoutLogs() -> [WorkoutLog] {
		guard fileManager.fileExists(atPath: workoutsURL.path) else { return [] }
		do {
			let data = try Data(contentsOf: workoutsURL)
			let decoded = try JSONDecoder().decode([WorkoutLog].self, from: data)
			return decoded
		} catch {
			DebugLog.error("listWorkoutLogs error: \(error.localizedDescription)")
			return []
		}
	}

	// MARK: - Seed
	private func seedTemplates() -> [TrainingTemplate] {
		func makeExercise(_ name: String, region: String, eq: String, reps: [Int]) -> WorkoutExercise {
			let ex = Exercise(name: name, bodyRegion: region, equipment: eq)
			let sets = reps.map { SetEntry(targetReps: $0, loadKG: nil, rpeTarget: 7.5, restSec: 120) }
			return WorkoutExercise(exerciseId: ex.id, displayName: name, sets: sets)
		}

		let days: [Int: [WorkoutExercise]] = [
			1: [makeExercise("Squat", region: "Legs", eq: "Barbell", reps: [5,5,5,5]), makeExercise("Bench Press", region: "Chest", eq: "Barbell", reps: [5,5,5,5])],
			3: [makeExercise("Deadlift", region: "Back", eq: "Barbell", reps: [5,5,5]), makeExercise("Overhead Press", region: "Shoulders", eq: "Barbell", reps: [5,5,5,5])],
			5: [makeExercise("Pull-ups", region: "Back", eq: "Bodyweight", reps: [8,8,8,8]), makeExercise("Dips", region: "Chest", eq: "Bodyweight", reps: [8,8,8,8])],
			7: [makeExercise("Rows", region: "Back", eq: "Dumbbell", reps: [10,10,10,10]), makeExercise("Lunges", region: "Legs", eq: "Dumbbell", reps: [10,10,10,10])]
		]

		let power = TrainingTemplate(title: "Power Base 4d", focus: .powerlifting, weekDays: days)
		let body = TrainingTemplate(title: "Body Recomp 4d", focus: .bodybuilding, weekDays: days)
		let cali = TrainingTemplate(title: "Cali Skills 4d", focus: .calisthenics, weekDays: days)
		let hybrid = TrainingTemplate(title: "Hybrid Starter 4d", focus: .hybrid, weekDays: days)
		return [power, body, cali, hybrid]
	}
}







