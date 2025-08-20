import Foundation

final class MobilityStorageService {
	private let fileManager = FileManager.default
	private let dirName = "mobility"
	private let routinesFile = "routines.json"
	private let logsFile = "mobility_logs.json"

	private var baseURL: URL {
		let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
		let dir = docs.appendingPathComponent(dirName, isDirectory: true)
		if !fileManager.fileExists(atPath: dir.path) { try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true) }
		return dir
	}
	private var routinesURL: URL { baseURL.appendingPathComponent(routinesFile) }
	private var logsURL: URL { baseURL.appendingPathComponent(logsFile) }

	func seedIfNeeded() {
		let existing = listRoutines()
		guard existing.isEmpty else { return }
		let daily = MobilityRoutine(id: UUID(), name: "Daily Flow (10m)", durationMin: 10, moves: [
			MobilityMove(id: UUID(), name: "Cat-Cow", targetArea: "Spine", holdSec: 30, reps: 10, notes: nil),
			MobilityMove(id: UUID(), name: "Hip Flexor", targetArea: "Hips", holdSec: 45, reps: nil, notes: nil),
			MobilityMove(id: UUID(), name: "Thoracic Twist", targetArea: "T-Spine", holdSec: 30, reps: 8, notes: nil),
			MobilityMove(id: UUID(), name: "Hamstring", targetArea: "Legs", holdSec: 45, reps: nil, notes: nil),
		])
		let desk = MobilityRoutine(id: UUID(), name: "Desk Break (5m)", durationMin: 5, moves: [
			MobilityMove(id: UUID(), name: "Pec Doorway", targetArea: "Chest", holdSec: 30, reps: nil, notes: nil),
			MobilityMove(id: UUID(), name: "Calf Wall", targetArea: "Calves", holdSec: 30, reps: nil, notes: nil),
			MobilityMove(id: UUID(), name: "Child’s Pose", targetArea: "Back", holdSec: 45, reps: nil, notes: nil),
		])
		saveRoutines([daily, desk])
	}

	// CRUD Routines
	func listRoutines() -> [MobilityRoutine] {
		guard fileManager.fileExists(atPath: routinesURL.path) else { return [] }
		return (try? JSONDecoder().decode([MobilityRoutine].self, from: (try? Data(contentsOf: routinesURL)) ?? Data())) ?? []
	}
	func saveRoutines(_ routines: [MobilityRoutine]) { do { try JSONEncoder().encode(routines).write(to: routinesURL, options: .atomic) } catch { DebugLog.error("Save routines failed: \(error.localizedDescription)") } }
	func addRoutine(_ r: MobilityRoutine) { var all = listRoutines(); all.append(r); saveRoutines(all) }
	func deleteRoutine(id: UUID) { var all = listRoutines(); all.removeAll { $0.id == id }; saveRoutines(all) }
	func updateRoutine(_ r: MobilityRoutine) { var all = listRoutines(); if let i = all.firstIndex(where: { $0.id == r.id }) { all[i] = r }; saveRoutines(all) }

	// Logs
	func listLogs() -> [MobilitySessionLog] { (try? JSONDecoder().decode([MobilitySessionLog].self, from: (try? Data(contentsOf: logsURL)) ?? Data())) ?? [] }
	func saveLogs(_ logs: [MobilitySessionLog]) { do { try JSONEncoder().encode(logs).write(to: logsURL, options: .atomic) } catch { DebugLog.error("Save logs failed: \(error.localizedDescription)") } }
	func addLog(_ log: MobilitySessionLog) { var all = listLogs(); all.append(log); saveLogs(all) }
}







