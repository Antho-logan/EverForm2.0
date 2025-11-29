import SwiftUI

struct ConnectedDevicesDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        EFScreenContainer {
            VStack(spacing: 0) {
                EFHeader(title: "Connected Devices", showBack: true)
                
                ScrollView {
                    VStack(spacing: 16) {
                        DeviceRow(name: "Apple Health", icon: "heart.fill", isConnected: true)
                        DeviceRow(name: "Oura Ring", icon: "circle.dashed", isConnected: false)
                        DeviceRow(name: "Whoop", icon: "w.circle", isConnected: false)
                        DeviceRow(name: "Garmin", icon: "watchface.applewatch.case", isConnected: false)
                    }
                    .padding(20)
                }
            }
        }
    }
    
    @ViewBuilder
    private func DeviceRow(name: String, icon: String, isConnected: Bool) -> some View {
        EFCard {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(isConnected ? .green : themeManager.textSecondary)
                    .frame(width: 32)
                
                Text(name)
                    .font(EverFont.body)
                    .foregroundStyle(themeManager.textPrimary)
                
                Spacer()
                
                Button(isConnected ? "Connected" : "Connect") { }
                    .font(EverFont.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(isConnected ? Color.green.opacity(0.1) : themeManager.backgroundSecondary)
                    .foregroundStyle(isConnected ? .green : themeManager.textPrimary)
                    .clipShape(Capsule())
            }
        }
    }
}

