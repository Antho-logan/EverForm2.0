//
//  LiveBreathworkSessionView.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import SwiftUI

struct LiveBreathworkSessionView: View {
    let pattern: BreathworkPattern
    @Environment(\.dismiss) private var dismiss
    @Environment(BreathworkStore.self) private var store
    
    // Session State
    @State private var isRunning = false
    @State private var currentRound = 1
    @State private var currentPhaseIndex = 0
    @State private var timeRemaining: Double = 0
    @State private var totalElapsed: TimeInterval = 0
    @State private var showingSummary = false
    
    // Animation State
    @State private var currentPhaseType: BreathPhaseType = .inhale
    
    private var totalRounds: Int { pattern.defaultRounds }
    
    private var currentPhase: BreathPhase {
        // SAFETY CHECK: Prevent crash if pattern has no phases
        if pattern.phases.isEmpty {
            print("[Breathwork] ERROR: Pattern has no phases. Returning fallback.")
            return BreathPhase(type: .inhale, durationSeconds: 4, instruction: "Breathe")
        }
        // SAFETY CHECK: Prevent index out of bounds
        if currentPhaseIndex >= pattern.phases.count {
            print("[Breathwork] ERROR: Index \(currentPhaseIndex) out of bounds. Returning last phase.")
            return pattern.phases.last ?? BreathPhase(type: .exhale, durationSeconds: 4, instruction: "Exhale")
        }
        return pattern.phases[currentPhaseIndex]
    }
    
    var body: some View {
        ZStack {
            DesignSystem.Colors.background.ignoresSafeArea()
            
            VStack {
                // Top Bar
                HStack {
                    Button {
                        endSession()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                            .padding(12)
                            .background(DesignSystem.Colors.backgroundSecondary)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text(pattern.displayName)
                        .font(DesignSystem.Typography.headline())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("Round")
                        Text("\(currentRound)/\(totalRounds)")
                            .monospacedDigit()
                    }
                    .font(DesignSystem.Typography.caption())
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(DesignSystem.Colors.backgroundSecondary)
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // Breathing Orb
                ZStack {
                    BreathingOrbView(
                        phase: currentPhaseType,
                        animationDuration: currentPhase.durationSeconds
                    )
                    
                    VStack(spacing: 8) {
                        Text(currentPhase.type.rawValue.uppercased())
                            .font(DesignSystem.Typography.displayMedium())
                            .foregroundStyle(.white)
                            .shadow(radius: 4)
                        
                        if let instruction = currentPhase.instruction {
                            Text(instruction)
                                .font(DesignSystem.Typography.bodyMedium())
                                .foregroundStyle(.white.opacity(0.9))
                                .shadow(radius: 2)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 400)
                
                Spacer()
                
                // Controls & Timer
                VStack(spacing: 32) {
                    Text(timeString(from: timeRemaining))
                        .font(DesignSystem.Typography.monospacedNumber(size: 48, relativeTo: .largeTitle))
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    HStack(spacing: 40) {
                        Button {
                            skipPhase()
                        } label: {
                            VStack {
                                Image(systemName: "forward.end.fill")
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                Text("Skip")
                                    .font(DesignSystem.Typography.caption())
                            }
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                        }
                        
                        Button {
                            togglePlayPause()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(DesignSystem.Colors.textPrimary)
                                    .frame(width: 72, height: 72)
                                
                                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(DesignSystem.Colors.background)
                            }
                        }
                        .scaleEffect(isRunning ? 1.0 : 1.05)
                        .animation(.spring(response: 0.3), value: isRunning)
                        
                        Button {
                            endSession()
                        } label: {
                            VStack {
                                Image(systemName: "stop.fill")
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                Text("End")
                                    .font(DesignSystem.Typography.caption())
                            }
                            .foregroundStyle(DesignSystem.Colors.error)
                        }
                    }
                    
                    Text("Always practice seated or lying down.")
                        .font(DesignSystem.Typography.caption())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .opacity(0.7)
                }
                .padding(.bottom, 40)
            }
            
            closeObserver
        }
        .onAppear {
            print("[Breathwork] LiveSession appeared. Pattern: \(pattern.displayName), Phases: \(pattern.phases.count)")
            startBreathingAnimationLoop()
        }
        .onDisappear {
            isRunning = false // Stop loop
        }
        .sheet(isPresented: $showingSummary) {
            BreathworkSessionSummaryView(
                pattern: pattern,
                totalMinutes: Int(totalElapsed / 60),
                roundsCompleted: currentRound
            )
        }
    }
    
    // MARK: - Logic
    
    private func togglePlayPause() {
        isRunning.toggle()
    }
    
    private func startBreathingAnimationLoop() {
        isRunning = true
        
        Task { @MainActor in
            // Initial delay
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            while !showingSummary {
                if !isRunning {
                    try? await Task.sleep(nanoseconds: 200_000_000)
                    continue
                }
                
                // Prepare Phase
                let phase = currentPhase
                currentPhaseType = phase.type
                timeRemaining = phase.durationSeconds
                triggerHaptic()
                
                let duration = phase.durationSeconds
                let startTime = Date()
                
                // Timer Loop
                while Date().timeIntervalSince(startTime) < duration {
                    if showingSummary { break }
                    // Check if skipped (timeRemaining reset manually)
                    if timeRemaining <= 0 { break }
                    
                    if !isRunning {
                        try? await Task.sleep(nanoseconds: 100_000_000)
                        continue
                    }
                    
                    let elapsed = Date().timeIntervalSince(startTime)
                    timeRemaining = max(0, duration - elapsed)
                    totalElapsed += 0.1
                    
                    try? await Task.sleep(nanoseconds: 100_000_000)
                }
                
                if !showingSummary {
                    advancePhase()
                }
            }
        }
    }
    
    private func advancePhase() {
        if currentPhaseIndex < pattern.phases.count - 1 {
            currentPhaseIndex += 1
        } else {
            if currentRound < totalRounds {
                currentRound += 1
                currentPhaseIndex = 0
            } else {
                completeSession()
            }
        }
    }
    
    private func skipPhase() {
        timeRemaining = 0
    }
    
    private func endSession() {
        isRunning = false
        dismiss()
    }
    
    private func completeSession() {
        isRunning = false
        showingSummary = true
        triggerSuccessHaptic()
    }
    
    private func timeString(from seconds: Double) -> String {
        let s = Int(ceil(seconds))
        let m = s / 60
        let sec = s % 60
        return String(format: "%02d:%02d", m, sec)
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func triggerSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Notification Handling
extension LiveBreathworkSessionView {
    private var closeObserver: some View {
        Color.clear
            .onReceive(NotificationCenter.default.publisher(for: .closeBreathworkSession)) { _ in
                dismiss()
            }
    }
}
