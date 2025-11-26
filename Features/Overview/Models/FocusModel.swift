
import Foundation

enum FocusTimeframe: String, CaseIterable, Identifiable {
    case today = "Today"
    case week = "Week"
    case month = "Month"
    
    var id: String { rawValue }
    
    var label: String { rawValue }
}

struct FocusItem: Identifiable {
    let id = UUID()
    let iconName: String
    let title: String
    let detail: String
    let isCompleted: Bool
    
    static let mockToday: [FocusItem] = [
        FocusItem(iconName: "drop.fill", title: "Hydration", detail: "Drink 2.5L of water", isCompleted: false),
        FocusItem(iconName: "figure.run", title: "Mobility", detail: "15 min hip opener", isCompleted: true),
        FocusItem(iconName: "fork.knife", title: "Protein", detail: "Hit 160g protein goal", isCompleted: false)
    ]
    
    static let mockWeek: [FocusItem] = [
        FocusItem(iconName: "dumbbell.fill", title: "Strength", detail: "3 Upper Body Sessions", isCompleted: false),
        FocusItem(iconName: "bed.double.fill", title: "Sleep", detail: "Avg 7.5h sleep/night", isCompleted: false),
        FocusItem(iconName: "figure.walk", title: "Recovery", detail: "1 Active Recovery Day", isCompleted: true)
    ]
    
    static let mockMonth: [FocusItem] = [
        FocusItem(iconName: "calendar.badge.clock", title: "Consistency", detail: "20 workouts total", isCompleted: false),
        FocusItem(iconName: "scalemass.fill", title: "Weight", detail: "Maintain 75kg", isCompleted: true)
    ]
}
