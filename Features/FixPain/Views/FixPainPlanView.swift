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
                            .font(DesignSystem.Typography.heading().weight(.bold))
                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                        
                        Text(plan.summaryBody)
                            .font(DesignSystem.Typography.bodyMedium())
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
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
                                .font(DesignSystem.Typography.heading())
                                .foregroundStyle(DesignSystem.Colors.textPrimary)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(plan.safetyNotes, id: \.self) { note in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "exclamationmark.shield.fill")
                                            .foregroundStyle(Color.orange)
                                            .font(.caption)
                                            .padding(.top, 2)
                                        
                                        Text(note)
                                            .font(DesignSystem.Typography.bodySmall())
                                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(DesignSystem.Colors.neutral50)
                            )
                        }
                    }
                    
                    // Disclaimer
                    Text(plan.disclaimer.isEmpty ? "This information is for educational purposes only and not medical advice. Always consult with a qualified healthcare provider for proper diagnosis and treatment." : plan.disclaimer)
                        .font(DesignSystem.Typography.caption())
                        .foregroundStyle(DesignSystem.Colors.textTertiary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 8)

                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 32)
                .offset(y: appeared ? 0 : 40)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: appeared)
            }
            .background(DesignSystem.Colors.background.ignoresSafeArea())
            .navigationTitle("Recovery Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(DesignSystem.Typography.buttonMedium())
                }
            }
        }
        .onAppear { appeared = true }
    }
    
    private var doctorBanner: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title2)
                .foregroundStyle(.red)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(plan.doctorBannerTitle ?? "Consider seeing a clinician")
                    .font(DesignSystem.Typography.heading())
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                
                Text(plan.doctorBannerBody ?? "Your answers suggest possible red flags. Please seek medical evaluation.")
                    .font(DesignSystem.Typography.bodyMedium())
                    .foregroundStyle(DesignSystem.Colors.textPrimary.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.red.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.red.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Subcomponents

struct FixPainPlanSectionCard<Content: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(DesignSystem.Typography.heading())
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                
                if let subtitle {
                    Text(subtitle)
                        .font(DesignSystem.Typography.bodyMedium())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
            }
            
            content
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(DesignSystem.Colors.cardBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
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
                    .foregroundStyle(DesignSystem.Colors.accent)
                    .frame(width: 24, height: 24)
                    .background(DesignSystem.Colors.accent.opacity(0.1))
                    .clipShape(Circle())
            } else {
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundStyle(DesignSystem.Colors.accent)
                    .padding(.top, 8)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.title)
                        .font(DesignSystem.Typography.bodyMedium().weight(.semibold))
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    if let minutes = item.durationMinutes {
                        Spacer()
                        Text("\(minutes) min")
                            .font(DesignSystem.Typography.labelSmall())
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(DesignSystem.Colors.neutral100)
                            .clipShape(Capsule())
                    }
                }
                
                Text(item.description)
                    .font(DesignSystem.Typography.bodySmall())
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
        }
    }
}
