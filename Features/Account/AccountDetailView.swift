import SwiftUI

struct AccountDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    
    @State private var fullName = "Anthony Logan"
    @State private var email = "anthonylogan1995@gmail.com"
    @State private var dateOfBirth = Date()
    @State private var height = "180"
    @State private var weight = "75"
    
    var body: some View {
        EFScreenContainer {
            VStack(spacing: 0) {
                EFHeader(title: "Account", showBack: true)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Image
                        VStack(spacing: 12) {
                            Circle()
                                .fill(themeManager.backgroundSecondary)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Text("AL")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundStyle(themeManager.textPrimary)
                                )
                            
                            Button("Edit Photo") { }
                                .font(EverFont.bodySecondary)
                                .foregroundStyle(DesignSystem.Colors.accent)
                        }
                        .padding(.top, 12)
                        
                        // Fields
                        EFCard {
                            VStack(spacing: 20) {
                                LabeledField(label: "Full Name", text: $fullName)
                                LabeledField(label: "Email", text: $email)
                                LabeledField(label: "Height (cm)", text: $height)
                                LabeledField(label: "Weight (kg)", text: $weight)
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
    }
    
    @ViewBuilder
    private func LabeledField(label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(EverFont.caption)
                .foregroundStyle(themeManager.textSecondary)
            
            TextField("", text: text)
                .font(EverFont.body)
                .foregroundStyle(themeManager.textPrimary)
                .padding(12)
                .background(themeManager.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

