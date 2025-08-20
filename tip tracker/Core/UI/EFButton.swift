import SwiftUI

enum EFButtonStyle {
	case primary
	case secondary
	case ghost
}

struct EFButton: View {
	let title: String
	let style: EFButtonStyle
	var fullWidth: Bool = false
	var isLoading: Bool = false
	var isDisabled: Bool = false
	var accessibilityId: String?
	var action: () -> Void

	var body: some View {
		Button(action: onTap) {
			HStack {
				if isLoading { ProgressView().progressViewStyle(.circular) }
				Text(title)
					.font(Theme.Typography.body)
					.fontWeight(.semibold)
			}
			.frame(maxWidth: fullWidth ? .infinity : nil, minHeight: 48)
		}
		.buttonStyle(PlainButtonStyle())
		.background(background)
		.foregroundColor(foreground)
		.overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: 1))
		.cornerRadius(12)
		.opacity(isDisabled || isLoading ? 0.6 : 1.0)
		.accessibilityLabel(accessibilityId ?? title)
	}

	private var background: some View {
		RoundedRectangle(cornerRadius: 12).fill(fillColor)
	}
	private var fillColor: Color {
		switch style {
		case .primary: return Theme.accent
		case .secondary: return Theme.bg
		case .ghost: return Color.clear
		}
	}
	private var foreground: Color {
		switch style {
		case .primary: return Color.white
		case .secondary: return Theme.text
		case .ghost: return Theme.accent
		}
	}
	private var borderColor: Color {
		switch style {
		case .primary: return Color.clear
		case .secondary: return Theme.border
		case .ghost: return Color.clear
		}
	}

	private func onTap() {
		guard !isDisabled && !isLoading else { return }
		DebugLog.info("EFButton tap title=\(title)")
		action()
	}
}







