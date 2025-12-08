import SwiftUI

struct TodayPlanSheet: View {
    let onStartWorkout: () -> Void
    let onClose: () -> Void
    
    var body: some View {
        EFScreenContainer {
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text("Today's Training")
                        .font(EverFormTheme.Typography.sectionTitle)
                        .foregroundColor(EverFormTheme.Colors.textPrimary)
                    Spacer()
                }
                .overlay(
                    Button("Close", action: onClose)
                        .font(EverFormTheme.Typography.button)
                        .foregroundColor(EverFormTheme.Colors.textSecondary),
                    alignment: .trailing
                )
                .padding(20)
                .background(EverFormTheme.Colors.background)
                
                ScrollView {
                    VStack(spacing: 24) {
                        EFCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Upper Power")
                                    .font(EverFormTheme.Typography.cardTitle)
                                    .foregroundStyle(EverFormTheme.Colors.textPrimary)
                                
                                Text("Duration: 75 minutes")
                                    .font(EverFormTheme.Typography.body)
                                    .foregroundStyle(EverFormTheme.Colors.textSecondary)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Main Exercises:")
                                        .font(EverFormTheme.Typography.cardTitle)
                                        .foregroundStyle(EverFormTheme.Colors.textPrimary)
                                    Text("• Bench Press")
                                    Text("• Pull-ups")
                                    Text("• Overhead Press")
                                }
                                .font(EverFormTheme.Typography.body)
                                .foregroundStyle(EverFormTheme.Colors.textSecondary)
                            }
                        }
                        
                        EFPrimaryButton("Start Workout", color: EverFormTheme.Colors.trainingGreen) {
                            onStartWorkout()
                        }
                    }
                    .padding(20)
                }
            }
        }
    }
}
