
import SwiftUI
import Observation
import UIKit

// MARK: - Theme Tokens
enum ThemeMode: String, CaseIterable {
    case system, light, dark

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

@Observable
final class ThemeManager {
    private let storageKey = "appearanceMode"
    private let legacyStorageKey = "selected_theme"
    
    var selectedTheme: ThemeMode
    
    init() {
        selectedTheme = ThemeManager.loadPersistedTheme(storageKey: storageKey, legacyKey: legacyStorageKey) ?? .system
    }
    
    func setTheme(_ theme: ThemeMode) {
        withAnimation(.easeInOut(duration: 0.2)) {
            self.selectedTheme = theme
        }
        ThemeManager.persist(theme, storageKey: storageKey, legacyKey: legacyStorageKey)
        print("Telemetry: theme_changed")
    }
    
    // MARK: - Dynamic Colors
    private var palette: ThemePalette {
        switch selectedTheme {
        case .light: return .light
        case .dark: return .dark
        case .system: return .system
        }
    }
    
    var backgroundPrimary: Color { palette.backgroundPrimary }
    var backgroundSecondary: Color { palette.backgroundSecondary }
    var cardBackground: Color { palette.cardBackground }
    var cardShadow: Color { palette.cardShadow }
    var textPrimary: Color { palette.textPrimary }
    var textSecondary: Color { palette.textSecondary }
    var border: Color { palette.border }
    
    // Specific for beige background support
    var beigeBackground: Color { palette.beigeBackground }
}

// MARK: - Persistence
private extension ThemeManager {
    static func loadPersistedTheme(storageKey: String, legacyKey: String) -> ThemeMode? {
        let defaults = UserDefaults.standard
        if let stored = defaults.string(forKey: storageKey), let mode = ThemeMode(rawValue: stored) {
            return mode
        }
        if let legacy = defaults.string(forKey: legacyKey), let mode = ThemeMode(rawValue: legacy) {
            return mode
        }
        return nil
    }
    
    static func persist(_ theme: ThemeMode, storageKey: String, legacyKey: String) {
        let defaults = UserDefaults.standard
        defaults.set(theme.rawValue, forKey: storageKey)
        defaults.set(theme.rawValue, forKey: legacyKey)
    }
}

// MARK: - Palette
private struct ThemePalette {
    let backgroundPrimary: Color
    let backgroundSecondary: Color
    let cardBackground: Color
    let cardShadow: Color
    let textPrimary: Color
    let textSecondary: Color
    let border: Color
    let beigeBackground: Color
    
    static let light = ThemePalette(
        backgroundPrimary: Color(red: 0.95, green: 0.91, blue: 0.86),
        backgroundSecondary: Color(red: 0.97, green: 0.94, blue: 0.90),
        cardBackground: Color(red: 0.99, green: 0.97, blue: 0.94),
        cardShadow: Color.black.opacity(0.1),
        textPrimary: Color.black.opacity(0.9),
        textSecondary: Color.black.opacity(0.6),
        border: Color.black.opacity(0.1),
        beigeBackground: Color(red: 0.95, green: 0.91, blue: 0.86)
    )
    
    static let dark = ThemePalette(
        backgroundPrimary: Color(hex: "121212"),
        backgroundSecondary: Color(hex: "1C1C1E"),
        cardBackground: Color(hex: "2C2C2E"),
        cardShadow: Color.black.opacity(0.3),
        textPrimary: Color(hex: "F2F2F7"),
        textSecondary: Color(hex: "AEAEB2"),
        border: Color(hex: "38383A"),
        beigeBackground: Color(hex: "121212")
    )
    
    static let system = ThemePalette(
        backgroundPrimary: dynamicColor(light: ThemeColors.backgroundPrimaryLight, dark: ThemeColors.backgroundPrimaryDark),
        backgroundSecondary: dynamicColor(light: ThemeColors.backgroundSecondaryLight, dark: ThemeColors.backgroundSecondaryDark),
        cardBackground: dynamicColor(light: ThemeColors.cardBackgroundLight, dark: ThemeColors.cardBackgroundDark),
        cardShadow: dynamicShadow(light: ThemeColors.cardShadowLight, dark: ThemeColors.cardShadowDark),
        textPrimary: dynamicColor(light: ThemeColors.textPrimaryLight, dark: ThemeColors.textPrimaryDark),
        textSecondary: dynamicColor(light: ThemeColors.textSecondaryLight, dark: ThemeColors.textSecondaryDark),
        border: dynamicColor(light: ThemeColors.borderLight, dark: ThemeColors.borderDark),
        beigeBackground: dynamicColor(light: ThemeColors.backgroundPrimaryLight, dark: ThemeColors.backgroundPrimaryDark)
    )
    
    private static func dynamicColor(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { traits in
            switch traits.userInterfaceStyle {
            case .dark: return dark
            default: return light
            }
        })
    }
    
    private static func dynamicShadow(light: UIColor, dark: UIColor) -> Color {
        Color(UIColor { traits in
            switch traits.userInterfaceStyle {
            case .dark: return dark
            default: return light
            }
        })
    }
}

private enum ThemeColors {
    static let backgroundPrimaryLight = UIColor(red: 0.95, green: 0.91, blue: 0.86, alpha: 1.0)
    static let backgroundPrimaryDark = UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1.0) // Hex 121212
    
    static let backgroundSecondaryLight = UIColor(red: 0.97, green: 0.94, blue: 0.90, alpha: 1.0)
    static let backgroundSecondaryDark = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) // Hex 1C1C1E
    
    static let cardBackgroundLight = UIColor(red: 0.99, green: 0.97, blue: 0.94, alpha: 1.0)
    static let cardBackgroundDark = UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1.0) // Hex 2C2C2E
    
    static let cardShadowLight = UIColor(white: 0.0, alpha: 0.1)
    static let cardShadowDark = UIColor(white: 0.0, alpha: 0.3)
    
    static let textPrimaryLight = UIColor(white: 0.0, alpha: 0.9)
    static let textPrimaryDark = UIColor(red: 0.949, green: 0.949, blue: 0.969, alpha: 1.0) // Hex F2F2F7
    
    static let textSecondaryLight = UIColor(white: 0.0, alpha: 0.6)
    static let textSecondaryDark = UIColor(red: 0.682, green: 0.682, blue: 0.698, alpha: 1.0) // Hex AEAEB2
    
    static let borderLight = UIColor(white: 0.0, alpha: 0.1)
    static let borderDark = UIColor(red: 0.220, green: 0.220, blue: 0.227, alpha: 1.0) // Hex 38383A
}
