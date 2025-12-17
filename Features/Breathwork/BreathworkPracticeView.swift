//
//  BreathworkPracticeView.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import SwiftUI

struct BreathworkPracticeView: View {
    @Environment(BreathworkStore.self) private var store
    
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
                if let currentPattern = store.activeSessionPattern {
                    HeroSessionCard(pattern: currentPattern) {
                        // Apply configuration overrides
                        var modified = currentPattern
                        modified.defaultRounds = selectedRounds
                        sessionPattern = modified
                    }
                } else {
                     // Safe fallback UI if no pattern found
                    Text("No pattern selected")
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
                
                // Pattern Selector
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quick Patterns")
                        .sectionTitle()
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(store.patterns) { pattern in
                                Button {
                                    withAnimation {
                                        store.selectedPatternType = pattern.type
                                    }
                                } label: {
                                    EverFormCard {
                                        VStack(alignment: .leading, spacing: 12) {
                                            Image(systemName: pattern.type.iconName)
                                                .font(.system(size: 24))
                                                .foregroundStyle(store.selectedPatternType == pattern.type ? EverFormTheme.Colors.breathworkTeal : EverFormTheme.Colors.textSecondary)
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(pattern.displayName)
                                                    .font(EverFormTheme.Typography.body.weight(.semibold))
                                                    .foregroundStyle(EverFormTheme.Colors.textPrimary)
                                                    .lineLimit(2)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                
                                                Text("\(pattern.estimatedMinutes) min")
                                                    .font(EverFormTheme.Typography.caption)
                                                    .foregroundStyle(EverFormTheme.Colors.textSecondary)
                                            }
                                        }
                                        .frame(width: 140, height: 100, alignment: .topLeading)
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(store.selectedPatternType == pattern.type ? EverFormTheme.Colors.breathworkTeal : Color.clear, lineWidth: 2)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 4) // Shadow room
                    }
                }
                
                // Configuration
                VStack(alignment: .leading, spacing: 16) {
                    Text("Session Config")
                        .sectionTitle()
                        .padding(.horizontal, 20)
                    
                    EverFormCard {
                        VStack(spacing: 0) {
                            ConfigRow(label: "Rounds", icon: "arrow.triangle.2.circlepath") {
                                HStack(spacing: 12) {
                                    Button {
                                        if selectedRounds > 1 { selectedRounds -= 1 }
                                    } label: {
                                        Image(systemName: "minus")
                                            .frame(width: 32, height: 32)
                                            .background(EverFormTheme.Colors.surface)
                                            .clipShape(Circle())
                                            .foregroundStyle(EverFormTheme.Colors.primaryBlue)
                                    }
                                    
                                    Text("\(selectedRounds)")
                                        .font(EverFormTheme.Typography.body.weight(.bold))
                                        .frame(minWidth: 24)
                                    
                                    Button {
                                        if selectedRounds < 10 { selectedRounds += 1 }
                                    } label: {
                                        Image(systemName: "plus")
                                            .frame(width: 32, height: 32)
                                            .background(EverFormTheme.Colors.surface)
                                            .clipShape(Circle())
                                            .foregroundStyle(EverFormTheme.Colors.primaryBlue)
                                    }
                                }
                            }
                            
                            Divider().padding(.leading, 50)
                            
                            ConfigRow(label: "Haptics", icon: "iphone.radiowaves.left.and.right") {
                                Toggle("", isOn: $hapticsEnabled)
                                    .labelsHidden()
                                    .tint(EverFormTheme.Colors.primaryBlue)
                            }
                            
                            Divider().padding(.leading, 50)
                            
                            ConfigRow(label: "Guidance", icon: "waveform") {
                                 Text("Voice & Sound")
                                    .foregroundStyle(EverFormTheme.Colors.textSecondary)
                            }
                        }
                    }
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
        .onAppear {
            store.loadAiTodaySuggestionIfNeeded()
        }
        .onChange(of: store.suggestedRoundsOverride) { newValue in
            if let rounds = newValue {
                withAnimation {
                    selectedRounds = rounds
                }
            }
        }
    }
}

struct HeroSessionCard: View {
    let pattern: BreathworkPattern
    let onStart: () -> Void
    
    var body: some View {
        EverFormCard {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Recommended for you")
                            .font(EverFormTheme.Typography.caption)
                            .foregroundStyle(EverFormTheme.Colors.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(EverFormTheme.Colors.surface)
                            .clipShape(Capsule())
                        
                        Text(pattern.displayName)
                            .font(EverFormTheme.Typography.screenTitle)
                            .foregroundStyle(EverFormTheme.Colors.textPrimary)
                    }
                    Spacer()
                    Image(systemName: pattern.type.iconName)
                        .font(.system(size: 32))
                        .foregroundStyle(pattern.type.gradientColors.first ?? EverFormTheme.Colors.breathworkTeal)
                }
                
                Text("\(pattern.targetEffect) • \(pattern.estimatedMinutes) min")
                    .font(EverFormTheme.Typography.body)
                    .foregroundStyle(EverFormTheme.Colors.textSecondary)
                
                Spacer(minLength: 20)
                
                Button(action: onStart) {
                    Text("Start Session")
                        .font(EverFormTheme.Fonts.buttonText())
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(EverFormTheme.Colors.primaryBlue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: EverFormTheme.Colors.primaryBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
            }
        }
        .padding(.horizontal, 20)
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
                .font(EverFormTheme.Typography.body)
                .foregroundStyle(EverFormTheme.Colors.textPrimary)
            Spacer()
            content
        }
        .padding(16)
    }
}
