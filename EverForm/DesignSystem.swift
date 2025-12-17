//
//  DesignSystem.swift
//  EverForm
//
//  Created by Assistant on 14/01/2025.
//  Premium Design System - WCAG AA+ Compliant
//

import SwiftUI

// MARK: - Premium Design System
struct DesignSystem {

  // MARK: - Colors (WCAG AA+ Compliant)
  struct Colors {
    // Primary Accent - Brand Blue
    static let accent = AppTheme.Colors.brandBlue
    static let accentLight = AppTheme.Colors.brandBlue.opacity(0.85)
    static let accentDark = AppTheme.Colors.brandBlue.opacity(1.0)

    // Neutral Palette
    static let neutral50 = Color(hex: "F9FAFB")  // #F9FAFB
    static let neutral100 = Color(hex: "F3F4F6")  // #F3F4F6
    static let neutral200 = Color(hex: "E5E7EB")  // #E5E7EB
    static let neutral300 = Color(hex: "D1D5DB")  // #D1D5DB
    static let neutral400 = Color(hex: "9CA3AF")  // #9CA3AF
    static let neutral500 = Color(hex: "6B7280")  // #6B7280
    static let neutral600 = Color(hex: "4B5563")  // #4B5563
    static let neutral700 = Color(hex: "374151")  // #374151
    static let neutral800 = Color(hex: "1F2937")  // #1F2937
    static let neutral900 = Color(hex: "111827")  // #111827

    // Semantic Colors
    static let success = Color(hex: "10B981")  // #10B981
    static let warning = Color(hex: "F59E0B")  // #F59E0B
    static let error = Color(hex: "EF4444")  // #EF4444
    static let info = Color(hex: "3B82F6")  // #3B82F6

    // NOTE: Usage of static dynamic colors is deprecated in favor of ThemeManager
    // Retaining strictly for backward compatibility where refactor hasn't touched yet

    private static func dynamicColor(light: UIColor, dark: UIColor) -> Color {
      Color(
        UIColor { traitCollection in
          traitCollection.userInterfaceStyle == .dark ? dark : light
        })
    }

    private static let lightBackground = UIColor(red: 0.95, green: 0.91, blue: 0.86, alpha: 1.0)  // warm beige
    private static let lightBackgroundSoft = UIColor(red: 0.97, green: 0.94, blue: 0.90, alpha: 1.0)  // lighter beige
    private static let lightBackgroundPale = UIColor(red: 0.99, green: 0.97, blue: 0.94, alpha: 1.0)  // palest beige
    private static let darkBackground = UIColor(red: 0.07, green: 0.07, blue: 0.07, alpha: 1.0)  // Dark grey/black
    private static let darkBackgroundSoft = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
    private static let darkBackgroundPale = UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1.0)

    static let background = AppTheme.Colors.appBackground
    static let backgroundSecondary = AppTheme.Colors.surfaceSecondary
    static let backgroundTertiary = AppTheme.Colors.surface

    static let textPrimary = AppTheme.Colors.textPrimary
    static let textSecondary = AppTheme.Colors.textSecondary
    static let textTertiary = AppTheme.Colors.textSecondary.opacity(0.75)

    static let border = AppTheme.Colors.separator
    static let borderSecondary = AppTheme.Colors.separator.opacity(0.8)

    // Premium Card Colors (Better contrast for light/dark)
    static var cardBackground: Color { AppTheme.Colors.surface }
    static var cardBackgroundSecondary: Color { AppTheme.Colors.surfaceSecondary }
    static var cardBackgroundElevated: Color { AppTheme.Colors.surface }

    // Button Colors (White buttons with dark icons)
    static let buttonBackground = AppTheme.Colors.surface
    static let buttonForeground = AppTheme.Colors.textPrimary
    static let buttonBackgroundDark = AppTheme.Colors.surface
    static let buttonForegroundDark = AppTheme.Colors.textPrimary

