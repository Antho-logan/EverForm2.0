//
//  ProgramDetailView.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import SwiftUI

struct ProgramDetailView: View {
    let program: BreathworkProgram
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Hero
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(
                        colors: [DesignSystem.Colors.neutral900, DesignSystem.Colors.neutral700],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 250)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(program.level.rawValue.uppercased())
                            .font(DesignSystem.Typography.caption())
                            .foregroundStyle(DesignSystem.Colors.accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Capsule())
                        
                        Text(program.name)
                            .font(DesignSystem.Typography.displaySmall())
                            .foregroundStyle(.white)
                        
                        Text(program.description)
                            .font(DesignSystem.Typography.bodyMedium())
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(20)
                }
                
                // Stats Bar
                HStack {
                    Label("\(program.daysCount) Days", systemImage: "calendar")
                    Spacer()
                    Label("\(program.dailyMinutes) min/day", systemImage: "clock")
                    Spacer()
                    Label("HealthKit", systemImage: "heart.fill")
                }
                .font(DesignSystem.Typography.caption())
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .padding(20)
                .background(DesignSystem.Colors.backgroundSecondary)
                
                // Schedule
                VStack(alignment: .leading, spacing: 20) {
                    Text("Schedule")
                        .font(DesignSystem.Typography.sectionHeader())
                        .padding(.horizontal, 20)
                    
                    ForEach(program.sessions) { day in
                        HStack(spacing: 16) {
                            // Status Icon
                            ZStack {
                                if day.completed {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(DesignSystem.Colors.success)
                                } else if day.locked {
                                    Image(systemName: "lock.fill")
                                        .foregroundStyle(DesignSystem.Colors.neutral300)
                                } else {
                                    Circle()
                                        .stroke(DesignSystem.Colors.accent, lineWidth: 2)
                                        .frame(width: 24, height: 24)
                                    Text("\(day.dayIndex)")
                                        .font(.caption2)
                                }
                            }
                            .frame(width: 32)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Day \(day.dayIndex) • \(day.template.pattern.displayName)")
                                    .font(DesignSystem.Typography.bodyMedium())
                                    .foregroundStyle(day.locked ? DesignSystem.Colors.textSecondary : DesignSystem.Colors.textPrimary)
                                
                                Text("\(day.template.totalEstimatedMinutes) min • \(day.template.pattern.targetEffect)")
                                    .font(DesignSystem.Typography.caption())
                                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                            }
                            
                            Spacer()
                            
                            if !day.locked && !day.completed {
                                Button("Start") {
                                    // Start logic
                                }
                                .font(DesignSystem.Typography.labelMedium())
                                .foregroundStyle(DesignSystem.Colors.accent)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(DesignSystem.Colors.accent.opacity(0.1))
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        
                        if day.dayIndex < program.sessions.count {
                            Divider().padding(.leading, 68)
                        }
                    }
                }
                .padding(.vertical, 20)
            }
        }
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(20)
                    .padding(.top, 20)
            }
        }
    }
}

