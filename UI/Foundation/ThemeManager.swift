
import SwiftUI
import Observation

@Observable
final class ThemeManager {
    var selectedTheme: ThemeMode = .system {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selected_theme")
            print("Theme changed to: \(selectedTheme.rawValue)")
        }
    }
    
    enum ThemeMode: String, CaseIterable {
        case light = "light"
        case dark = "dark"
        case system = "system"
        
        var displayName: String {
            switch self {
            case .light: return "Light"
            case .dark: return "Dark"
            case .system: return "System"
            }
        }
        
        var colorScheme: ColorScheme? {
            switch self {
            case .light: return .light
            case .dark: return .dark
            case .system: return nil
            }
        }
    }
    
    init() {
        if let savedTheme = UserDefaults.standard.string(forKey: "selected_theme"),
           let theme = ThemeMode(rawValue: savedTheme) {
            self.selectedTheme = theme
        }
    }
    
    func setTheme(_ theme: ThemeMode) {
        selectedTheme = theme
        print("Telemetry: theme_changed")
    }

    var beigeBackground: Color {
        switch selectedTheme {
        case .light: return Color(red: 0.96, green: 0.93, blue: 0.89) // beige
        default: return Color(.systemBackground)
        }
    }
}
