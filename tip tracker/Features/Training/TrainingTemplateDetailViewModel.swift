import Foundation
import Observation

@Observable final class TrainingTemplateDetailViewModel {
	let template: TrainingTemplate
	init(template: TrainingTemplate) { self.template = template }

	var sortedDays: [Int] { template.weekDays.keys.sorted() }
}







