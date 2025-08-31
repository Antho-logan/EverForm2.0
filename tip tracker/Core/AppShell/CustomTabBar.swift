//
// CustomTabBar.swift  
// EverForm
//
// Bottom bar with THREE evenly spaced tab buttons (no center gap)
// Assumptions: 60pt height, ultraThinMaterial, three tabs
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    let onTabTap: (Tab) -> Void
    
    // Layout constants
    private let barHeight: CGFloat = 60
    
    var body: some View {
        HStack(spacing: 0) {
            // Three evenly spaced tabs
            tabButton(for: .overview)
            tabButton(for: .coach)
            tabButton(for: .scan)
        }
        .frame(height: barHeight)
        .background(.ultraThinMaterial)
        .overlay(
            // Top border
            Rectangle()
                .fill(DesignSystem.Colors.border.opacity(0.3))
                .frame(height: 0.5),
            alignment: .top
        )
    }
    
    // MARK: - Tab Button
    private func tabButton(for tab: Tab) -> some View {
        Button(action: {
            handleTabTap(tab)
        }) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 22, weight: selectedTab == tab ? .semibold : .medium))
                    .foregroundColor(selectedTab == tab ? DesignSystem.Colors.accent : DesignSystem.Colors.textSecondary)
                
                Text(tab.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(selectedTab == tab ? DesignSystem.Colors.accent : DesignSystem.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: barHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(tab.accessibilityLabel))
    }
    
    // MARK: - Actions
    private func handleTabTap(_ tab: Tab) {
        let impact = UIImpactFeedbackGenerator(style: .soft)
        impact.impactOccurred()
        
        DebugLog.d("Tab tapped: \(tab.rawValue)")
        TelemetryService.shared.track("tab_switch_\(tab.rawValue)")
        
        onTabTap(tab)
    }
}