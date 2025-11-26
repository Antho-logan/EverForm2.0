//
//  MobilityRoutineDetailView.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

import SwiftUI

struct MobilityRoutineDetailView: View {
    let routine: MobilityRoutine
    @State private var showSession = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(routine.type.rawValue.uppercased())
                            .font(DesignSystem.Typography.labelSmall())
                            .foregroundStyle(DesignSystem.Colors.accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(DesignSystem.Colors.accent.opacity(0.1))
                            .clipShape(Capsule())
                        Spacer()
                        Label("\(routine.durationMinutes) min", systemImage: "clock")
                            .font(DesignSystem.Typography.caption())
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                    }
                    
                    Text(routine.title)
                        .font(DesignSystem.Typography.displaySmall())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    Text(routine.subtitle)
                        .font(DesignSystem.Typography.bodyMedium())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Focus Areas
                VStack(alignment: .leading, spacing: 12) {
                    Text("Focus Areas")
                        .font(DesignSystem.Typography.labelMedium())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .textCase(.uppercase)
                    
                    HStack {
                        ForEach(routine.focusAreas) { area in
                            Label(area.rawValue, systemImage: area.icon)
                                .font(DesignSystem.Typography.bodyMedium())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(DesignSystem.Colors.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(.horizontal)
                
                // Routine Steps
                VStack(alignment: .leading, spacing: 16) {
                    Text("Routine Breakdown")
                        .font(DesignSystem.Typography.titleSmall())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    VStack(spacing: 12) {
                        ForEach(Array(routine.steps.enumerated()), id: \.offset) { index, step in
                            RoutineStepRow(index: index + 1, step: step)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 40)
                
                // Start Button
                Button {
                    showSession = true
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Session")
                    }
                    .font(DesignSystem.Typography.buttonLarge())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(DesignSystem.Colors.accent)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .background(DesignSystem.Colors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showSession) {
            MobilitySessionView(routine: routine)
        }
    }
}

struct RoutineStepRow: View {
    let index: Int
    let step: MobilityRoutineStep
    
    var body: some View {
        HStack(spacing: 16) {
            Text("\(index)")
                .font(DesignSystem.Typography.labelMedium())
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(step.name)
                    .font(DesignSystem.Typography.bodyLarge())
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                
                if let desc = step.description {
                    Text(desc)
                        .font(DesignSystem.Typography.caption())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            Text(formatDuration(step.durationSeconds))
                .font(DesignSystem.Typography.monospacedNumber(size: 14, relativeTo: .caption))
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(DesignSystem.Colors.neutral100.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding()
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    func formatDuration(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
