import Foundation

public enum TrainingFocus: String, Codable, CaseIterable, Identifiable {
	case powerlifting = "Powerlifting"
	case bodybuilding = "Bodybuilding"
	case calisthenics = "Calisthenics"
	case hybrid = "Hybrid"
	public var id: String { rawValue }
}

public struct Exercise: Codable, Identifiable, Hashable {
	public let id: UUID
	public var name: String
	public var bodyRegion: String
	public var equipment: String
	public var notes: String?
	public init(id: UUID = UUID(), name: String, bodyRegion: String, equipment: String, notes: String? = nil) {
		self.id = id
		self.name = name
		self.bodyRegion = bodyRegion
		self.equipment = equipment
		self.notes = notes
	}
}

public struct SetEntry: Codable, Identifiable, Hashable {
	public let id: UUID
	public var targetReps: Int
	public var loadKG: Double?
	public var rpeTarget: Double?
	public var restSec: Int?
	public init(id: UUID = UUID(), targetReps: Int, loadKG: Double? = nil, rpeTarget: Double? = nil, restSec: Int? = nil) {
		self.id = id
		self.targetReps = targetReps
		self.loadKG = loadKG
		self.rpeTarget = rpeTarget
		self.restSec = restSec
	}
}

public struct WorkoutExercise: Codable, Identifiable, Hashable {
	public let id: UUID
	public var exerciseId: UUID
	public var displayName: String
	public var sets: [SetEntry]
	public init(id: UUID = UUID(), exerciseId: UUID, displayName: String, sets: [SetEntry]) {
		self.id = id
		self.exerciseId = exerciseId
		self.displayName = displayName
		self.sets = sets
	}
}

public struct TrainingTemplate: Codable, Identifiable, Hashable {
	public let id: UUID
	public var title: String
	public var focus: TrainingFocus
	/// Map of weekday (1=Mon ... 7=Sun) to list of exercises
	public var weekDays: [Int: [WorkoutExercise]]
	public init(id: UUID = UUID(), title: String, focus: TrainingFocus, weekDays: [Int: [WorkoutExercise]]) {
		self.id = id
		self.title = title
		self.focus = focus
		self.weekDays = weekDays
	}
}

public struct WorkoutSetLog: Codable, Identifiable, Hashable {
	public let id: UUID
	public var repsDone: Int
	public var loadKG: Double?
	public var rpe: Double?
	public var restUsedSec: Int?
	public var timestamp: Date
	public init(id: UUID = UUID(), repsDone: Int, loadKG: Double? = nil, rpe: Double? = nil, restUsedSec: Int? = nil, timestamp: Date = Date()) {
		self.id = id
		self.repsDone = repsDone
		self.loadKG = loadKG
		self.rpe = rpe
		self.restUsedSec = restUsedSec
		self.timestamp = timestamp
	}
}

public struct WorkoutExerciseLog: Codable, Identifiable, Hashable {
	public let id: UUID
	public var exerciseName: String
	public var sets: [WorkoutSetLog]
	public init(id: UUID = UUID(), exerciseName: String, sets: [WorkoutSetLog]) {
		self.id = id
		self.exerciseName = exerciseName
		self.sets = sets
	}
}

public struct WorkoutLog: Codable, Identifiable, Hashable {
	public let id: UUID
	public var date: Date
	public var templateId: UUID?
	public var durationSec: Int
	public var notes: String?
	public var exercises: [WorkoutExerciseLog]
	public init(id: UUID = UUID(), date: Date = Date(), templateId: UUID? = nil, durationSec: Int, notes: String? = nil, exercises: [WorkoutExerciseLog]) {
		self.id = id
		self.date = date
		self.templateId = templateId
		self.durationSec = durationSec
		self.notes = notes
		self.exercises = exercises
	}
}







