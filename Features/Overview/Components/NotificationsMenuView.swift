
import SwiftUI

struct NotificationsMenuView: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Notifications")
                        .font(.headline)
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    Text("Recent updates")
                        .font(.caption)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                Button {
                    withAnimation {
                        isPresented = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DesignSystem.Colors.textTertiary)
                        .font(.system(size: 22))
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            
            Divider()
                .background(DesignSystem.Colors.border)
            
            // List
            ScrollView {
                VStack(spacing: 0) {
                    NotificationItem(
                        color: .green,
                        title: "Training session completed",
                        subtitle: "Upper Body • 45 min"
                    )
                    
                    Divider().padding(.leading, 40)
                    
                    NotificationItem(
                        color: .orange,
                        title: "Calorie target exceeded",
                        subtitle: "Try adding a walk today"
                    )
                    
                    Divider().padding(.leading, 40)
                    
                    NotificationItem(
                        color: .blue,
                        title: "New breathwork program",
                        subtitle: "Available now"
                    )
                }
                .padding(.vertical, 8)
            }
            .frame(maxHeight: 260)
            
            Divider()
                .background(DesignSystem.Colors.border)
            
            // Footer
            Button {
                print("View all tapped")
            } label: {
                Text("View all")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(DesignSystem.Colors.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
        }
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(DesignSystem.Colors.border, lineWidth: 0.5)
        )
    }
    
    @ViewBuilder
    private func NotificationItem(color: Color, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
        }
        .padding(12)
    }
}

