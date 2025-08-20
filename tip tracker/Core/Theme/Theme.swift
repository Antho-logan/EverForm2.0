import SwiftUI

/// Theme utilities providing colors and typography helpers.
struct Theme {
	// Colors
	static var text: Color { Palette.efText }
	static var textSecondary: Color { Palette.efTextSecondary }
	static var bg: Color { Palette.efBg }
	static var bgElevated: Color { Palette.efBgElevated }
	static var surface: Color { Palette.efSurface }
	static var accent: Color { Palette.efAccent() }
	static var border: Color { Palette.efBorder }
	static var success: Color { Palette.efSuccess }
	static var warning: Color { Palette.efWarning }
	static var shadowOpacity: Double { Palette.efShadowOpacity }

	// Typography scale
	struct Typography {
		static let display = Font.system(size: 34, weight: .semibold)
		static let title = Font.system(size: 28, weight: .semibold)
		static let heading = Font.system(size: 22, weight: .semibold)
		static let body = Font.system(size: 17, weight: .regular)
		static let subbody = Font.system(size: 15, weight: .regular)
		static let caption = Font.system(size: 13, weight: .medium)
	}

	// Spacing
	struct Spacing {
		static let xs: CGFloat = 4
		static let sm: CGFloat = 8
		static let md: CGFloat = 12
		static let lg: CGFloat = 16
		static let xl: CGFloat = 24
		static let xxl: CGFloat = 32
	}

	// Helpers
	@ViewBuilder static func h1(_ text: String) -> some View { Text(text).font(Typography.title).foregroundColor(Theme.text) }
	@ViewBuilder static func h2(_ text: String) -> some View { Text(text).font(Typography.heading).foregroundColor(Theme.text) }
	@ViewBuilder static func body(_ text: String) -> some View { Text(text).font(Typography.body).foregroundColor(Theme.textSecondary) }

	@ViewBuilder static func card<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
		content()
			.padding(Spacing.lg)
			.background(RoundedRectangle(cornerRadius: 14).fill(bgElevated))
			.shadow(color: Color.black.opacity(shadowOpacity), radius: 10, x: 0, y: 4)
	}
}

