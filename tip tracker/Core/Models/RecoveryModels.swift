import Foundation

public struct BreathingPattern: Codable, Identifiable, Hashable {
	public let id: UUID
	public var name: String
	public var inhale: Int
	public var hold: Int
	public var exhale: Int
	public var hold2: Int
	public var cycles: Int
	public init(id: UUID = UUID(), name: String, inhale: Int, hold: Int, exhale: Int, hold2: Int, cycles: Int) {
		self.id = id; self.name = name; self.inhale = inhale; self.hold = hold; self.exhale = exhale; self.hold2 = hold2; self.cycles = cycles
	}
}

public struct WindDownStep: Codable, Identifiable, Hashable {
	public let id: UUID
	public var title: String
	public var minutes: Int
	public var notes: String?
	public init(id: UUID = UUID(), title: String, minutes: Int, notes: String? = nil) {
		self.id = id; self.title = title; self.minutes = minutes; self.notes = notes
	}
}

public struct WindDownProtocol: Codable, Identifiable, Hashable {
	public let id: UUID
	public var name: String
	public var durationMin: Int
	public var steps: [WindDownStep]
}

public struct MorningRoutine: Codable, Identifiable, Hashable {
	public let id: UUID
	public var name: String
	public var sunlightMin: Int
	public var caffeineDelayMin: Int
}

public struct ReadinessEntry: Codable, Identifiable, Hashable {
	public let id: UUID
	public var date: Date
	public var rhr: Int
	public var hrv: Int
	public var sleepHours: Double
	public init(id: UUID = UUID(), date: Date, rhr: Int, hrv: Int, sleepHours: Double) {
		self.id = id; self.date = date; self.rhr = rhr; self.hrv = hrv; self.sleepHours = sleepHours
	}
}

public struct ReadinessScore: Codable, Identifiable, Hashable {
	public let id: UUID
	public var date: Date
	public var score: Int
	public var advice: String
	public init(id: UUID = UUID(), date: Date, score: Int, advice: String) {
		self.id = id; self.date = date; self.score = score; self.advice = advice
	}
}