    // Icon Circle Colors
    static let iconCircleBackground = AppTheme.Colors.surface
    static let iconCircleForeground = AppTheme.Colors.textPrimary
  }

  // MARK: - Font Style System
  enum FontStyle: String, CaseIterable {
    case defaultStyle = "default"
    case typewriter = "typewriter"

    var displayName: String {
      switch self {
      case .defaultStyle: return "Default"
      case .typewriter: return "Typewriter"
      }
    }
  }

  // MARK: - App-wide Font Style Setting
  @AppStorage("fontStyle") static var currentFontStyle: String = FontStyle.defaultStyle.rawValue

  static var currentStyle: FontStyle {
    FontStyle(rawValue: currentFontStyle) ?? .defaultStyle
  }

  // MARK: - Typography System with Typewriter Support
  struct Typography {
    // MARK: - Core Font Function with Fallbacks
    static func font(
      _ style: FontStyle,
      nameCandidates: [String],
      size: CGFloat,
      relativeTo textStyle: Font.TextStyle,
      fallbackDesign: Font.Design = .default
    ) -> Font {
      guard style == .typewriter else {
        return .system(size: size, weight: .regular, design: fallbackDesign)
          .monospacedDigit()
      }

      // Try American Typewriter variants
      for candidate in nameCandidates {
        if UIFont(name: candidate, size: size) != nil {
          return Font.custom(candidate, size: size, relativeTo: textStyle)
            .monospacedDigit()
        }
      }

      // Fallback to monospaced system font for typewriter feel
      return .system(size: size, weight: .regular, design: .monospaced)
        .monospacedDigit()
    }

    // MARK: - Display Fonts (Headlines)
    static func displayLarge() -> Font {
      font(
        currentStyle,
        nameCandidates: ["AmericanTypewriter-Bold", "AmericanTypewriter-Semibold"],
        size: 48,
        relativeTo: .largeTitle,
        fallbackDesign: .default
      )
    }

    static func displayMedium() -> Font {
      font(
        currentStyle,
        nameCandidates: ["AmericanTypewriter-Bold", "AmericanTypewriter-Semibold"],
        size: 32,
        relativeTo: .title,
        fallbackDesign: .default
      )
    }

    static func displaySmall() -> Font {
      font(
        currentStyle,
        nameCandidates: ["AmericanTypewriter-Semibold", "AmericanTypewriter-Bold"],
        size: 24,
        relativeTo: .title2,
        fallbackDesign: .default
      )
    }

    // MARK: - Title Fonts
    static func titleLarge() -> Font {
      font(
        currentStyle,
        nameCandidates: ["AmericanTypewriter-Semibold", "AmericanTypewriter-Bold"],
        size: 20,
        relativeTo: .title3,
        fallbackDesign: .monospaced
      )
    }

    static func titleMedium() -> Font {
      font(
        currentStyle,
        nameCandidates: ["AmericanTypewriter-Semibold", "AmericanTypewriter"],
        size: 18,
        relativeTo: .headline,
        fallbackDesign: .monospaced
      )
    }

    static func titleSmall() -> Font {
      font(
        currentStyle,
        nameCandidates: ["AmericanTypewriter-Semibold", "AmericanTypewriter"],
        size: 16,
        relativeTo: .subheadline,
        fallbackDesign: .monospaced
      )
    }

    // MARK: - Section Headers
    static func sectionHeader() -> Font {
      font(
        currentStyle,
        nameCandidates: ["AmericanTypewriter-Semibold", "AmericanTypewriter-Bold"],
        size: 18,
        relativeTo: .headline,
        fallbackDesign: .monospaced
      )
    }

    static func heading() -> Font {
      font(
        currentStyle,
        nameCandidates: ["AmericanTypewriter-Semibold", "AmericanTypewriter-Bold"],
        size: 17,
        relativeTo: .headline,
        fallbackDesign: .default
      )
    }

    // MARK: - Button Fonts
    static func buttonLarge() -> Font {
      font(
        currentStyle,
        nameCandidates: ["AmericanTypewriter-Semibold", "AmericanTypewriter-Bold"],
        size: 16,
        relativeTo: .callout,
        fallbackDesign: .monospaced
      )
    }

    static func buttonMedium() -> Font {
      font(
        currentStyle,
        nameCandidates: ["AmericanTypewriter-Semibold", "AmericanTypewriter"],
        size: 14,
        relativeTo: .subheadline,
        fallbackDesign: .monospaced
      )
    }

    // MARK: - Body Text (Keep SF for readability)
    static func bodyLarge() -> Font {
      currentStyle == .typewriter
        ? font(currentStyle, nameCandidates: ["AmericanTypewriter"], size: 16, relativeTo: .body)
        : .system(size: 16, weight: .regular, design: .default)
    }

    static func bodyMedium() -> Font {
      currentStyle == .typewriter
        ? font(
          currentStyle, nameCandidates: ["AmericanTypewriter-Light", "AmericanTypewriter"],
          size: 14, relativeTo: .callout)
        : .system(size: 14, weight: .regular, design: .default)
    }

    static func bodySmall() -> Font {
      currentStyle == .typewriter
        ? font(
          currentStyle, nameCandidates: ["AmericanTypewriter-Light", "AmericanTypewriter"],
          size: 12, relativeTo: .caption)
        : .system(size: 12, weight: .regular, design: .default)
    }

    // MARK: - Labels
    static func labelLarge() -> Font {
      font(
        currentStyle,
        nameCandidates: ["AmericanTypewriter", "AmericanTypewriter-Light"],
        size: 14,
        relativeTo: .footnote,
        fallbackDesign: .default
      )
    }

    static func labelMedium() -> Font {
      font(
        currentStyle,
        nameCandidates: ["AmericanTypewriter", "AmericanTypewriter-Light"],
        size: 12,
        relativeTo: .caption,
        fallbackDesign: .default
      )
    }

    static func labelSmall() -> Font {
      font(
        currentStyle,
        nameCandidates: ["AmericanTypewriter", "AmericanTypewriter-Light"],
        size: 11,
        relativeTo: .caption2,
        fallbackDesign: .default
      )
    }

    // MARK: - Caption
    static func caption() -> Font {
      font(
        currentStyle,
        nameCandidates: ["AmericanTypewriter-Light", "AmericanTypewriter"],
        size: 10,
        relativeTo: .caption2,
        fallbackDesign: .default
      )
    }

    // MARK: - Monospaced Numbers (for metrics/stats)
    static func monospacedNumber(size: CGFloat, relativeTo textStyle: Font.TextStyle) -> Font {
      currentStyle == .typewriter
        ? font(
          currentStyle, nameCandidates: ["AmericanTypewriter-Bold", "AmericanTypewriter"],
          size: size, relativeTo: textStyle, fallbackDesign: .monospaced)
        : .system(size: size, weight: .semibold, design: .monospaced).monospacedDigit()
    }

    // Note: All typography now uses function calls (e.g., Typography.titleLarge())
    // to support dynamic font style switching
  }

  // MARK: - Spacing (8pt Grid System)
  struct Spacing {
    static let xs: CGFloat = 4  // 0.5 units
    static let sm: CGFloat = 8  // 1 unit
    static let md: CGFloat = 16  // 2 units
    static let lg: CGFloat = 24  // 3 units
    static let xl: CGFloat = 32  // 4 units
    static let xxl: CGFloat = 48  // 6 units
    static let xxxl: CGFloat = 64  // 8 units

    // Semantic Spacing
    static let cardPadding: CGFloat = 16
    static let sectionPadding: CGFloat = 24
    static let screenPadding: CGFloat = 16
  }

  // MARK: - Layout Constants
  struct Layout {
    static let barHeight: CGFloat = 60
    static let cameraSize: CGFloat = 56
  }

  // MARK: - Border & Radius
  struct Border {
    static let hairline: CGFloat = 1
    static let thin: CGFloat = 2
    static let medium: CGFloat = 4

    // Black outline for better visual definition
    static let outline: CGFloat = 1.5
    static var outlineColor: Color {
      return Color.black.opacity(0.15)
    }
  }

  struct Radius {
    static let none: CGFloat = 0
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let full: CGFloat = 999
  }

  // MARK: - Shadows (Elevation 0-1)
  struct Shadow {
    static let none = ShadowStyle.none
    static let sm = ShadowStyle.sm
    static let md = ShadowStyle.md

    enum ShadowStyle {
      case none, sm, md

      var radius: CGFloat {
        switch self {
        case .none: return 0
        case .sm: return 2
        case .md: return 4
        }
      }

      var offset: CGSize {
        switch self {
        case .none: return .zero
        case .sm: return CGSize(width: 0, height: 1)
        case .md: return CGSize(width: 0, height: 2)
        }
      }

      var opacity: Double {
        switch self {
        case .none: return 0
        case .sm: return 0.05
        case .md: return 0.1
        }
      }
    }
  }

  // MARK: - Animation Timings
  struct Animation {
    static let fast = 0.15
    static let medium = 0.2
    static let slow = 0.3

    // Easing Functions
    static let easeInOut = SwiftUI.Animation.easeInOut(duration: medium)
    static let spring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8)
    static let springFast = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let springSlow = SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.8)
  }

  // MARK: - Icon Sizes
  struct IconSize {
    static let small: CGFloat = 20
    static let medium: CGFloat = 24
    static let large: CGFloat = 28
  }

  // MARK: - Touch Targets (WCAG AA+ - Min 44px)
  struct TouchTarget {
    static let minimum: CGFloat = 44
    static let comfortable: CGFloat = 48
    static let large: CGFloat = 56
  }
}

