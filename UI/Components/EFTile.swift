import SwiftUI

public struct EFTile: View {
    @Environment(\.colorScheme) private var scheme
    let icon: String
    let title: String
    let value: String?
    let action: () -> Void
    
    @State private var isPressed = false
    
    public init(icon: String, title: String, value: String? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.value = value
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            VStack(spacing: Theme.Spacing.sm) {
                ZStack {
                    Circle()
                        .fill(Theme.palette(scheme).accent.opacity(0.15))
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.palette(scheme).accent)
                }
                
                VStack(spacing: 2) {
                    if let value = value {
                        Text(value)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Theme.palette(scheme).textPrimary)
                    }
                    
                    Text(title.uppercased())
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(Theme.palette(scheme).textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(minWidth: 56, minHeight: 56)
            .padding(Theme.Spacing.md)
            .background(Theme.palette(scheme).surfaceElevated)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .stroke(Theme.palette(scheme).stroke, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            .shadow(
                color: Theme.Shadow.card,
                radius: 8,
                x: 0,
                y: 4
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isPressed ? 0.8 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        }, perform: {})
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title): \(value ?? "")")
        .accessibilityAddTraits(.isButton)
        .frame(minWidth: 44, minHeight: 44)
    }
}

#Preview {
    HStack {
        EFTile(icon: "figure.walk", title: "Steps", value: "8,234") {}
        EFTile(icon: "flame.fill", title: "Calories", value: "1,456") {}
        EFTile(icon: "bed.double.fill", title: "Sleep", value: "7h 32m") {}
        EFTile(icon: "drop.fill", title: "Water", value: "6 cups") {}
    }
    .padding()
    .background(Theme.palette(.dark).background)
}
