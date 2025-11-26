//
//  BreathworkInsightsView.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import SwiftUI

struct BreathworkInsightsView: View {
    @Environment(BreathworkStore.self) private var store
    @State private var selectedChartRange = 0 // 0 = 7 days, 1 = 30 days
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Stats Overview
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    BreathworkStatCard(
                        title: "Total Sessions",
                        value: "\(store.totalSessions)",
                        icon: "figure.mind.and.body",
                        color: .blue
                    )
                    BreathworkStatCard(
                        title: "Minutes",
                        value: "\(store.totalMinutes)",
                        icon: "clock",
                        color: .purple
                    )
                    BreathworkStatCard(
                        title: "Streak",
                        value: "\(store.longestStreak) days",
                        icon: "flame.fill",
                        color: .orange
                    )
                    BreathworkStatCard(
                        title: "Best Hold",
                        value: "\(store.longestRetentionSeconds)s",
                        icon: "stopwatch",
                        color: .teal
                    )
                }
                .padding(.horizontal, 20)
                
                // Chart
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Trends")
                            .font(DesignSystem.Typography.sectionHeader())
                        Spacer()
                        Picker("", selection: $selectedChartRange) {
                            Text("7 Days").tag(0)
                            Text("30 Days").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 160)
                    }
                    .padding(.horizontal, 20)
                    
                    EFCard {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack(alignment: .bottom, spacing: 8) {
                                ForEach(0..<7) { i in
                                    VStack {
                                        Spacer()
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(i > 4 ? DesignSystem.Colors.accent : DesignSystem.Colors.neutral100)
                                            .frame(height: CGFloat([40, 60, 20, 80, 30, 90, 100][i]))
                                    }
                                }
                            }
                            .frame(height: 150)
                            .padding(.top, 10)
                            
                            Text("You're breathing 12% more than last week.")
                                .font(DesignSystem.Typography.caption())
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Levels
                VStack(alignment: .leading, spacing: 16) {
                    Text("Levels")
                        .font(DesignSystem.Typography.sectionHeader())
                        .padding(.horizontal, 20)
                    
                    EFCard {
                        VStack(spacing: 20) {
                            LevelRow(level: 1, title: "Getting Started", isUnlocked: true, progress: 1.0)
                            LevelRow(level: 2, title: "Consistent Breather", isUnlocked: true, progress: 0.4)
                            LevelRow(level: 3, title: "Deep Diver", isUnlocked: false, progress: 0.0)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Education
                VStack(alignment: .leading, spacing: 16) {
                    Text("Learn")
                        .font(DesignSystem.Typography.sectionHeader())
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            EducationCard(title: "The Science of CO₂ Tolerance", color: .indigo)
                            EducationCard(title: "Nervous System 101", color: .teal)
                            EducationCard(title: "Why Nasal Breathing?", color: .blue)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer(minLength: 40)
            }
            .padding(.vertical, 20)
        }
    }
}

struct LevelRow: View {
    let level: Int
    let title: String
    let isUnlocked: Bool
    let progress: Double
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? DesignSystem.Colors.accent : DesignSystem.Colors.neutral100)
                    .frame(width: 40, height: 40)
                Text("\(level)")
                    .font(DesignSystem.Typography.headline())
                    .foregroundStyle(isUnlocked ? .white : DesignSystem.Colors.neutral400)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(DesignSystem.Typography.bodyMedium())
                    .foregroundStyle(isUnlocked ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.neutral400)
                
                ProgressView(value: progress)
                    .tint(DesignSystem.Colors.accent)
            }
            
            Spacer()
            
            if !isUnlocked {
                Image(systemName: "lock.fill")
                    .foregroundStyle(DesignSystem.Colors.neutral300)
            }
        }
    }
}

struct EducationCard: View {
    let title: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(DesignSystem.Typography.headline())
                .foregroundStyle(.white)
                .lineLimit(2)
            
            Spacer()
            
            Text("Read Article")
                .font(DesignSystem.Typography.caption())
                .foregroundStyle(.white.opacity(0.8))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())
        }
        .padding(16)
        .frame(width: 160, height: 200)
        .background(
            LinearGradient(
                colors: [color, color.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