// MARK: - Color Extension for Hex Support
extension Color {
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let a: UInt64
    let r: UInt64
    let g: UInt64
    let b: UInt64
    switch hex.count {
    case 3:  // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6:  // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8:  // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (1, 1, 1, 0)
    }

    self.init(
      .sRGB,
      red: Double(r) / 255,
      green: Double(g) / 255,
      blue: Double(b) / 255,
      opacity: Double(a) / 255
    )
  }

  func toHex() -> String {
    let uic = UIColor(self)
    guard let components = uic.cgColor.components, components.count >= 3 else {
      return "000000"
    }
    let r = Float(components[0])
    let g = Float(components[1])
    let b = Float(components[2])
    return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
  }
}

// MARK: - View Modifiers for Design System
extension View {
  // cardStyle moved to EverFormTheme.swift

  func buttonPrimaryStyle() -> some View {
    self
      .font(DesignSystem.Typography.buttonLarge())
      .foregroundStyle(.white)
      .frame(maxWidth: .infinity)
      .frame(height: 56)
      .background(
        LinearGradient(
          colors: [
            DesignSystem.Colors.accentLight,
            DesignSystem.Colors.accent,
          ],
          startPoint: .top,
          endPoint: .bottom
        )
      )
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .shadow(color: DesignSystem.Colors.accent.opacity(0.3), radius: 8, x: 0, y: 4)
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(Color.white.opacity(0.2), lineWidth: 1)
      )
  }

  func buttonSecondaryStyle() -> some View {
    self
      .font(DesignSystem.Typography.buttonLarge())
      .foregroundStyle(DesignSystem.Colors.textPrimary)
      .frame(maxWidth: .infinity)
      .frame(height: 56)
      .background(DesignSystem.Colors.cardBackgroundSecondary)
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(DesignSystem.Colors.border, lineWidth: 1)
      )
  }

  func buttonGhostStyle() -> some View {
    self
      .font(DesignSystem.Typography.buttonMedium())
      .foregroundStyle(DesignSystem.Colors.textSecondary)
      .frame(height: 44)
      .padding(.horizontal, 16)
      .background(Color.clear)
  }
}

