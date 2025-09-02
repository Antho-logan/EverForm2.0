import SwiftUI

// MARK: - Appearance

enum EFAppearance: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
}

final class EFThemeManager: ObservableObject {
    @AppStorage("ef.appearance") var stored: String = EFAppearance.system.rawValue
    var selection: EFAppearance {
        get { EFAppearance(rawValue: stored) ?? .system }
        set { stored = newValue.rawValue; objectWillChange.send() }
    }
    var overrideScheme: ColorScheme? {
        switch selection {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

// MARK: - Palette (kept in code to avoid asset changes)
struct EFPalette {
    // Light palette (iOS 26 Scan screen vibe)
    static let lightBackground  = Color(hex: 0xF2EBDD)   // soft beige
    static let lightSurface     = Color(hex: 0xF8F4EA)   // card
    static let lightCardStroke  = Color(hex: 0xE7E0D2)
    static let lightText        = Color(hex: 0x121212)
    static let lightMutedText   = Color(hex: 0x7A7A7A)

    // Dark palette (deep, neutral; cards slightly lifted)
    static let darkBackground   = Color(hex: 0x0B0B0C)   // near-black
    static let darkSurface      = Color(hex: 0x151516)   // card
    static let darkCardStroke   = Color(hex: 0x1F1F21)
    static let darkText         = Color.white
    static let darkMutedText    = Color.white.opacity(0.6)
}

// MARK: - Theme tokens
struct EFTheme {
    static func background(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? EFPalette.darkBackground : EFPalette.lightBackground
    }
    static func surface(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? EFPalette.darkSurface : EFPalette.lightSurface
    }
    static func cardStroke(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? EFPalette.darkCardStroke : EFPalette.lightCardStroke
    }
    static func text(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? EFPalette.darkText : EFPalette.lightText
    }
    static func muted(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? EFPalette.darkMutedText : EFPalette.lightMutedText
    }
}

// MARK: - Hex helpers
extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xff) / 255
        let g = Double((hex >>  8) & 0xff) / 255
        let b = Double((hex      ) & 0xff) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
