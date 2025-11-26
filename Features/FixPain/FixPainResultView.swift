//
//  FixPainResultView.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import SwiftUI

struct FixPainResultView: View {
    let plan: FixPainPlan
    @Binding var isPresented: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Recovery Plan")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(FixPainTheme.textPrimary)
                    
                    Text("Generated based on your symptoms")
                        .font(.subheadline)
                        .foregroundStyle(FixPainTheme.textSecondary)
                }
                .padding(.top, 30)
                .padding(.horizontal, FixPainTheme.paddingLarge)
                
                // Risk Assessment
                RiskCard(riskLevel: plan.riskLevel, explanation: plan.explanation)
                    .padding(.horizontal, FixPainTheme.paddingLarge)
                
                // Exercises Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Warmup & Mobility")
                        .font(.headline)
                        .padding(.horizontal, FixPainTheme.paddingLarge)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(plan.warmupAndMobility) { exercise in
                                FixPainExerciseCard(exercise: exercise)
                            }
                        }
                        .padding(.horizontal, FixPainTheme.paddingLarge)
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Strength & Activation")
                        .font(.headline)
                        .padding(.horizontal, FixPainTheme.paddingLarge)
                    
                    VStack(spacing: 12) {
                        ForEach(plan.strengthAndActivation) { exercise in
                            FixPainExerciseRow(exercise: exercise)
                        }
                    }
                    .padding(.horizontal, FixPainTheme.paddingLarge)
                }
                
                // Recovery Advice
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recovery Advice")
                        .font(.headline)
                        .padding(.horizontal, FixPainTheme.paddingLarge)
                    
                    VStack(spacing: 12) {
                        ForEach(plan.recoveryAdvice) { advice in
                            HStack(alignment: .top, spacing: 16) {
                                Image(systemName: advice.icon)
                                    .font(.title2)
                                    .foregroundStyle(FixPainTheme.primary)
                                    .frame(width: 32)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(advice.title)
                                        .font(.system(size: 16, weight: .semibold))
                                    Text(advice.description)
                                        .font(.system(size: 14))
                                        .foregroundStyle(FixPainTheme.textSecondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(FixPainTheme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.horizontal, FixPainTheme.paddingLarge)
                }
                
                // Done Button
                FixPainPrimaryButton(title: "Done") {
                    isPresented = false
                }
                .padding(FixPainTheme.paddingLarge)
                .padding(.bottom, 20)
            }
        }
        .background(FixPainTheme.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}

struct RiskCard: View {
    let riskLevel: RiskLevel
    let explanation: String
    
    var riskColor: Color {
        switch riskLevel {
        case .selfCareOk: return .green
        case .caution: return .orange
        case .seeDoctorASAP: return .red
        }
    }
    
    var riskTitle: String {
        switch riskLevel {
        case .selfCareOk: return "Safe for Self-Care"
        case .caution: return "Proceed with Caution"
        case .seeDoctorASAP: return "See a Doctor"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: riskLevel == .selfCareOk ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(riskColor)
                Text(riskTitle)
                    .font(.headline)
                    .foregroundStyle(riskColor)
            }
            
            Text(explanation)
                .font(.system(size: 15))
                .foregroundStyle(FixPainTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(riskColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(riskColor.opacity(0.2), lineWidth: 1)
        )
    }
}

struct FixPainExerciseCard: View {
    let exercise: PainExercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Placeholder Image
            RoundedRectangle(cornerRadius: 12)
                .fill(FixPainTheme.cardBackgroundSecondary)
                .frame(height: 100)
                .overlay(
                    Image(systemName: "figure.run")
                        .font(.largeTitle)
                        .foregroundStyle(FixPainTheme.primary.opacity(0.5))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.title)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
                
                Text(exercise.sets != nil ? "\(exercise.sets!) sets × \(exercise.reps ?? 0) reps" : "\(exercise.estimatedDurationMinutes ?? 5) min")
                    .font(.caption)
                    .foregroundStyle(FixPainTheme.textSecondary)
            }
        }
        .padding(12)
        .frame(width: 160)
        .background(FixPainTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: FixPainTheme.shadowColor.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

struct FixPainExerciseRow: View {
    let exercise: PainExercise
    
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12)
                .fill(FixPainTheme.cardBackgroundSecondary)
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "dumbbell.fill")
                        .foregroundStyle(FixPainTheme.textSecondary)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.title)
                    .font(.system(size: 16, weight: .medium))
                Text(exercise.description)
                    .font(.caption)
                    .foregroundStyle(FixPainTheme.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(FixPainTheme.textSecondary)
        }
        .padding()
        .background(FixPainTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
