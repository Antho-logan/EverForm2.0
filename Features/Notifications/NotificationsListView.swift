import SwiftUI

struct NotificationsListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        EFScreenContainer {
            VStack(spacing: 0) {
                EFHeader(title: "Notifications", showBack: true)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        NotificationListRow(
                            color: .green,
                            icon: "checkmark.circle.fill",
                            title: "Training Completed",
                            subtitle: "Upper Body Power • 45 min",
                            time: "2h ago"
                        )
                        
                        NotificationListRow(
                            color: .orange,
                            icon: "exclamationmark.triangle.fill",
                            title: "Calorie Target Exceeded",
                            subtitle: "You are 200 kcal over your daily limit. Consider a light walk.",
                            time: "5h ago"
                        )
                        
                        NotificationListRow(
                            color: .blue,
                            icon: "wind",
                            title: "New Breathwork",
                            subtitle: "The 'Deep Focus' session is now available in your library.",
                            time: "1d ago"
                        )
                        
                        NotificationListRow(
                            color: .purple,
                            icon: "figure.flexibility",
                            title: "Mobility Routine",
                            subtitle: "Don't forget your evening mobility work.",
                            time: "1d ago"
                        )
                    }
                    .padding(20)
                }
            }
        }
    }
    
    @ViewBuilder
    private func NotificationListRow(color: Color, icon: String, title: String, subtitle: String, time: String) -> some View {
        EFCard {
            HStack(alignment: .top, spacing: 16) {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .foregroundStyle(color)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(EverFont.body)
                            .foregroundStyle(themeManager.textPrimary)
                        Spacer()
                        Text(time)
                            .font(EverFont.caption)
                            .foregroundStyle(themeManager.textSecondary)
                    }
                    
                    Text(subtitle)
                        .font(EverFont.bodySecondary)
                        .foregroundStyle(themeManager.textSecondary)
                        .lineLimit(2)
                }
            }
        }
    }
}

