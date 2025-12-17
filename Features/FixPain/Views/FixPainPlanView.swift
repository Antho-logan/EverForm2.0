//
//  FixPainPlanView.swift
//  EverForm
//
//  Created by Assistant on 07/12/2025.
//

import SwiftUI

struct FixPainPlanView: View {
    let plan: PainAiPlanDTO

    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false

    var body: some View {
        NavigationStack {
            EFScreenContainer {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // 1) Doctor Banner
                        if plan.showDoctorBanner || plan.triageLevel == .seeDoctorSoon {
                            doctorBanner
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        // 2) Summary Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text(plan.summaryTitle)
                                .font(EverFormTheme.Typography.screenTitle)
                                .foregroundStyle(EverFormTheme.Colors.textPrimary)
                            
                            Text(plan.summaryBody)
                                .font(EverFormTheme.Typography.body)
                                .foregroundStyle(EverFormTheme.Colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.bottom, 8)

                        // 3) Warmup & Mobility
                        if !plan.warmupAndMobility.isEmpty {
                            FixPainPlanSectionCard(
                                title: "Warmup & Mobility",
                                subtitle: "Get moving safely"
                            ) {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(plan.warmupAndMobility) { item in
                                        FixPainPlanItemRow(item: item)
                                        if item.id != plan.warmupAndMobility.last?.id {
                                            Divider()
                                                .padding(.leading, 20)
                                        }
                                    }
                                }
                            }
                        }

                        // 4) Strength & Activation
                        if !plan.strengthAndActivation.isEmpty {
                            FixPainPlanSectionCard(
                                title: "Strength & Activation",
                                subtitle: "Build resilience"
                            ) {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(plan.strengthAndActivation) { item in
                                        FixPainPlanItemRow(item: item)
                                        if item.id != plan.strengthAndActivation.last?.id {
                                            Divider()
                                                .padding(.leading, 20)
                                        }
                                    }
                                }
                            }
                        }

                        // 5) Recovery Advice
                        if !plan.recoveryAdvice.isEmpty {
                            FixPainPlanSectionCard(
                                title: "Recovery Advice",
                                subtitle: "Lifestyle & care"
                            ) {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(plan.recoveryAdvice) { item in
                                        FixPainPlanItemRow(item: item)
                                        if item.id != plan.recoveryAdvice.last?.id {
                                            Divider()
                                                .padding(.leading, 20)
                                        }
                                    }
                                }
                            }
                        }

                        // 6) Safety Notes
                        if !plan.safetyNotes.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Safety Notes")
                                    .sectionTitle()
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(plan.safetyNotes, id: \.self) { note in
                                        HStack(alignment: .top, spacing: 8) {
                                            Image(systemName: "exclamationmark.shield.fill")
                                                .foregroundStyle(EverFormTheme.Colors.warningAmber)
                                                .font(.caption)
                                                .padding(.top, 2)
                                            
                                            Text(note)
                                                .font(EverFormTheme.Typography.caption)
                                                .foregroundStyle(EverFormTheme.Colors.textSecondary)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(EverFormTheme.Colors.surface)
                                )
                            }
                        }
                        
                        // Disclaimer
                        Text(plan.disclaimer.isEmpty ? "This information is for educational purposes only and not medical advice. Always consult with a qualified healthcare provider for proper diagnosis and treatment." : plan.disclaimer)
                            .font(EverFormTheme.Typography.caption)
                            .foregroundStyle(EverFormTheme.Colors.textSecondary.opacity(0.7))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 8)

                    }
                    .screenPadding()
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                    .offset(y: appeared ? 0 : 40)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: appeared)
                }
            }
            .navigationTitle("Recovery Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(EverFormTheme.Typography.button)
                }
            }
        }
        .onAppear { appeared = true }
    }
    
    private var doctorBanner: some View {
        EverFormCard {
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                    .foregroundStyle(EverFormTheme.Colors.dangerText)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.doctorBannerTitle ?? "Consider seeing a clinician")
                        .font(EverFormTheme.Typography.cardTitle)
                        .foregroundStyle(EverFormTheme.Colors.textPrimary)
                    
                    Text(plan.doctorBannerBody ?? "Your answers suggest possible red flags. Please seek medical evaluation.")
                        .font(EverFormTheme.Typography.body)
                        .foregroundStyle(EverFormTheme.Colors.textPrimary.opacity(0.8))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .background(EverFormTheme.Colors.dangerBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(EverFormTheme.Colors.dangerText.opacity(0.25), lineWidth: 1)
        )
    }
}

// MARK: - Subcomponents

struct FixPainPlanSectionCard<Content: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder let content: Content

    var body: some View {
        EverFormCard {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .sectionTitle()
                    
                    if let subtitle {
                        Text(subtitle)
                            .font(EverFormTheme.Typography.body)
                            .foregroundStyle(EverFormTheme.Colors.textSecondary)
                    }
                }
                
                content
            }
        }
    }
}

struct FixPainPlanItemRow: View {
    let item: PainAiSectionItemDTO

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon or Bullet
            if let iconKey = item.iconKey, !iconKey.isEmpty {
                // If we had an icon mapping, we'd use it. For now, use SF Symbol based on key or default
                Image(systemName: "figure.run") // Placeholder, ideally mapped from iconKey
                    .font(.system(size: 14))
                    .foregroundStyle(EverFormTheme.Colors.fixPainIndigo)
                    .frame(width: 24, height: 24)
                    .background(EverFormTheme.Colors.fixPainIndigo.opacity(0.1))
                    .clipShape(Circle())
            } else {
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundStyle(EverFormTheme.Colors.fixPainIndigo)
                    .padding(.top, 8)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.title)
                        .font(EverFormTheme.Typography.body.weight(.semibold))
                        .foregroundStyle(EverFormTheme.Colors.textPrimary)
                    
                    if let minutes = item.durationMinutes {
                        Spacer()
                        Text("\(minutes) min")
                            .font(EverFormTheme.Typography.caption)
                            .foregroundStyle(EverFormTheme.Colors.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(AppTheme.Colors.surfaceSecondary)
                            .clipShape(Capsule())
                    }
                }
                
                Text(item.description)
                    .font(EverFormTheme.Typography.caption)
                    .foregroundStyle(EverFormTheme.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
        }
    }
}
