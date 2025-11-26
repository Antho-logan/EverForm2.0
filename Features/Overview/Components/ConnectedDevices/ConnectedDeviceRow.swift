import SwiftUI

struct ConnectedDeviceRow: View {
    let icon: String
    let title: String
    let description: String
    let isConnected: Bool
    let isAvailable: Bool
    let action: () -> Void
    
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(themeManager.backgroundSecondary)
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isConnected ? DesignSystem.Colors.accent : themeManager.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(DesignSystem.Typography.bodyLarge())
                    .foregroundStyle(themeManager.textPrimary)
                
                Text(description)
                    .font(DesignSystem.Typography.caption())
                    .foregroundStyle(themeManager.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
            }
            
            Spacer()
            
            if isAvailable {
                Button(action: action) {
                    Text(isConnected ? "Connected" : "Connect")
                        .font(DesignSystem.Typography.buttonMedium())
                        .foregroundStyle(isConnected ? .white : themeManager.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            isConnected ? DesignSystem.Colors.accent : themeManager.backgroundSecondary
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            } else {
                Text("Unavailable")
                    .font(DesignSystem.Typography.caption())
                    .foregroundStyle(themeManager.textSecondary)
            }
        }
        .padding(16)
        .background(themeManager.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: themeManager.cardShadow, radius: 4, x: 0, y: 2)
    }
}

