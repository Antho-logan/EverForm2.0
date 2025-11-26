import SwiftUI

struct ConnectedDevicesView: View {
    @State private var healthManager = HealthKitManager.shared
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        EFScreenContainer {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Text("Connected Devices")
                        .font(DesignSystem.Typography.displaySmall())
                        .foregroundStyle(themeManager.textPrimary)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(themeManager.textSecondary)
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 20)

                ScrollView {
                    VStack(spacing: 16) {
                        // Apple Health
                        ConnectedDeviceRow(
                            icon: "heart.fill",
                            title: "Apple Health",
                            description: "Sync steps, sleep, and activity data to EverForm.",
                            isConnected: healthManager.isHealthConnected,
                            isAvailable: healthManager.isHealthDataAvailable
                        ) {
                            if healthManager.isHealthConnected {
                                healthManager.disconnect()
                            } else {
                                Task {
                                    await healthManager.requestAuthorization()
                                }
                            }
                        }
                        
                        // Apple Watch
                        ConnectedDeviceRow(
                            icon: "applewatch",
                            title: "Apple Watch",
                            description: healthManager.isHealthConnected ? "Connected via Apple Health" : "Connect via Apple Health to sync workouts.",
                            isConnected: healthManager.isHealthConnected,
                            isAvailable: healthManager.isHealthDataAvailable
                        ) {
                            // Treating Watch as implicitly connected via Health for now
                            if !healthManager.isHealthConnected {
                                Task {
                                    await healthManager.requestAuthorization()
                                }
                            }
                        }
                        .disabled(healthManager.isHealthConnected)
                        .opacity(healthManager.isHealthConnected ? 0.8 : 1.0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

