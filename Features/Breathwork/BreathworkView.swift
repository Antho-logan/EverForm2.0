//
//  BreathworkView.swift
//  EverForm
//
//  Full-screen breathwork experience with animated breathing ring
//

import SwiftUI

struct BreathworkView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedPattern: BreathingPattern = .fourSevenEight
    @State private var isActive = false
    @State private var currentPhase: BreathingPhase = .inhale
    @State private var countdown = 4
    @State private var ringScale: CGFloat = 0.8
    @State private var timer: Timer?
    
    enum BreathingPattern: String, CaseIterable {
        case fourSevenEight = "4-7-8"
        case box = "Box"
        case deep = "Deep"
        
        var description: String {
            switch self {
            case .fourSevenEight: return "Inhale 4s, Hold 7s, Exhale 8s"
            case .box: return "Inhale 4s, Hold 4s, Exhale 4s, Hold 4s"
            case .deep: return "Inhale 6s, Exhale 6s"
            }
        }
        
        var phases: [(BreathingPhase, Int)] {
            switch self {
            case .fourSevenEight: return [(.inhale, 4), (.hold, 7), (.exhale, 8)]
            case .box: return [(.inhale, 4), (.hold, 4), (.exhale, 4), (.hold, 4)]
            case .deep: return [(.inhale, 6), (.exhale, 6)]
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
        let semantic = Theme.semantic(colorScheme)
        
        NavigationView {
            VStack(spacing: Theme.Spacing.xl) {
                if !isActive {
                    // Pattern selection
                    VStack(spacing: Theme.Spacing.lg) {
                        VStack(spacing: Theme.Spacing.sm) {
                            Text("Breathwork")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(palette.textPrimary)
                            
                            Text("Choose a breathing pattern to help you relax and focus")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(palette.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        VStack(spacing: Theme.Spacing.md) {
                            ForEach(BreathingPattern.allCases, id: \.self) { pattern in
                                Button(action: {
                                    selectedPattern = pattern
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                }) {
                                    EFCard {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(pattern.rawValue)
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundStyle(palette.textPrimary)
                                                
                                                Text(pattern.description)
                                                    .font(.system(size: 14, weight: .regular))
                                                    .foregroundStyle(palette.textSecondary)
                                            }
                                            
                                            Spacer()
                                            
                                            if selectedPattern == pattern {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 24, weight: .medium))
                                                    .foregroundStyle(semantic.success)
                                            }
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        // Start button
                        Button(action: startBreathing) {
                            Text("Start Session")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Theme.Spacing.md)
                                .background(semantic.success)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    // Active breathing session
                    VStack(spacing: Theme.Spacing.xl) {
                        Spacer()
                        
                        // Breathing ring
                        ZStack {
                            // Outer ring
                            Circle()
                                .stroke(currentPhase.color.opacity(0.3), lineWidth: 4)
                                .frame(width: 200, height: 200)
                            
                            // Inner animated circle
                            Circle()
                                .fill(currentPhase.color.opacity(0.2))
                                .frame(width: 160, height: 160)
                                .scaleEffect(ringScale)
                                .animation(.easeInOut(duration: 1.0), value: ringScale)
                            
                            // Center content
                            VStack(spacing: Theme.Spacing.sm) {
                                Text(currentPhase.rawValue)
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundStyle(palette.textPrimary)
                                
                                Text("\(countdown)")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundStyle(currentPhase.color)
                                    .contentTransition(.numericText())
                            }
                        }
                        
                        Spacer()
                        
                        // Stop button
                        Button(action: stopBreathing) {
                            Text("Stop Session")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(semantic.danger)
                                .padding(.vertical, Theme.Spacing.md)
                                .padding(.horizontal, Theme.Spacing.xl)
                                .background(semantic.danger.opacity(0.1))
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        stopBreathing()
                        dismiss()
                    }
                    .foregroundStyle(palette.accent)
                }
            }
        }
        .interactiveDismissDisabled(false)
    }
    
    private func startBreathing() {
        isActive = true
        startBreathingCycle()
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    private func stopBreathing() {
        isActive = false
        timer?.invalidate()
        timer = nil
        ringScale = 0.8
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    private func startBreathingCycle() {
        let phases = selectedPattern.phases
        var currentPhaseIndex = 0
        
        func nextPhase() {
            let (phase, duration) = phases[currentPhaseIndex]
            currentPhase = phase
            countdown = duration
            
            // Animate ring based on phase
            withAnimation(.easeInOut(duration: Double(duration))) {
                ringScale = phase == .inhale ? 1.2 : (phase == .exhale ? 0.6 : 1.0)
            }
            
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

#Preview {
    BreathworkView()
}
