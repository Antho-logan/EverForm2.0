import SwiftUI

struct PrivacySecurityView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        EFScreenContainer {
            VStack(spacing: 0) {
                EFHeader(title: "Privacy & Security", showBack: true)
                
                ScrollView {
                    VStack(spacing: 24) {
                        EFCard {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "lock.shield")
                                        .foregroundStyle(DesignSystem.Colors.accent)
                                    Text("Data Privacy")
                                        .font(EverFont.cardTitle)
                                        .foregroundStyle(themeManager.textPrimary)
                                }
                                
                                Text("Your data is encrypted and stored securely. We verify all third-party integrations to ensure compliance with strict privacy standards.")
                                    .font(EverFont.bodySecondary)
                                    .foregroundStyle(themeManager.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        EFCard {
                            VStack(spacing: 0) {
                                Button(action: {}) {
                                    HStack {
                                        Text("Export All Data")
                                            .foregroundStyle(themeManager.textPrimary)
                                        Spacer()
                                        Image(systemName: "square.and.arrow.up")
                                    }
                                    .padding(.vertical, 12)
                                }
                                .buttonStyle(.plain)
                                
                                Divider()
                                
                                Button(action: {}) {
                                    HStack {
                                        Text("Delete Account")
                                            .foregroundStyle(.red)
                                        Spacer()
                                        Image(systemName: "trash")
                                            .foregroundStyle(.red)
                                    }
                                    .padding(.vertical, 12)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
    }
}

