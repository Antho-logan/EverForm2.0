import Foundation
import Observation

@Observable final class TrainingViewModel {
	var selectedFocus: TrainingFocus = .hybrid
	private let storage = TrainingStorageService()
	private(set) var templates: [TrainingTemplate] = []

	func load() {
		DebugLog.info("TrainingVM load")
		storage.loadDefaultTemplatesIfNeeded()
		templates = storage.listTemplates()
	}

	var filteredTemplates: [TrainingTemplate] {
		templates.filter { $0.focus == selectedFocus }
	}

	func selectFocus(_ focus: TrainingFocus) {
		selectedFocus = focus
		TelemetryService.track("training_focus_change", props: ["focus": focus.rawValue])
	}

	func startWorkoutSession(template: TrainingTemplate, dayIndex: Int) -> WorkoutSessionViewModel {
		TelemetryService.track("training_start_tap", props: ["templateId": template.id.uuidString, "day": String(dayIndex)])
		return WorkoutSessionViewModel(template: template, dayIndex: dayIndex, storage: storage)
	}

	func historyViewModel() -> TrainingHistoryViewModel { TrainingHistoryViewModel(storage: storage) }
}







