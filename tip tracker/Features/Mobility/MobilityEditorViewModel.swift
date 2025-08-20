import Foundation
import Observation

@Observable final class MobilityEditorViewModel {
	private let storage = MobilityStorageService()
	var name: String = "My Routine"
	var moves: [MobilityMove] = []

	let library: [MobilityMove] = [
		MobilityMove(id: UUID(), name: "Hip Flexor", targetArea: "Hips", holdSec: 45, reps: nil, notes: nil),
		MobilityMove(id: UUID(), name: "Thoracic Twist", targetArea: "T-Spine", holdSec: 30, reps: 8, notes: nil),
		MobilityMove(id: UUID(), name: "Hamstring", targetArea: "Legs", holdSec: 45, reps: nil, notes: nil),
		MobilityMove(id: UUID(), name: "Calf Wall", targetArea: "Calves", holdSec: 30, reps: nil, notes: nil),
		MobilityMove(id: UUID(), name: "Pec Doorway", targetArea: "Chest", holdSec: 30, reps: nil, notes: nil),
		MobilityMove(id: UUID(), name: "Child’s Pose", targetArea: "Back", holdSec: 45, reps: nil, notes: nil),
		MobilityMove(id: UUID(), name: "Cat-Cow", targetArea: "Spine", holdSec: 30, reps: 10, notes: nil),
	]

	func addMove(_ m: MobilityMove) { moves.append(m) }
	func removeMove(at offsets: IndexSet) { moves.remove(atOffsets: offsets) }
	func save() {
		let total = moves.reduce(0) { $0 + Int(($1.holdSec + (($1.reps ?? 0) * 2)) / 60) }
		let routine = MobilityRoutine(id: UUID(), name: name, durationMin: max(1, total), moves: moves)
		storage.addRoutine(routine)
	}
}







