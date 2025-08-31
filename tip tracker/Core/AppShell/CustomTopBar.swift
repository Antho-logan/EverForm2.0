//
// CustomTopBar.swift
// EverForm
//
// Custom top bar for dashboard with greeting and settings button
// Assumptions: Fixed height, settings gear icon, dynamic greeting
//

import SwiftUI

struct CustomTopBar: View {
    let firstName: String
    let onSettingsTap: () -> Void
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon" 
        case 17..<22:
            return "Good evening"
        default:
            return "Good night"
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            // Greeting Section
            VStack(alignment: .leading, spacing: 4) {
                Text("\(greeting), \(firstName)")
                    .font(DesignSystem.Typography.titleLarge())
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text(dateString)
                    .font(DesignSystem.Typography.bodyMedium())
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
            
            // Settings Button
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                
                DebugLog.d("Settings button tapped from top bar")
                TelemetryService.shared.track("settings_open_from_topbar")
                
                onSettingsTap()
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")
        }
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
        .padding(.vertical, DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.background)
    }
}

#Preview {
    CustomTopBar(
        firstName: "Alex",
        onSettingsTap: {
            print("Settings tapped")
        }
    )
}

