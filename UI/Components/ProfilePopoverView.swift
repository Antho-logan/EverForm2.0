//
//  ProfilePopoverView.swift
//  EverForm
//
//  Profile popover from top-left avatar with account settings
//

import SwiftUI

struct ProfilePopoverView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ThemeManager.self) private var themeManager
    @State private var showingDisplaySettings = false
    
    var body: some View {
        let palette = Theme.palette(colorScheme)
        
        NavigationView {
            VStack(spacing: 0) {
                // Account header
                VStack(spacing: Theme.Spacing.sm) {
                    Circle()
                        .fill(palette.accent.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(palette.accent)
                        )
                    
                    VStack(spacing: 4) {
                        Text("Alex Thompson")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(palette.textPrimary)
                        
                        Text("alex@example.com")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(palette.textSecondary)
                    }
                }
                .padding(.vertical, Theme.Spacing.lg)
                
                Divider()
                    .background(palette.stroke)
                
                // Menu items
                VStack(spacing: 0) {
                    MenuRow(
                        icon: "person.circle",
                        title: "Profile",
                        action: {
                            dismiss()
                            // Navigate to profile
                        }
                    )
                    
                    MenuRow(
                        icon: "paintbrush",
                        title: "Display",
                        trailing: {
                            Text(themeManager.selectedTheme.displayName)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(palette.textSecondary)
                        },
                        action: {
                            showingDisplaySettings = true
                        }
                    )
                    
                    MenuRow(
                        icon: "lock.shield",
                        title: "Security",
                        action: {
                            dismiss()
                            // Navigate to security
                        }
                    )
                    
                    MenuRow(
                        icon: "square.and.arrow.up",
                        title: "Export Data",
                        action: {
                            dismiss()
                            // Export data
                        }
                    )
                    
                    MenuRow(
                        icon: "questionmark.circle",
                        title: "Help",
                        action: {
                            dismiss()
                            // Open help
                        }
                    )
                    
                    MenuRow(
                        icon: "exclamationmark.triangle",
                        title: "Report a Bug",
                        action: {
                            dismiss()
                            // Report bug
                        }
                    )
                    
                    Divider()
                        .background(palette.stroke)
                        .padding(.vertical, Theme.Spacing.xs)
                    
                    MenuRow(
                        icon: "rectangle.portrait.and.arrow.right",
                        title: "Logout",
                        titleColor: .red,
                        action: {
                            dismiss()
                            // Logout
                        }
                    )
                }
                
                Spacer()
            }
            .background(palette.surfaceElevated)
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(palette.accent)
                }
            }
        }
        .sheet(isPresented: $showingDisplaySettings) {
            DisplaySettingsView()
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Menu Row Component

private struct MenuRow<Trailing: View>: View {
    let icon: String
    let title: String
    let titleColor: Color?
    let trailing: () -> Trailing
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(
        icon: String,
        title: String,
        titleColor: Color? = nil,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() },
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.titleColor = titleColor
        self.trailing = trailing
        self.action = action
    }
    
    var body: some View {
        let palette = Theme.palette(colorScheme)
        
        Button(action: action) {
            HStack(spacing: Theme.Spacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(titleColor ?? palette.textPrimary)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(titleColor ?? palette.textPrimary)
                
                Spacer()
                
                trailing()
                
                if Trailing.self == EmptyView.self {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(palette.textSecondary)
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.sm)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}



#Preview {
    ProfilePopoverView()
        .environment(ThemeManager())
}
