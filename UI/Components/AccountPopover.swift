import SwiftUI

struct AccountPopover: View {
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Theme.Colors.accent.opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(Theme.Colors.accent)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Alex Chen")
                        .font(.headline)
                        .foregroundColor(Theme.Colors.textPrimary)
                    Text("alex@example.com")
                        .font(.subheadline)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
            }
            .padding(16)

            Divider()
                .background(Theme.Colors.border)

            MenuRow(icon: "person.circle", title: "Profile", trailing: EmptyView())
            MenuRow(icon: "paintbrush", title: "Display", trailing: Text(currentThemeLabel()).foregroundStyle(Theme.Colors.textSecondary))
            MenuRow(icon: "lock", title: "Security", trailing: EmptyView())
            MenuRow(icon: "square.and.arrow.down", title: "Export Data", trailing: EmptyView())
            MenuRow(icon: "questionmark.circle", title: "Help", trailing: EmptyView())
            MenuRow(icon: "ladybug", title: "Report a Bug", trailing: EmptyView())
        }
        .background(Theme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Theme.Colors.border))
        .padding(.vertical, 4)
        .frame(maxWidth: 320)
    }

    private func currentThemeLabel() -> String {
        themeManager.selectedTheme.displayName
    }
}

private struct MenuRow<Trailing: View>: View {
    let icon: String
    let title: String
    var trailing: Trailing
    
    init(icon: String, title: String, trailing: Trailing = EmptyView() as! Trailing) {
        self.icon = icon
        self.title = title
        self.trailing = trailing
    }
    
    var body: some View {
        Button(action: {
            // Handle menu item tap
        }) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 22)
                    .foregroundStyle(Theme.Colors.textSecondary)

                Text(title)
                    .foregroundColor(Theme.Colors.textPrimary)

                Spacer()

                trailing

                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.Colors.textSecondary.opacity(0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}
