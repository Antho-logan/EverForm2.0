import Foundation

final class RecoveryStorageService {
	private let fileManager = FileManager.default
	private let dirName = "recovery"
	private let readinessFile = "readiness.json"
	private let morningLogFile = "morning.json"
	private let winddownLogFile = "winddown.json"
	private let baselineRHRKey = "readiness.baseline.rhr"
	private let baselineHRVKey = "readiness.baseline.hrv"

	private var baseURL: URL {
		let docs = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
		let dir = docs.appendingPathComponent(dirName, isDirectory: true)
		if !fileManager.fileExists(atPath: dir.path) { try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true) }
		return dir
	}
	private var readinessURL: URL { baseURL.appendingPathComponent(readinessFile) }
	private var morningURL: URL { baseURL.appendingPathComponent(morningLogFile) }
	private var winddownURL: URL { baseURL.appendingPathComponent(winddownLogFile) }

	// Seeds
	func defaultBreathing() -> [BreathingPattern] {
		[
			BreathingPattern(name: "Box 4-4-4-4", inhale: 4, hold: 4, exhale: 4, hold2: 4, cycles: 8),
			BreathingPattern(name: "4-7-8", inhale: 4, hold: 7, exhale: 8, hold2: 0, cycles: 6),
			BreathingPattern(name: "Coherent 5-5", inhale: 5, hold: 0, exhale: 5, hold2: 0, cycles: 10),
		]
	}
	func defaultWindDowns() -> [WindDownProtocol] {
		func steps(_ total: Int) -> [WindDownStep] {
			[
				WindDownStep(title: "Dim lights", minutes: min(10, total/3)),
				WindDownStep(title: "Screens off", minutes: min(10, total/3)),
				WindDownStep(title: "Hot shower", minutes: 10),
				WindDownStep(title: "Stretch", minutes: min(10, total/3)),
				WindDownStep(title: "Breathing", minutes: max(5, total - 30)),
			]
		}
		return [30,60,90].map { d in WindDownProtocol(id: UUID(), name: "Wind-Down \(d)m", durationMin: d, steps: steps(d)) }
	}
	func defaultMorning() -> MorningRoutine {
		MorningRoutine(id: UUID(), name: "Sunlight 10–15m", sunlightMin: 15, caffeineDelayMin: 60)
	}

	// Persistence: readiness entries
	func listReadiness() -> [ReadinessEntry] {
		guard fileManager.fileExists(atPath: readinessURL.path) else { return [] }
		do { return try JSONDecoder().decode([ReadinessEntry].self, from: Data(contentsOf: readinessURL)) } catch { return [] }
	}
	func saveReadiness(_ entries: [ReadinessEntry]) {
		do { try JSONEncoder().encode(entries).write(to: readinessURL, options: .atomic) } catch { DebugLog.error("Save readiness failed: \(error.localizedDescription)") }
	}
	func addReadiness(_ entry: ReadinessEntry) { var all = listReadiness(); all.append(entry); saveReadiness(all) }

	func logMorningCompletion(date: Date = Date()) { append(date, to: morningURL) }
	func logWinddownCompletion(date: Date = Date()) { append(date, to: winddownURL) }
	private func append(_ date: Date, to url: URL) {
		var dates = (try? JSONDecoder().decode([Date].self, from: (try? Data(contentsOf: url)) ?? Data())) ?? []
		dates.append(date)
		do { try JSONEncoder().encode(dates).write(to: url, options: .atomic) } catch { DebugLog.error("Save log failed: \(error.localizedDescription)") }
	}
	func listMorningCompletions() -> [Date] { (try? JSONDecoder().decode([Date].self, from: (try? Data(contentsOf: morningURL)) ?? Data())) ?? [] }
	func listWinddownCompletions() -> [Date] { (try? JSONDecoder().decode([Date].self, from: (try? Data(contentsOf: winddownURL)) ?? Data())) ?? [] }

	// Sleep summaries (manual approximation using readiness entries sleepHours)
	func latestSleepSummary() -> (hours: Double, date: Date)? {
		listReadiness().sorted { $0.date > $1.date }.first.map { ($0.sleepHours, $0.date) }
	}
	func sevenDayAverages() -> Double {
		let end = Calendar.current.startOfDay(for: Date())
		let start = Calendar.current.date(byAdding: .day, value: -6, to: end) ?? end
		let entries = listReadiness().filter { $0.date >= start && $0.date <= end }
		let avg = entries.isEmpty ? 0 : entries.map { $0.sleepHours }.reduce(0, +) / Double(entries.count)
		return avg
	}
	func sleepDebt(weeklyTargetHours: Double = 56) -> Double {
		let end = Calendar.current.startOfDay(for: Date())
		let start = Calendar.current.date(byAdding: .day, value: -6, to: end) ?? end
		let sum = listReadiness().filter { $0.date >= start && $0.date <= end }.map { $0.sleepHours }.reduce(0, +)
		return max(0, weeklyTargetHours - sum)
	}

	// Baselines and readiness
	func setBaselines(rhr: Int, hrv: Int) {
		UserDefaults.standard.set(rhr, forKey: baselineRHRKey)
		UserDefaults.standard.set(hrv, forKey: baselineHRVKey)
	}
	func getBaselines() -> (rhr: Int, hrv: Int) {
		let r = UserDefaults.standard.integer(forKey: baselineRHRKey); let h = UserDefaults.standard.integer(forKey: baselineHRVKey)
		return (r == 0 ? 60 : r, h == 0 ? 60 : h)
	}
	func computeReadiness(from entry: ReadinessEntry) -> ReadinessScore {
		let base = getBaselines()
		var score = 80
		score -= Int(Double(entry.rhr - base.rhr) * 1.5)
		score += Int(Double(entry.hrv - base.hrv) * 0.6)
		score += Int((entry.sleepHours - 7.0) * 4.0)
		score = max(0, min(100, score))
		let advice: String = score >= 80 ? "Train" : (score >= 60 ? "Maintain" : "Deload")
		return ReadinessScore(date: entry.date, score: score, advice: advice)
	}
}
