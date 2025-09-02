import SwiftUI
import UIKit

// MARK: - Simple Theme Enum
public enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark
    public var id: String { rawValue }
}

// MARK: - Theme Palette
public struct ThemePalette {
    // Beige light background (matches your screenshots)
    public let appBackground: Color
    public let cardBackground: Color
    public let textPrimary: Color
    public let textSecondary: Color

    public static let light = ThemePalette(
        appBackground: Color(red: 0.96, green: 0.93, blue: 0.89), // beige
        cardBackground: Color.white.opacity(0.96),
        textPrimary: Color.black,
        textSecondary: Color.black.opacity(0.6)
    )

    public static let dark = ThemePalette(
        appBackground: Color(red: 0.07, green: 0.08, blue: 0.09), // near-black
        cardBackground: Color(red: 0.13, green: 0.14, blue: 0.15), // dark card
        textPrimary: Color.white,
        textSecondary: Color.white.opacity(0.7)
    )
}

// MARK: - Manager (Observable + Persistence)
public final class ThemeManager: ObservableObject {
    private let key = "app.theme.preference"
    @Published public var selection: AppTheme {
        didSet { UserDefaults.standard.set(selection.rawValue, forKey: key) }
    }

    public init() {
        if let raw = UserDefaults.standard.string(forKey: key),
           let t = AppTheme(rawValue: raw) {
            self.selection = t
        } else {
            self.selection = .system
        }
    }

    public var palette: ThemePalette {
        switch resolvedColorScheme {
        case .light: return .light
        case .dark:  return .dark
        @unknown default: return .dark
        }
    }

    // SwiftUI colorScheme to apply at the root
    public var preferredColorScheme: ColorScheme? {
        switch selection {
        case .system: return nil        // follow system
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    // If following system, infer using UITraitCollection; else fixed
    private var resolvedColorScheme: UIUserInterfaceStyle {
        switch selection {
        case .system:
            return UITraitCollection.current.userInterfaceStyle
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

// MARK: - Optional Theme Palette Environment Helper
private struct ThemePaletteKey: EnvironmentKey { 
    static let defaultValue: ThemePalette? = nil 
}

extension EnvironmentValues { 
    var themePalette: ThemePalette? {
        get { self[ThemePaletteKey.self] }
        set { self[ThemePaletteKey.self] = newValue }
    } 
}

extension View {
    func provideThemePalette(_ palette: ThemePalette) -> some View {
        environment(\.themePalette, palette)
    }
}
