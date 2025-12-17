import SwiftUI

// MARK: - EverForm Global Design System

struct EverFormTheme {
    
    // MARK: - Colors
    struct Colors {
        // MARK: New global theme colors (semantic, dynamic via Asset Catalog)
        static let appBackground = AppTheme.Colors.appBackground
        static let cardBackground = AppTheme.Colors.surface
        static let primaryBlue = AppTheme.Colors.brandBlue

        // Semantic text
        static let textPrimary = AppTheme.Colors.textPrimary
        static let textSecondary = AppTheme.Colors.textSecondary
        static let separator = AppTheme.Colors.separator
        static let shadow = AppTheme.Colors.shadow
        static let dangerBackground = AppTheme.Colors.dangerBackground
        static let dangerText = AppTheme.Colors.dangerText

        static let surfaceSecondary = AppTheme.Colors.surfaceSecondary
        
        // Forwarding to Legacy/DesignSystem for compatibility
        static var background: Color { EverFormThemeLegacy.Colors.background }
        static var surface: Color { EverFormThemeLegacy.Colors.surface }
        static var card: Color { EverFormThemeLegacy.Colors.card }
        static var cardStroke: Color { EverFormThemeLegacy.Colors.cardStroke }
        static var border: Color { EverFormThemeLegacy.Colors.divider }
        static var divider: Color { EverFormThemeLegacy.Colors.divider }
        static var textOnAccent: Color { EverFormThemeLegacy.Colors.textOnAccent }
        
        static let trainingGreen = EverFormThemeLegacy.Colors.trainingGreen
        static let nutritionOrange = EverFormThemeLegacy.Colors.nutritionOrange
        static let recoveryBlue = EverFormThemeLegacy.Colors.recoveryBlue
        static let mobilityPurple = EverFormThemeLegacy.Colors.mobilityPurple
        static let breathworkTeal = EverFormThemeLegacy.Colors.breathworkTeal
        static let fixPainIndigo = EverFormThemeLegacy.Colors.fixPainIndigo
        static let lookMaxPink = EverFormThemeLegacy.Colors.lookMaxPink
        
        static let infoBlue = EverFormThemeLegacy.Colors.infoBlue
        static let warningAmber = EverFormThemeLegacy.Colors.warningAmber
        static let successGreen = EverFormThemeLegacy.Colors.successGreen
        static let errorRed = EverFormThemeLegacy.Colors.errorRed
        
        // From DesignSystem
        static let success = DesignSystem.Colors.success
        static let warning = DesignSystem.Colors.warning
        static let error = DesignSystem.Colors.error
        
        static let neutral100 = DesignSystem.Colors.neutral100
        static let neutral400 = DesignSystem.Colors.neutral400
        
        static func gradient(for color: Color) -> LinearGradient {
            EverFormThemeLegacy.Colors.gradient(for: color)
        }
    }
    
    // MARK: - Fonts
    struct Fonts {
        static func sectionTitle() -> Font {
            .system(size: 22, weight: .bold, design: .default)
        }
        
        static func buttonText() -> Font {
            .system(size: 17, weight: .bold, design: .default)
        }
    }
    
    // Forwarding Typography
    typealias Typography = EverFormThemeLegacy.Typography
    typealias Spacing = EverFormThemeLegacy.Spacing
    typealias Radius = EverFormThemeLegacy.Radius
    typealias Shadows = EverFormThemeLegacy.Shadows
}

// MARK: - View Modifiers

extension View {
    
    /// Standard screen padding for main content containers
    func screenPadding() -> some View {
        self.padding(.horizontal, 20)
    }
    
    /// Consistent font/spacing for section headers
    func sectionTitle() -> some View {
        self
            .font(EverFormTheme.Fonts.sectionTitle())
            .foregroundStyle(EverFormTheme.Colors.textPrimary)
            .padding(.bottom, 8)
    }
    
    /// Global Card Style
    /// Background: White, Radius: 20, Shadow: Soft
    func cardStyle() -> some View {
        self
            .background(EverFormTheme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: EverFormTheme.Colors.shadow, radius: 10, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(EverFormTheme.Colors.separator.opacity(0.5), lineWidth: 0.5)
            )
    }
    
    /// Global Chip Style for small pills
    func chipStyle() -> some View {
        self
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(EverFormTheme.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: EverFormTheme.Colors.shadow, radius: 4, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(EverFormTheme.Colors.separator.opacity(0.5), lineWidth: 0.5)
            )
    }
}

// MARK: - Components

struct EverFormCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(16)
            .cardStyle()
    }
}

struct EverFormPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(EverFormTheme.Fonts.buttonText())
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(EverFormTheme.Colors.primaryBlue)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            .shadow(color: EverFormTheme.Colors.primaryBlue.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

// Helper to make it easier to apply
extension Button {
    func primaryStyle() -> some View {
        self.buttonStyle(EverFormPrimaryButtonStyle())
    }
}
