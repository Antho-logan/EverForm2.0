import SwiftUI

enum EFSocialProvider { case apple, google, facebook }

struct EFSocialButton: View {
	let provider: EFSocialProvider
	let title: String
	var fullWidth: Bool = true
	var accessibilityId: String?
	var action: () -> Void

	var body: some View {
		Button(action: {
			DebugLog.info("Social tap provider=\(label)")
			action()
		}) {
			HStack(spacing: 8) {
				Image(systemName: icon).frame(width: 20)
				Text(title).font(Theme.Typography.body).fontWeight(.semibold)
				Spacer()
			}
			.padding(.horizontal, 14)
			.frame(maxWidth: fullWidth ? .infinity : nil, minHeight: 48)
		}
		.buttonStyle(.plain)
		.background(background)
		.foregroundColor(foreground)
		.overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: 1))
		.cornerRadius(12)
		.accessibilityLabel(accessibilityId ?? label)
	}

	private var label: String {
		switch provider {
		case .apple: return "apple"
		case .google: return "google"
		case .facebook: return "facebook"
		}
	}
	private var icon: String {
		switch provider {
		case .apple: return "apple.logo"
		case .google: return "g.circle"
		case .facebook: return "f.cursive"
		}
	}
	private var background: Color {
		switch provider {
		case .apple: return .black
		case .google: return Theme.bg
		case .facebook: return Color.blue.opacity(0.85)
		}
	}
	private var foreground: Color {
		switch provider {
		case .apple: return .white
		case .google: return Theme.text
		case .facebook: return .white
		}
	}
	private var borderColor: Color {
		switch provider {
		case .apple: return .clear
		case .google: return Theme.border
		case .facebook: return .clear
		}
	}
}







