import Foundation

// MARK: - Coach Topic
enum CoachTopic: String, CaseIterable {
    case training = "training"
    case nutrition = "nutrition"
    case sleep = "sleep"
    case mobility = "mobility"
    case supplements = "supplements"
    case progress = "progress"
    case general = "general"
    
    var displayName: String {
        switch self {
        case .training: return "Training"
        case .nutrition: return "Nutrition"
        case .sleep: return "Sleep"
        case .mobility: return "Mobility"
        case .supplements: return "Supplements"
        case .progress: return "Progress"
        case .general: return "General"
        }
    }
}





