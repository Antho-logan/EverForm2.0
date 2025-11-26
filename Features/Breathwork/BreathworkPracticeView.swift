//
//  BreathworkPracticeView.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import SwiftUI

struct BreathworkPracticeView: View {
    @Environment(BreathworkStore.self) private var store
    // Removed Binding for self-contained navigation
    
    // Local config state
    @State private var selectedRounds: Int = 3
    @State private var pace: Double = 1.0
    @State private var hapticsEnabled = true
    
    // Session presentation
    @State private var sessionPattern: BreathworkPattern?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Hero Section
                if let currentPattern = store.patterns.first(where: { $0.type == store.selectedPatternType }) {
                    HeroSessionCard(pattern: currentPattern) {
                        sessionPattern = currentPattern
                    }
                }
                
                // Pattern Selector
                VStack(alignment: .leading, spacing: 16) {
                    Text("Patterns")
                        .font(DesignSystem.Typography.sectionHeader())
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(store.patterns) { pattern in
                                BreathworkPatternCard(
                                    pattern: pattern,
                                    isSelected: store.selectedPatternType == pattern.type
                                ) {
                                    withAnimation {
                                        store.selectedPatternType = pattern.type
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // Configuration
                VStack(alignment: .leading, spacing: 16) {
                    Text("Session Config")
                        .font(DesignSystem.Typography.sectionHeader())
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 0) {
                        ConfigRow(label: "Rounds", icon: "arrow.triangle.2.circlepath") {
                            Stepper("\(selectedRounds)", value: $selectedRounds, in: 1...10)
                        }
                        
                        Divider().padding(.leading, 50)
                        
                        ConfigRow(label: "Haptics", icon: "iphone.radiowaves.left.and.right") {
                            Toggle("", isOn: $hapticsEnabled)
                                .labelsHidden()
                        }
                        
                        Divider().padding(.leading, 50)
                        
                        ConfigRow(label: "Guidance", icon: "waveform") {
                             Text("Voice & Sound")
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                        }
                    }
                    .background(DesignSystem.Colors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 20)
                }
                
                Spacer(minLength: 40)
            }
            .padding(.vertical, 20)
        }
        .fullScreenCover(item: $sessionPattern) { pattern in
            LiveBreathworkSessionView(pattern: pattern)
                .environment(store)
        }
    }
}

struct HeroSessionCard: View {
    let pattern: BreathworkPattern
    let onStart: () -> Void
    
    var body: some View {
        Button(action: onStart) {
            ZStack(alignment: .bottomLeading) {
                // Background Gradient
                LinearGradient(
                    colors: pattern.type.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // Content
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Good Evening, Anthony")
                                .font(DesignSystem.Typography.subheadline())
                                .foregroundStyle(.white.opacity(0.9))
                            
                            Text("Recommended for you")
                                .font(DesignSystem.Typography.caption())
                                .foregroundStyle(.white.opacity(0.7))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.white.opacity(0.2))
                                .clipShape(Capsule())
                        }
                        Spacer()
                        Image(systemName: pattern.type.iconName)
                            .font(.system(size: 32))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(pattern.displayName)
                            .font(DesignSystem.Typography.displaySmall())
                            .foregroundStyle(.white)
                        
                        Text("\(pattern.targetEffect) • \(pattern.estimatedMinutes) min")
                            .font(DesignSystem.Typography.bodyMedium())
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    
                    HStack {
                        Text("Start Session")
                            .font(DesignSystem.Typography.buttonLarge())
                            .foregroundStyle(pattern.type.gradientColors.first ?? .blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(24)
            }
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: pattern.type.gradientColors.first?.opacity(0.3) ?? .clear, radius: 20, y: 10)
            .padding(.horizontal, 20)
        }
        .buttonStyle(.plain)
    }
}

struct ConfigRow<Content: View>: View {
    let label: String
    let icon: String
    let content: Content
    
    init(label: String, icon: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(DesignSystem.Colors.neutral500)
            Text(label)
                .font(DesignSystem.Typography.bodyMedium())
                .foregroundStyle(DesignSystem.Colors.textPrimary)
            Spacer()
            content
        }
        .padding(16)
    }
}

