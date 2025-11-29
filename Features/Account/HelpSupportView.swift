import SwiftUI

struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        EFScreenContainer {
            VStack(spacing: 0) {
                EFHeader(title: "Help & Support", showBack: true)
                
                ScrollView {
                    VStack(spacing: 20) {
                        EFCard {
                            VStack(spacing: 16) {
                                LinkRow(icon: "book", title: "Read FAQ")
                                Divider()
                                LinkRow(icon: "envelope", title: "Contact Support")
                                Divider()
                                LinkRow(icon: "star", title: "Rate the App")
                            }
                        }
                        
                        Text("Version 2.0.1 (Build 142)")
                            .font(EverFont.caption)
                            .foregroundStyle(themeManager.textSecondary)
                            .padding(.top, 20)
                    }
                    .padding(20)
                }
            }
        }
    }
    
    @ViewBuilder
    private func LinkRow(icon: String, title: String) -> some View {
        Button(action: {}) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24)
                    .foregroundStyle(DesignSystem.Colors.accent)
                Text(title)
                    .font(EverFont.body)
                    .foregroundStyle(themeManager.textPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(themeManager.textSecondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

