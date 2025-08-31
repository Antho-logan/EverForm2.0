import SwiftUI
import Observation

@Observable
final class AppMenuCoordinator {
    enum Sheet: Identifiable {
        case nutritionDiary
        case quickAddMeal
        case logMealChooser
        case sleepRoutine
        case mobilityRoutine
        case todayPlanTraining
        case workoutHistory
        case nutritionTrends
        case settings
        case editProfile

        var id: String { String(describing: self) }
    }

    // Drawer state
    var isOpen: Bool = false

    // Single global sheet
    var sheet: Sheet?

    // Tab switch hook (injected by RootTabView)
    var switchToTab: ((Tab) -> Void)?

    // Drawer controls
    func toggle() { withAnimation(.snappy) { isOpen.toggle() } }
    func open()   { withAnimation(.snappy) { isOpen = true } }
    func close()  { withAnimation(.snappy) { isOpen = false } }

    // Sheet openers
    @MainActor func openDiary()           { sheet = .nutritionDiary; close() }
    @MainActor func openQuickAddMeal()    { sheet = .quickAddMeal; close() }
    @MainActor func openLogMealChooser()  { sheet = .logMealChooser; close() }
    @MainActor func openSleepRoutine()    { sheet = .sleepRoutine; close() }
    @MainActor func openMobilityRoutine() { sheet = .mobilityRoutine; close() }
    @MainActor func openTodayPlan()       { sheet = .todayPlanTraining; close() }
    @MainActor func openWorkoutHistory()  { sheet = .workoutHistory; close() }
    @MainActor func openNutritionTrends() { sheet = .nutritionTrends; close() }
    @MainActor func openSettings()        { sheet = .settings; close() }
    @MainActor func openEditProfile()     { sheet = .editProfile; close() }

    // Tabs
    @MainActor func goCoach() { switchToTab?(.coach); close() }
    @MainActor func goScan()  { switchToTab?(.scan);  close() }
}
