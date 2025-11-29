import SwiftUI

struct FeatureHistorySection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
            
            content
        }
        .padding(.horizontal, 20)
    }
}

struct FeatureHistoryRow: View {
    let title: String
    let subtitle: String
    let detail: String?
    let icon: String
    let iconColor: Color
    let action: () -> Void
    
    init(
        title: String,
        subtitle: String,
        detail: String? = nil,
        icon: String,
        iconColor: Color = DesignSystem.Colors.accent,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.detail = detail
        self.icon = icon
        self.iconColor = iconColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.backgroundSecondary)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(iconColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                if let detail = detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
            .padding()
            .background(DesignSystem.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}