/// The single source of truth for the EverForm design system.
/// Wraps tokens for Colors, Typography, Spacing, Radii, and Shadows.
public struct EverFormThemeLegacy {

  // MARK: - Colors
  public struct Colors {

    // MARK: Backgrounds & Surfaces
    public static var background: Color {
      ThemeManager.shared.backgroundPrimary
    }

    public static var surface: Color {
      ThemeManager.shared.backgroundSecondary
    }

    public static var card: Color {
      ThemeManager.shared.cardBackground
    }

    public static var cardStroke: Color {
      ThemeManager.shared.border
    }

    public static var divider: Color {
      ThemeManager.shared.border
    }

    // MARK: Text
    public static var textPrimary: Color {
      ThemeManager.shared.textPrimary
    }

    public static var textSecondary: Color {
      ThemeManager.shared.textSecondary
    }

    public static var textMuted: Color {
      ThemeManager.shared.textSecondary.opacity(0.7)
    }

    public static var textOnAccent: Color {
      Color.white
    }

    // MARK: Domain Accents
    public static let trainingGreen = Color(hex: "2E7D32")  // Deep natural green
    public static let nutritionOrange = Color(hex: "ED6C02")  // Warm vibrant orange
    public static let recoveryBlue = Color(hex: "0288D1")  // Calming blue
    public static let mobilityPurple = Color(hex: "7B1FA2")  // Deep purple
    public static let breathworkTeal = Color(hex: "009688")  // Teal
    public static let fixPainIndigo = Color(hex: "3F51B5")  // Indigo
    public static let lookMaxPink = Color(hex: "C2185B")  // Pink

