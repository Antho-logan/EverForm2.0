import SwiftUI

struct ProfileMenuPopoverView: View {
  @Binding var isPresented: Bool
  var onConnectedDevicesTap: (() -> Void)?
  @Environment(ThemeManager.self) private var themeManager

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // Header with Avatar
      HStack(spacing: 12) {
        Circle()
          .fill(themeManager.backgroundSecondary)
          .frame(width: 48, height: 48)
          .overlay(
            Text("AL")
              .font(EverFont.cardTitle)
              .foregroundStyle(themeManager.textPrimary)
          )

        VStack(alignment: .leading, spacing: 2) {
          Text("Anthony Logan")
            .font(EverFont.cardTitle)
            .foregroundStyle(themeManager.textPrimary)

          Text("anthonylogan1995@gmail.com")
            .font(EverFont.caption)
            .foregroundStyle(themeManager.textSecondary)
        }
      }
      .padding(16)

      Divider()
        .background(themeManager.border)

      // Menu Items
      VStack(spacing: 4) {
        MenuButton(icon: "person", title: "Account")
        
        MenuButton(icon: "link", title: "Connected Devices") {
            onConnectedDevicesTap?()
        }

        // Appearance Toggle
        HStack {
          Image(systemName: "sun.max")
            .font(.system(size: 16))
            .foregroundStyle(themeManager.textSecondary)
            .frame(width: 24)

          Text("Appearance")
            .font(EverFont.bodySecondary)
            .foregroundStyle(themeManager.textPrimary)

          Spacer()

          Picker(
            "Appearance",
            selection: Binding(
              get: { themeManager.selectedTheme },
              set: { themeManager.setTheme($0) }
            )
          ) {
            Text("Light").tag(ThemeMode.light)
            Text("Dark").tag(ThemeMode.dark)
          }
          .pickerStyle(.segmented)
          .frame(width: 160)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)

        MenuButton(icon: "bell", title: "Notifications")
        MenuButton(icon: "lock", title: "Privacy & Security")
        MenuButton(icon: "questionmark.circle", title: "Help & Support")
        MenuButton(
          icon: "rectangle.portrait.and.arrow.right", title: "Sign Out", isDestructive: true)
      }
      .padding(8)
    }
    .background(themeManager.cardBackground)
    .clipShape(RoundedRectangle(cornerRadius: 20))
    .shadow(color: themeManager.cardShadow, radius: 20, x: 0, y: 10)
    .overlay(
      RoundedRectangle(cornerRadius: 20)
        .stroke(themeManager.border, lineWidth: 0.5)
    )
    // Popover animation
    .scaleEffect(isPresented ? 1.0 : 0.95, anchor: .topLeading)
    .opacity(isPresented ? 1.0 : 0)
    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPresented)
  }

  @ViewBuilder
  private func MenuButton(icon: String, title: String, isDestructive: Bool = false, action: (() -> Void)? = nil) -> some View {
    Button {
      action?()
    } label: {
      HStack(spacing: 12) {
        Image(systemName: icon)
          .font(.system(size: 16))
          .foregroundStyle(isDestructive ? .red : themeManager.textSecondary)
          .frame(width: 24)

        Text(title)
          .font(EverFont.bodySecondary)
          .foregroundStyle(isDestructive ? .red : themeManager.textPrimary)

        Spacer()
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 10)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityLabel("\(title), button")
  }
}
