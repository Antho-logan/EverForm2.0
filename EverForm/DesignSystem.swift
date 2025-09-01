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
        // Primary Accent - Premium Blue
        static let accent = Color(hex: "0066FF") // #0066FF - High contrast blue
        static let accentLight = Color(hex: "3385FF")
        static let accentDark = Color(hex: "0052CC")
        
        // Neutral Palette
        static let neutral50 = Color(hex: "F9FAFB")   // #F9FAFB
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
        static let success = Color(hex: "10B981")     // #10B981
        static let warning = Color(hex: "F59E0B")     // #F59E0B
        static let error = Color(hex: "EF4444")       // #EF4444
        static let info = Color(hex: "3B82F6")        // #3B82F6
        
        // Dynamic Colors (Light/Dark adaptive)
        static let background = Color(.systemBackground)
        static let backgroundSecondary = Color(.secondarySystemBackground)
        static let backgroundTertiary = Color(.tertiarySystemBackground)
        
        static let textPrimary = Color(.label)
        static let textSecondary = Color(.secondaryLabel)
        static let textTertiary = Color(.tertiaryLabel)
        
        static let border = Color(.separator)
        static let borderSecondary = Color(.opaqueSeparator)
        
        // Premium Card Colors (Better contrast for light/dark)
        static var cardBackground: Color {
            Color(.systemBackground).opacity(0.8)
        }
        
        static var cardBackgroundSecondary: Color {
            #if os(iOS)
            return Color(UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor.secondarySystemBackground
                default:
                    return UIColor.systemGray6
                }
            })
            #else
            return Color(.secondarySystemBackground)
            #endif
        }
        
        static var cardBackgroundElevated: Color {
            #if os(iOS)
            return Color(UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor.tertiarySystemBackground
                default:
                    return UIColor.white
                }
            })
            #else
            return Color(.tertiarySystemBackground)
            #endif
        }
        
        // Button Colors (White buttons with dark icons)
        static let buttonBackground = Color.white
        static let buttonForeground = Color.black
        static let buttonBackgroundDark = Color.black
        static let buttonForegroundDark = Color.white
        
        // Icon Circle Colors
        static let iconCircleBackground = Color.white
        static let iconCircleForeground = Color.black
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
                ? font(currentStyle, nameCandidates: ["AmericanTypewriter-Light", "AmericanTypewriter"], size: 14, relativeTo: .callout)
                : .system(size: 14, weight: .regular, design: .default)
        }
        
        static func bodySmall() -> Font {
            currentStyle == .typewriter 
                ? font(currentStyle, nameCandidates: ["AmericanTypewriter-Light", "AmericanTypewriter"], size: 12, relativeTo: .caption)
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
                ? font(currentStyle, nameCandidates: ["AmericanTypewriter-Bold", "AmericanTypewriter"], size: size, relativeTo: textStyle, fallbackDesign: .monospaced)
                : .system(size: size, weight: .semibold, design: .monospaced).monospacedDigit()
        }
        
        // Note: All typography now uses function calls (e.g., Typography.titleLarge()) 
        // to support dynamic font style switching
    }
    
    // MARK: - Spacing (8pt Grid System)
    struct Spacing {
        static let xs: CGFloat = 4    // 0.5 units
        static let sm: CGFloat = 8    // 1 unit
        static let md: CGFloat = 16   // 2 units
        static let lg: CGFloat = 24   // 3 units
        static let xl: CGFloat = 32   // 4 units
        static let xxl: CGFloat = 48  // 6 units
        static let xxxl: CGFloat = 64 // 8 units
        
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
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
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
    func cardStyle() -> some View {
        self
            .background(DesignSystem.Colors.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
            .shadow(
                color: .black.opacity(DesignSystem.Shadow.sm.opacity),
                radius: DesignSystem.Shadow.sm.radius,
                x: DesignSystem.Shadow.sm.offset.width,
                y: DesignSystem.Shadow.sm.offset.height
            )
    }
    
    func buttonPrimaryStyle() -> some View {
        self
            .frame(minHeight: DesignSystem.TouchTarget.minimum)
            .background(DesignSystem.Colors.accent)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
    }
    
    func buttonSecondaryStyle() -> some View {
        self
            .frame(minHeight: DesignSystem.TouchTarget.minimum)
            .background(DesignSystem.Colors.backgroundSecondary)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
    }
}
