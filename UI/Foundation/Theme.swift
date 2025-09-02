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

    // MARK: - EF Theme (for surgical theme patch)
    enum EFTheme: String, CaseIterable, Identifiable {
        case system, light, dark
        var id: String { rawValue }
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
    enum Radius { static let card: CGFloat = 18; static let pill: CGFloat = 12 }
    enum Shadow { static let card = Color.black.opacity(0.30) }

    // MARK: - Action Colors
    enum Colors {
        static let background      = Color(hex: 0x0B0B0D)
        static let surface         = Color(hex: 0x141416)
        static let surfaceElevated = Color(hex: 0x181A1D)
        static let border          = Color.white.opacity(0.06)
        static let textPrimary     = Color.white
        static let textSecondary   = Color.white.opacity(0.7)
        static let accent          = Color(hex: 0x2ECC71)

        // Action tints
        static let blue    = Color(hex: 0x3BA0FF)
        static let teal    = Color(hex: 0x1FB7A5)
        static let red     = Color(hex: 0xE05252)
        static let indigo  = Color(hex: 0x5B6CFF)
        static let orange  = Color(hex: 0xFFA43B)
        static let purple  = Color(hex: 0xA56BFF)
        static let blueSoft = Color(hex: 0x3BA0FF).opacity(0.18)
        static let tealSoft = Color(hex: 0x1FB7A5).opacity(0.18)
        static let redSoft  = Color(hex: 0xE05252).opacity(0.18)
        static let indigoSoft = Color(hex: 0x5B6CFF).opacity(0.18)

        // MARK: - EF Dynamic Colors (for surgical theme patch)
        static let efBackground = Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.06, green: 0.06, blue: 0.08, alpha: 1.0)   // #0F1014
            : UIColor(red: 0.96, green: 0.93, blue: 0.88, alpha: 1.0)   // warm beige
        })
        static let efSurface = Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.09, green: 0.09, blue: 0.11, alpha: 1.0)   // #181A1E
            : UIColor(red: 0.97, green: 0.95, blue: 0.91, alpha: 1.0)   // light beige
        })
        static let efCard = Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.11, green: 0.11, blue: 0.14, alpha: 1.0)   // #1D1F24
            : UIColor(red: 0.98, green: 0.96, blue: 0.93, alpha: 1.0)
        })
        static let efText = Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? .white : .black
        })
        static let efTextMuted = Color(UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor(white: 0.75, alpha: 1.0)
            : UIColor(white: 0.25, alpha: 1.0)
        })
    }

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
            stroke: Color.black.opacity(0.08)
        )

        // Dark = match Scan Food styling
        static let dark = Palette(
            background: Color(hex: 0x0B0B0D),
            surface: Color(hex: 0x141416),
            surfaceElevated: Color(hex: 0x181A1D),
            textPrimary: .white,
            textSecondary: .white.opacity(0.7),
            accent: Color(hex: 0x2ECC71),
            stroke: .white.opacity(0.06)
        )
    }

    // MARK: - Semantic Colors

    struct Semantic {
        let success: Color
        let info: Color
        let danger: Color
        let water: Color

        static let light = Semantic(
            success: Color(red: 0.20, green: 0.70, blue: 0.35), // accentGreen
            info: Color(red: 0.20, green: 0.50, blue: 0.90),    // accentBlue
            danger: Color(red: 0.90, green: 0.30, blue: 0.30),  // accentRed
            water: Color(red: 0.20, green: 0.80, blue: 0.80)    // accentAqua
        )

        static let dark = Semantic(
            success: Color(red: 0.47, green: 0.90, blue: 0.38), // accentGreen
            info: Color(red: 0.40, green: 0.70, blue: 1.0),     // accentBlue
            danger: Color(red: 1.0, green: 0.50, blue: 0.50),   // accentRed
            water: Color(red: 0.40, green: 0.90, blue: 0.90)    // accentAqua
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

    static func semantic(_ cs: ColorScheme) -> Semantic {
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

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8)  & 0xFF) / 255.0,
            blue:  Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
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

public enum PlanAccent {
    public static let training  = Color.green   // #32D74B
    public static let nutrition = Color.orange  // #FF9F0A
    public static let recovery  = Color.blue    // #0A84FF
    public static let mobility  = Color.purple  // #BF5AF2
}

// MARK: - EF Theme Manager (for surgical theme patch)
import Combine

// MARK: - Global Theme (Light/Dark) and Colors used app-wide

public final class EFThemeOld: ObservableObject {
    // "system" | "light" | "dark"
    @AppStorage("ef.color.mode") public var storedMode: String = "system" {
        didSet { objectWillChange.send() }
    }
    public var colorSchemeOverride: ColorScheme? {
        switch storedMode {
        case "light": return .light
        case "dark":  return .dark
        default:      return nil
        }
    }
}

public enum EFColor {
    // Dark mode palette
    static let bgDark         = Color(red: 0.07, green: 0.08, blue: 0.10)   // #121419
    static let surfaceDark    = Color(red: 0.12, green: 0.12, blue: 0.14)   // #1F2024
    static let cardDark       = Color(red: 0.15, green: 0.15, blue: 0.17)
    static let textDark       = Color.white.opacity(0.92)
    static let subTextDark    = Color.white.opacity(0.65)
    static let dividerDark    = Color.white.opacity(0.08)

    // Light mode palette (beige family from your Scan screen)
    static let bgLight        = Color(red: 0.96, green: 0.94, blue: 0.89)   // warm beige
    static let surfaceLight   = Color.white.opacity(0.85)
    static let cardLight      = Color.white
    static let textLight      = Color.black.opacity(0.92)
    static let subTextLight   = Color.black.opacity(0.55)
    static let dividerLight   = Color.black.opacity(0.08)

    // Brand/action colors
    static let green  = Color(hue: 0.35, saturation: 0.70, brightness: 0.75)
    static let orange = Color(hue: 0.10, saturation: 0.80, brightness: 0.90)
    static let blue   = Color(hue: 0.60, saturation: 0.70, brightness: 0.85)
    static let purple = Color(hue: 0.78, saturation: 0.50, brightness: 0.85)
    static let teal   = Color(hue: 0.47, saturation: 0.55, brightness: 0.80)
    static let red    = Color(hue: 0.00, saturation: 0.75, brightness: 0.85)
}

public struct EFBackground: ViewModifier {
    @Environment(\.colorScheme) private var scheme
    public func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if scheme == .dark { EFColor.bgDark }
                    else { EFColor.bgLight }
                }
                .ignoresSafeArea()
            )
    }
}
public extension View { func efBackground() -> some View { modifier(EFBackground()) } }

