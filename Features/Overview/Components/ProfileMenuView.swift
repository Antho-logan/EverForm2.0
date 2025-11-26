
import SwiftUI

struct ProfileMenuView: View {
    @Binding var isPresented: Bool
    @State private var selectedAppearance: String = "System" // Placeholder state
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with Avatar
            HStack(spacing: 12) {
                Circle()
                    .fill(DesignSystem.Colors.backgroundSecondary)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text("AL")
                            .font(.headline)
                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Anthony Logan")
                        .font(.headline)
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    Text("anthonylogan1995@gmail.com")
                        .font(.caption)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
            }
            .padding(16)
            
            Divider()
                .background(DesignSystem.Colors.border)
            
            // Menu Items
            VStack(spacing: 4) {
                MenuButton(icon: "person", title: "Account")
                
                // Appearance Toggle
                HStack {
                    Image(systemName: "sun.max")
                        .font(.system(size: 16))
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .frame(width: 24)
                    
                    Text("Appearance")
                        .font(.subheadline)
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    Spacer()
                    
                    Picker("Appearance", selection: $selectedAppearance) {
                        Text("System").tag("System")
                        Text("Light").tag("Light")
                        Text("Dark").tag("Dark")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 180)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                
                MenuButton(icon: "bell", title: "Notifications")
                MenuButton(icon: "lock", title: "Privacy & Security")
                MenuButton(icon: "questionmark.circle", title: "Help & Support")
                MenuButton(icon: "rectangle.portrait.and.arrow.right", title: "Sign Out", isDestructive: true)
            }
            .padding(8)
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
    private func MenuButton(icon: String, title: String, isDestructive: Bool = false) -> some View {
        Button {
            // Action placeholder
            print("Tapped \(title)")
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(isDestructive ? .red : DesignSystem.Colors.textSecondary)
                    .frame(width: 24)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(isDestructive ? .red : DesignSystem.Colors.textPrimary)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.primary.opacity(0.001)) // Hit testing
        }
        .buttonStyle(.plain)
    }
}

