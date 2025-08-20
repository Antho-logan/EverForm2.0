import SwiftUI

/// Color palette tokens used by Theme.
struct Palette {
	static let ink = Color("ink")
	static let charcoal = Color("charcoal")
	static let sakura = Color("sakura")
	static let indigo = Color("indigo")
	static let matcha = Color("matcha")

	// Semantic (light/dark aware via system colors blended with accent)
	static var efBg: Color { Color(.systemBackground) }
	static var efBgElevated: Color { Color(.secondarySystemBackground) }
	static var efSurface: Color { Color(.tertiarySystemBackground) }
	static var efText: Color { Color.primary }
	static var efTextSecondary: Color { Color.secondary }
	static var efBorder: Color { Color(.separator) }
	static var efSuccess: Color { Color.green.opacity(0.9) }
	static var efWarning: Color { Color.orange.opacity(0.9) }
	static var efShadowOpacity: Double { 0.06 }

	static func efAccent(current: String = "indigo") -> Color {
		switch current.lowercased() {
		case "sakura": return sakura
		case "matcha": return matcha
		default: return indigo
		}
	}
}