// Simple capsule pill
public struct EFPill: View {
    public let title: String
    public let color: Color
    public var body: some View {
        Text(title)
            .font(.callout.weight(.semibold))
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(color.opacity(0.18))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.45), lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// Card and Chip components moved to UI/Components/ to avoid duplicates

// MARK: - New Theme System

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

// MARK: - Theme tokens
struct EFTheme {
    static func background(_ scheme: ColorScheme) -> Color {
        EFPalette.current(scheme).background
    }
    static func surface(_ scheme: ColorScheme) -> Color {
        EFPalette.current(scheme).surface
    }
    static func cardStroke(_ scheme: ColorScheme) -> Color {
        EFPalette.current(scheme).stroke
    }
    static func text(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white : Color.black
    }
    static func muted(_ scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.6)
    }
}

final class EFThemeManagerOld: ObservableObject {
    static let shared = EFThemeManagerOld()

    @AppStorage("ef.theme") private var storedTheme: String = Theme.EFTheme.system.rawValue
    @Published var selection: Theme.EFTheme

    var resolvedColorScheme: ColorScheme? {
        switch selection {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    private init() {
        let stored = UserDefaults.standard.string(forKey: "ef.theme") ?? Theme.EFTheme.system.rawValue
        self.selection = Theme.EFTheme(rawValue: stored) ?? .system
    }

    func set(_ theme: Theme.EFTheme) {
        selection = theme
        storedTheme = theme.rawValue
    }
}