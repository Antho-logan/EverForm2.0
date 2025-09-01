//
//  BreathworkSheet.swift
//  EverForm
//
//  Breathwork bottom sheet with preset breathing exercises
//

import SwiftUI

struct BreathworkSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedPreset: BreathworkPreset = .fourSevenEight
    @State private var isActive = false
    @State private var currentPhase: BreathingPhase = .inhale
    @State private var countdown = 4
    @State private var timer: Timer?
    
    enum BreathworkPreset: String, CaseIterable {
        case fourSevenEight = "4-7-8"
        case boxBreathing = "Box Breathing"
        case deepBreathing = "Deep Breathing"
        
        var description: String {
            switch self {
            case .fourSevenEight:
                return "Inhale 4s, Hold 7s, Exhale 8s"
            case .boxBreathing:
                return "Inhale 4s, Hold 4s, Exhale 4s, Hold 4s"
            case .deepBreathing:
                return "Inhale 6s, Exhale 6s"
            }
        }
        
        var phases: [(BreathingPhase, Int)] {
            switch self {
            case .fourSevenEight:
                return [(.inhale, 4), (.hold, 7), (.exhale, 8)]
            case .boxBreathing:
                return [(.inhale, 4), (.hold, 4), (.exhale, 4), (.hold, 4)]
            case .deepBreathing:
                return [(.inhale, 6), (.exhale, 6)]
            }
        }
    }
    
    enum BreathingPhase: String {
        case inhale = "Inhale"
        case hold = "Hold"
        case exhale = "Exhale"
        
        var color: Color {
            switch self {
            case .inhale: return .blue
            case .hold: return .orange
            case .exhale: return .green
            }
        }
    }
    
    var body: some View {
        let palette = Theme.palette(colorScheme)
        
        NavigationView {
            VStack(spacing: Theme.Spacing.lg) {
                // Header
                VStack(spacing: Theme.Spacing.sm) {
                    Text("Breathwork")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(palette.textPrimary)
                    
                    Text("Choose a breathing pattern to help you relax and focus")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(palette.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                if !isActive {
                    // Preset selection
                    VStack(spacing: Theme.Spacing.sm) {
                        ForEach(BreathworkPreset.allCases, id: \.self) { preset in
                            Button(action: {
                                selectedPreset = preset
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(preset.rawValue)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(palette.textPrimary)
                                        
                                        Text(preset.description)
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundStyle(palette.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if selectedPreset == preset {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundStyle(palette.accent)
                                    }
                                }
                                .padding(Theme.Spacing.md)
                                .background(
                                    selectedPreset == preset ?
                                    palette.accent.opacity(0.1) :
                                    palette.surface
                                )
                                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.Radius.card)
                                        .stroke(
                                            selectedPreset == preset ?
                                            palette.accent :
                                            palette.stroke,
                                            lineWidth: 1
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // Start button
                    Button(action: startBreathwork) {
                        Text("Start Session")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.md)
                            .background(palette.accent)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
                    }
                    .buttonStyle(.plain)
                } else {
                    // Active breathing session
                    VStack(spacing: Theme.Spacing.xl) {
                        // Breathing circle
                        ZStack {
                            Circle()
                                .stroke(currentPhase.color.opacity(0.3), lineWidth: 4)
                                .frame(width: 120, height: 120)
                            
                            Circle()
                                .fill(currentPhase.color.opacity(0.2))
                                .frame(width: 120, height: 120)
                                .scaleEffect(currentPhase == .inhale ? 1.2 : 0.8)
                                .animation(.easeInOut(duration: 1.0), value: currentPhase)
                            
                            VStack {
                                Text(currentPhase.rawValue)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(palette.textPrimary)
                                
                                Text("\(countdown)")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundStyle(currentPhase.color)
                            }
                        }
                        
                        // Stop button
                        Button(action: stopBreathwork) {
                            Text("Stop Session")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(palette.accent)
                                .padding(.vertical, Theme.Spacing.sm)
                                .padding(.horizontal, Theme.Spacing.lg)
                                .background(palette.accent.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Spacer()
            }
            .padding(Theme.Spacing.lg)
            .background(palette.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(palette.accent)
                }
            }
        }
    }
    
    private func startBreathwork() {
        isActive = true
        startBreathingCycle()
    }
    
    private func stopBreathwork() {
        isActive = false
        timer?.invalidate()
        timer = nil
    }
    
    private func startBreathingCycle() {
        let phases = selectedPreset.phases
        var currentPhaseIndex = 0
        
        func nextPhase() {
            let (phase, duration) = phases[currentPhaseIndex]
            currentPhase = phase
            countdown = duration
            
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                countdown -= 1
                
                if countdown <= 0 {
                    timer?.invalidate()
                    currentPhaseIndex = (currentPhaseIndex + 1) % phases.count
                    nextPhase()
                }
            }
        }
        
        nextPhase()
    }
}
