import SwiftUI

enum Theme {
    enum Mode: String, CaseIterable {
        case system = "system"
        case light = "light" 
        case dark = "dark"
        
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
    
    enum Layout {
        static let hPadding: CGFloat = 16
        static let vSpacing: CGFloat = 16
        static let gridSpacing: CGFloat = 12
        static let kpiTileHeight: CGFloat = 84
        static let planCardHeight: CGFloat = 144
        static let quickCardHeight: CGFloat = 92
        static let ringSize: CGFloat = 108
        
        // Section spacing
        static let headerToKPI: CGFloat = 12
        static let kpiToPlan: CGFloat = 16
        static let planToQuick: CGFloat = 16
        static let sectionTitleSpacing: CGFloat = 8
        static let ringToGrid: CGFloat = 16
    }
    
    enum Spacing { static let xs: CGFloat = 8; static let sm: CGFloat = 12
        static let md: CGFloat = 16; static let lg: CGFloat = 20; static let xl: CGFloat = 24 }
    enum Radius { static let card: CGFloat = 16; static let pill: CGFloat = 12 }
    enum Shadow { static let card = Color.black.opacity(0.30) }

    struct Palette {
        let background: Color
        let surface: Color
        let surfaceElevated: Color
        let textPrimary: Color
        let textSecondary: Color
        let accent: Color
        let stroke: Color

        // Light = warm beige
        static let light = Palette(
            background: Color(hex: "F2E9DE"),
            surface: Color(hex: "F7F0E7"),
            surfaceElevated: Color.white,
            textPrimary: Color.black.opacity(0.9),
            textSecondary: Color.black.opacity(0.65),
            accent: Color(red: 0.20, green: 0.70, blue: 0.35),
            stroke: Color.black.opacity(0.12)
        )

        // Dark = existing minimal
        static let dark = Palette(
            background: Color(red: 0.08, green: 0.09, blue: 0.09),
            surface: Color(red: 0.12, green: 0.13, blue: 0.13),
            surfaceElevated: Color(red: 0.16, green: 0.17, blue: 0.18),
            textPrimary: .white,
            textSecondary: .white.opacity(0.75),
            accent: Color(red: 0.47, green: 0.90, blue: 0.38),
            stroke: .white.opacity(0.10)
        )
    }

    @AppStorage("themeMode") private static var storedMode: String = Mode.system.rawValue
    
    static var currentMode: Mode {
        Mode(rawValue: storedMode) ?? .system
    }
    
    static func palette(_ cs: ColorScheme) -> Palette {
        switch currentMode {
        case .system: return cs == .dark ? .dark : .light
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    static func color(_ token: ColorToken, scheme: ColorScheme) -> Color {
        let palette = palette(scheme)
        switch token {
        case .background: return palette.background
        case .surface: return palette.surface
        case .surfaceElevated: return palette.surfaceElevated
        case .textPrimary: return palette.textPrimary
        case .textSecondary: return palette.textSecondary
        case .accent: return palette.accent
        case .stroke: return palette.stroke
        }
    }
    
    enum ColorToken {
        case background, surface, surfaceElevated, textPrimary, textSecondary, accent, stroke
    }
}

extension View {
    func efCardStyle(scheme: ColorScheme) -> some View {
        let p = Theme.palette(scheme)
        return self
            .background(p.surface)
            .overlay(RoundedRectangle(cornerRadius: Theme.Radius.card).stroke(p.stroke, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            .shadow(color: scheme == .dark ? Theme.Shadow.card : .black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}