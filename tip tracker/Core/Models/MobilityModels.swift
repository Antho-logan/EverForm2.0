import Foundation

public struct MobilityMove: Codable, Identifiable, Hashable {
	public let id: UUID
	public var name: String
	public var targetArea: String
	public var holdSec: Int
	public var reps: Int?
	public var notes: String?
}

public struct MobilityRoutine: Codable, Identifiable, Hashable {
	public let id: UUID
	public var name: String
	public var durationMin: Int
	public var moves: [MobilityMove]
}

public struct MobilitySessionLog: Codable, Identifiable, Hashable {
	public let id: UUID
	public var date: Date
	public var routineId: UUID
	public var durationMin: Int
	public var notes: String?
}







