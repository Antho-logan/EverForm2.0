import SwiftUI

struct WorkoutRunnerView: View {
    let onFinish: () -> Void
    let onDiscard: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        EFScreenContainer {
            VStack(spacing: 0) {
                EFHeader(title: "Workout", showBack: false)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Info Card
                        EFCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Upper Power Workout")
                                    .font(EverFormTheme.Typography.cardTitle)
                                    .foregroundStyle(EverFormTheme.Colors.textPrimary)
                                
                                Text("Focus on form and tempo.")
                                    .font(EverFormTheme.Typography.body)
                                    .foregroundStyle(EverFormTheme.Colors.textSecondary)
                            }
                        }
                        
                        // Active Exercise Card
                        EFCard(style: .tinted(EverFormTheme.Colors.trainingGreen)) {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text("Exercise 1")
                                        .font(EverFormTheme.Typography.label)
                                        .foregroundStyle(EverFormTheme.Colors.trainingGreen)
                                    Spacer()
                                    Text("Set 1 of 3")
                                        .font(EverFormTheme.Typography.label)
                                        .foregroundStyle(EverFormTheme.Colors.textSecondary)
                                }
                                
                                Text("Bench Press")
                                    .font(EverFormTheme.Typography.screenTitle)
                                    .foregroundStyle(EverFormTheme.Colors.textPrimary)
                                
                                HStack(spacing: 16) {
                                    EFPrimaryButton("Log Set", color: EverFormTheme.Colors.trainingGreen) {
                                        // Log logic
                                    }
                                    
                                    EFSecondaryButton("Skip Set") {
                                        // Skip logic
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 40)
                        
                        // Footer Actions
                        HStack(spacing: 16) {
                            EFSecondaryButton("Discard") {
                                onDiscard()
                            }
                            
                            EFPrimaryButton("Finish Workout") {
                                onFinish()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
