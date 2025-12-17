//
//  FixPainDesignSystem.swift
//  EverForm
//
//  Created by Assistant on 19/11/2025.
//  Updated for Global Theme Integration
//

import SwiftUI

// MARK: - Reusable Components

struct FixPainPrimaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(EverFormTheme.Fonts.buttonText())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    isDisabled ? EverFormTheme.Colors.neutral400 : EverFormTheme.Colors.fixPainIndigo
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: isDisabled ? .clear : EverFormTheme.Colors.fixPainIndigo.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .disabled(isDisabled)
        .scaleEffect(isDisabled ? 1.0 : 1.0)
        .animation(.spring(response: 0.3), value: isDisabled)
    }
}

struct FixPainSecondaryButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(EverFormTheme.Typography.body)
                .foregroundStyle(EverFormTheme.Colors.textSecondary)
                .frame(height: 44)
        }
    }
}

// FixPainChip removed - defined in FixPainAssessmentView.swift to allow specific view-local customizations

struct FixPainStepHeader: View {
    let step: Int
    let totalSteps: Int
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Progress Label
            HStack {
                Text("STEP \(step) OF \(totalSteps)")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(EverFormTheme.Colors.fixPainIndigo)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(EverFormTheme.Colors.fixPainIndigo.opacity(0.1))
                    .clipShape(Capsule())
                Spacer()
            }
            
            Text(title)
                .sectionTitle()
                .fixedSize(horizontal: false, vertical: true)
            
            Text(subtitle)
                .font(EverFormTheme.Typography.body)
                .foregroundStyle(EverFormTheme.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
        .screenPadding()
        .padding(.bottom, 10)
    }
}

struct FixPainProgressBar: View {
    let progress: Double // 0.0 to 1.0
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(EverFormTheme.Colors.textSecondary.opacity(0.1))
                    .frame(height: 4)
                
                Capsule()
                    .fill(EverFormTheme.Colors.fixPainIndigo)
                    .frame(width: geo.size.width * progress, height: 4)
                    .animation(.smooth(duration: 0.5), value: progress)
            }
        }
        .frame(height: 4)
    }
}

struct FixPainToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(EverFormTheme.Typography.body)
                .foregroundStyle(EverFormTheme.Colors.textPrimary)
        }
        .toggleStyle(SwitchToggleStyle(tint: EverFormTheme.Colors.fixPainIndigo))
        .padding()
        .cardStyle()
    }
}
