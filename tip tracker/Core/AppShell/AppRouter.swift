import SwiftUI
import Observation

@Observable
final class AppRouter {
    enum Tab: Hashable { case overview, coach, scan, more }
    enum FullScreen: Identifiable, Hashable {
        case logMeal, startWorkout, mobility, sleep, nutritionTrends, workoutHistory, settings
        case expressOnboarding, advancedProfile, editProfile, profile
        var id: String { String(describing: self) }
    }

    var selectedTab: Tab = .overview
    var isSideMenuOpen: Bool = false {
        didSet {
            print("📱 AppRouter: Side menu \(isSideMenuOpen ? "opened" : "closed")")
        }
    }
    var fullScreen: FullScreen? = nil

    func go(_ tab: Tab) { 
        print("🔄 AppRouter: Navigating to tab \(tab)")
        selectedTab = tab; isSideMenuOpen = false 
    }
    func open(_ screen: FullScreen) { 
        print("🚀 AppRouter: Opening full screen \(screen)")
        fullScreen = screen; isSideMenuOpen = false 
    }
    func closeFullScreen() { 
        print("❌ AppRouter: Closing full screen")
        fullScreen = nil 
    }
}