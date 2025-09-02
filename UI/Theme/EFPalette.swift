import SwiftUI

/// Semantic color tokens we'll use everywhere.
public struct EFPalette {
    public let background: Color      // level 0 (page)
    public let surface: Color         // level 1 (sections)
    public let card: Color            // level 2 (cards/tiles)
    public let chrome: Color          // nav/tab "bubble", tool surfaces
    public let stroke: Color          // subtle borders on light
    public let shadow: Color          // unified shadow color

    public static func current(_ scheme: ColorScheme) -> EFPalette {
        if scheme == .light {
            // Warm light (from Scan Food iOS 26 look)
            // Tones are intentionally subtle & warm (sand/ivory).
            return EFPalette(
                background: Color(hex: 0xF3E8DB), // page
                surface:    Color(hex: 0xF6EFE7), // section blocks
                card:       Color(hex: 0xFBF7F2), // floating cards/tiles
                chrome:     Color(hex: 0xEFE4D8), // tab "bubble", toolbars
                stroke:     Color(hex: 0xE6D8C8),
                shadow:     Color.black.opacity(0.08)
            )
        } else {
            // Preserve existing dark look by mapping to system/dark neutrals.
            return EFPalette(
                background: Color(.black),
                surface:    Color(red: 0.09, green: 0.09, blue: 0.10),
                card:       Color(red: 0.13, green: 0.13, blue: 0.14),
                chrome:     Color(red: 0.10, green: 0.10, blue: 0.11),
                stroke:     Color.white.opacity(0.06),
                shadow:     Color.black.opacity(0.40)
            )
        }
    }
}

// MARK: - Helpers
// Note: Using existing Color.init(hex:), EFCardStyle, and efCard() from the project
