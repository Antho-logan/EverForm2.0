//
//  EFPillButton.swift
//  EverForm
//
//  Pill-style button component
//

import SwiftUI

struct EFPillButton: View {
    let title: String
    let style: Style
    let color: Color?
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    enum Style {
        case primary, secondary
    }

    init(title: String, style: Style, color: Color? = nil, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.color = color
        self.action = action
    }

    var body: some View {
        let palette = Theme.palette(colorScheme)
        let buttonColor = color ?? palette.accent

        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(style == .primary ? .white : buttonColor)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(style == .primary ? buttonColor : buttonColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.pill))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.pill)
                        .stroke(style == .primary ? Color.clear : buttonColor, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 16) {
        EFPillButton(title: "Primary Button", style: .primary) {
            print("Primary tapped")
        }
        
        EFPillButton(title: "Secondary Button", style: .secondary) {
            print("Secondary tapped")
        }
        
        EFPillButton(title: "Green Button", style: .primary, color: .green) {
            print("Green tapped")
        }
    }
    .padding()
}
