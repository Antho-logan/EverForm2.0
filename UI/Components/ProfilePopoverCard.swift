//
//  ProfilePopoverCard.swift
//  EverForm
//
//  Compact profile popover card anchored to avatar button
//

import SwiftUI

struct ProfilePopoverCard: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ThemeManager.self) private var themeManager
    @State private var showingDisplaySettings = false
    
    var body: some View {
        let palette = Theme.palette(colorScheme)
        
        VStack(spacing: 0) {
            // Arrow pointing to avatar
            HStack {
                Triangle()
                    .fill(palette.surfaceElevated)
                    .frame(width: 12, height: 8)
                    .offset(x: 20, y: -1)
                Spacer()
            }
            
            // Main card content
            VStack(spacing: 0) {
                // User info header
                VStack(spacing: Theme.Spacing.xs) {
                    HStack {
                        Circle()
                            .fill(palette.accent.opacity(0.2))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(palette.accent)
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Alex Chen")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(palette.textPrimary)
                            
                            Text("alex@example.com")
                                .font(.system(size: 12, weight: .regular))
                                .foregroundStyle(palette.textSecondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.sm)
                }
                
                Divider()
                    .background(palette.stroke)
                
                // Menu items
                VStack(spacing: 0) {
                    PopoverMenuRow(
                        icon: "person.circle",
                        title: "Profile",
                        action: {
                            // Navigate to profile
                        }
                    )
                    
                    PopoverMenuRow(
                        icon: "paintbrush",
                        title: "Display",
                        trailing: {
                            Text(themeManager.selectedTheme.displayName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(palette.textSecondary)
                        },
                        action: {
                            showingDisplaySettings = true
                        }
                    )
                    
                    PopoverMenuRow(
                        icon: "lock.shield",
                        title: "Security",
                        action: {
                            // Navigate to security
                        }
                    )
                    
                    PopoverMenuRow(
                        icon: "square.and.arrow.up",
                        title: "Export Data",
                        action: {
                            // Export data
                        }
                    )
                    
                    PopoverMenuRow(
                        icon: "questionmark.circle",
                        title: "Help",
                        action: {
                            // Open help
                        }
                    )
                    
                    PopoverMenuRow(
                        icon: "exclamationmark.triangle",
                        title: "Report a Bug",
                        action: {
                            // Report bug
                        }
                    )
                }
            }
            .background(palette.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
        }
        .frame(width: 240)
        .sheet(isPresented: $showingDisplaySettings) {
            DisplaySettingsSheet()
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Supporting Components

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct PopoverMenuRow<Trailing: View>: View {
    let icon: String
    let title: String
    let trailing: (() -> Trailing)?
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(icon: String, title: String, action: @escaping () -> Void) where Trailing == EmptyView {
        self.icon = icon
        self.title = title
        self.trailing = nil
        self.action = action
    }
    
    init(icon: String, title: String, @ViewBuilder trailing: @escaping () -> Trailing, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.trailing = trailing
        self.action = action
    }
    
    var body: some View {
        let palette = Theme.palette(colorScheme)
        
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(palette.textSecondary)
                    .frame(width: 20, height: 20)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(palette.textPrimary)
                
                Spacer()
                
                if let trailing = trailing {
                    trailing()
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct DisplaySettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        let palette = Theme.palette(colorScheme)
        
        NavigationView {
            VStack(spacing: Theme.Spacing.lg) {
                VStack(spacing: Theme.Spacing.sm) {
                    ForEach(ThemeManager.ThemeMode.allCases, id: \.self) { mode in
                        Button(action: {
                            themeManager.setTheme(mode)
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                        }) {
                            HStack {
                                Text(mode.displayName)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(palette.textPrimary)

                                Spacer()

                                if themeManager.selectedTheme == mode {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(palette.accent)
                                }
                            }
                            .padding(.horizontal, Theme.Spacing.lg)
                            .padding(.vertical, Theme.Spacing.md)
                            .background(
                                themeManager.selectedTheme == mode ?
                                palette.accent.opacity(0.1) :
                                Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer()
            }
            .padding(Theme.Spacing.lg)
            .background(palette.background)
            .navigationTitle("Display")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(palette.accent)
                }
            }
        }
    }
}

#Preview {
    ProfilePopoverCard()
        .environment(ThemeManager())
}
