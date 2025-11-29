import SwiftUI

struct NotificationsPopoverView: View {
  @Binding var isPresented: Bool
  var onViewAllTap: (() -> Void)?
  @Environment(ThemeManager.self) private var themeManager

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // Header
      HStack {
        VStack(alignment: .leading, spacing: 2) {
          Text("Notifications")
            .font(EverFont.cardTitle)
            .foregroundStyle(themeManager.textPrimary)

          Text("Recent updates")
            .font(EverFont.caption)
            .foregroundStyle(themeManager.textSecondary)
        }

        Spacer()

        Button {
          withAnimation {
            isPresented = false
          }
        } label: {
          Image(systemName: "xmark.circle.fill")
            .foregroundStyle(themeManager.textSecondary)
            .font(.system(size: 22))
        }
        .buttonStyle(.plain)
      }
      .padding(16)

      Divider()
        .background(themeManager.border)

      // List
      ScrollView {
        VStack(spacing: 0) {
          NotificationItem(
            color: .green,
            title: "Training session completed",
            subtitle: "Upper Body • 45 min"
          )

          Divider().background(themeManager.border).padding(.leading, 40)

          NotificationItem(
            color: .orange,
            title: "Calorie target exceeded",
            subtitle: "Try adding a walk today"
          )

          Divider().background(themeManager.border).padding(.leading, 40)

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
        .background(themeManager.border)

      // Footer
      Button {
        onViewAllTap?()
      } label: {
        Text("View all")
          .font(EverFont.button)
          .foregroundStyle(DesignSystem.Colors.accent)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 12)
      }
    }
    .background(themeManager.cardBackground)
    .clipShape(RoundedRectangle(cornerRadius: 20))
    .shadow(color: themeManager.cardShadow, radius: 20, x: 0, y: 10)
    .overlay(
      RoundedRectangle(cornerRadius: 20)
        .stroke(themeManager.border, lineWidth: 0.5)
    )
    // Popover animation
    .scaleEffect(isPresented ? 1.0 : 0.95, anchor: .topTrailing)
    .opacity(isPresented ? 1.0 : 0)
    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPresented)
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
          .font(EverFont.bodySecondary)
          .foregroundStyle(themeManager.textPrimary)

        Text(subtitle)
          .font(EverFont.caption)
          .foregroundStyle(themeManager.textSecondary)
      }

      Spacer()
    }
    .padding(12)
    .contentShape(Rectangle())
  }
}
