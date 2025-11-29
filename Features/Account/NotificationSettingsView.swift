import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    
    @State private var pushEnabled = true
    @State private var emailEnabled = true
    @State private var trainingReminders = true
    @State private var hydrationReminders = false
    @State private var sleepReminders = true
    
    var body: some View {
        EFScreenContainer {
            VStack(spacing: 0) {
                EFHeader(title: "Notifications", showBack: true)
                
                ScrollView {
                    VStack(spacing: 20) {
                        EFCard {
                            VStack(spacing: 20) {
                                ToggleRow(title: "Push Notifications", isOn: $pushEnabled)
                                ToggleRow(title: "Email Summaries", isOn: $emailEnabled)
                            }
                        }
                        
                        Text("Categories")
                            .font(EverFont.sectionTitle)
                            .foregroundStyle(themeManager.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 12)
                        
                        EFCard {
                            VStack(spacing: 20) {
                                ToggleRow(title: "Training Reminders", isOn: $trainingReminders)
                                ToggleRow(title: "Hydration Alerts", isOn: $hydrationReminders)
                                ToggleRow(title: "Sleep Routine", isOn: $sleepReminders)
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
    }
    
    @ViewBuilder
    private func ToggleRow(title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(EverFont.body)
                .foregroundStyle(themeManager.textPrimary)
        }
        .tint(DesignSystem.Colors.accent)
    }
}

