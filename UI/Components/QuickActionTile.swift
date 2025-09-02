//
//  QuickActionTile.swift
//  EverForm
//
//  Reusable quick action tile with semantic styling
//

import SwiftUI

struct QuickActionTile: View {
    let icon: String
    let title: String
    let style: SemanticStyle
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    
    enum SemanticStyle: String, Codable, CaseIterable {
        case success, info, danger, water

        func color(for colorScheme: ColorScheme) -> Color {
            let semantic = Theme.semantic(colorScheme)
            switch self {
            case .success: return semantic.success
            case .info: return semantic.info
            case .danger: return semantic.danger
            case .water: return semantic.water
            }
        }
    }
    
    var body: some View {
        let semanticColor = style.color(for: colorScheme)

        Button(action: action) {
            VStack(spacing: 8) {
                // Icon with semantic color background
                ZStack {
                    Circle()
                        .fill(Color(.systemFill))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(semanticColor)
                }

                // Title
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 96)
            .efCard()
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: isPressed)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        }, perform: {})
        .accessibilityLabel(title)
        .accessibilityHint("Tap to \(title.lowercased())")
    }
}

#Preview {
    let palette = Theme.palette(.light)
    
    VStack(spacing: 16) {
        HStack(spacing: 12) {
            QuickActionTile(
                icon: "drop.fill",
                title: "Add Water",
                style: .water
            ) {}
            
            QuickActionTile(
                icon: "wind",
                title: "Breathwork",
                style: .success
            ) {}
        }
        
        HStack(spacing: 12) {
            QuickActionTile(
                icon: "cross.case",
                title: "Fix Pain",
                style: .danger
            ) {}
            
            QuickActionTile(
                icon: "brain.head.profile",
                title: "Ask Coach",
                style: .info
            ) {}
        }
    }
    .padding()
    .background(palette.background)
}