    // MARK: Semantic Status
    public static let infoBlue = Color(hex: "2196F3")
    public static let warningAmber = Color(hex: "FF9800")
    public static let successGreen = Color(hex: "4CAF50")
    public static let errorRed = Color(hex: "F44336")

    // MARK: Gradients
    public static func gradient(for color: Color) -> LinearGradient {
      LinearGradient(
        colors: [color.opacity(0.8), color],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    }

    public static func darkGradient(for color: Color) -> LinearGradient {
      LinearGradient(
        colors: [color.opacity(0.3), color.opacity(0.1)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    }
  }

  // MARK: - Typography
  /// Reuses the existing Typography system but exposes semantic tokens
  public struct Typography {
    public static var screenTitle: Font { Font.app(.largeTitle) }
    public static var sectionTitle: Font { Font.app(.title) }
    public static var cardTitle: Font { Font.app(.heading) }
    public static var metricValue: Font { Font.custom("ScienceGothic-Medium", size: 32) }  // Custom for metrics
    public static var body: Font { Font.app(.body) }
    public static var caption: Font { Font.app(.caption) }
    public static var label: Font { Font.app(.label) }
    public static var button: Font { Font.app(.button) }
  }

  // MARK: - Spacing
  public struct Spacing {
    public static let screenPadding: CGFloat = 20
    public static let sectionSpacing: CGFloat = 24
    public static let cardPadding: CGFloat = 16
    public static let gridSpacing: CGFloat = 12
    public static let vStackSpacing: CGFloat = 16
    public static let vStackLoose: CGFloat = 24
    public static let heroTopInset: CGFloat = 44

    // Standard sizing
    public static let xs: CGFloat = 4
    public static let sm: CGFloat = 8
    public static let md: CGFloat = 16
    public static let lg: CGFloat = 24
    public static let xl: CGFloat = 32
    public static let xxl: CGFloat = 48
  }

  // MARK: - Radii & Shadows
  public struct Radius {
    public static let card: CGFloat = 18
    public static let hero: CGFloat = 24
    public static let pill: CGFloat = 12
    public static let segmented: CGFloat = 12
    public static let small: CGFloat = 8
  }

  public struct Shadows {
    public static func light() -> Color {
      Color.black.opacity(0.08)
    }

    public static func dark() -> Color {
      Color.black.opacity(0.35)
    }

    public static let radius: CGFloat = 16
    public static let y: CGFloat = 8
  }
}
