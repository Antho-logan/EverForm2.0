//
//  MobilitySessionView.swift
//  EverForm
//
//  Created by Gemini on 18/11/2025.
//

import SwiftUI

struct MobilitySessionView: View {
    let routine: MobilityRoutine
    @Environment(\.dismiss) private var dismiss
    @StateObject private var store = MobilityStore.shared
    
    @State private var currentStepIndex = 0
    @State private var isTimerRunning = false
    @State private var timeRemaining = 0
    @State private var showCelebration = false
    
    private var steps: [MobilityRoutineStep] { routine.steps }
    private var currentStep: MobilityRoutineStep? {
        guard currentStepIndex < steps.count else { return nil }
        return steps[currentStepIndex]
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea() // Immersive dark mode for session
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .padding(12)
                            .background(.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("\(currentStepIndex + 1) of \(steps.count)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                    Spacer()
                    // Placeholder for sound toggle
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                if showCelebration {
                    CelebrationView {
                        dismiss()
                    }
                } else if let step = currentStep {
                    // Exercise Content
                    VStack(spacing: 32) {
                        Text(step.name)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        
                        // Media Placeholder
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.white.opacity(0.1))
                            .aspectRatio(4/3, contentMode: .fit)
                            .overlay(
                                VStack(spacing: 12) {
                                    Image(systemName: "figure.flexibility")
                                        .font(.system(size: 64))
                                        .foregroundStyle(.white.opacity(0.5))
                                    Text("Exercise Demo")
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                            )
                        
                        // Instructions
                        if let description = step.description {
                            Text(description)
                                .font(.title3)
                                .foregroundStyle(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        Spacer()
                        
                        // Timer / Controls
                        VStack(spacing: 20) {
                            // Timer
                            Text(timeString(time: timeRemaining))
                                .font(.system(size: 64, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white)
                                .onAppear {
                                    // Initial setup
                                    timeRemaining = step.durationSeconds
                                    isTimerRunning = true
                                }
                                .onChange(of: currentStepIndex) { _ in
                                    // Reset when step changes
                                    timeRemaining = step.durationSeconds
                                    isTimerRunning = true
                                }
                                .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                                    if isTimerRunning && timeRemaining > 0 {
                                        timeRemaining -= 1
                                    } else if timeRemaining == 0 && isTimerRunning {
                                        isTimerRunning = false
                                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                    }
                                }
                            
                            HStack(spacing: 40) {
                                Button {
                                    if currentStepIndex > 0 {
                                        withAnimation { currentStepIndex -= 1 }
                                    }
                                } label: {
                                    Image(systemName: "backward.fill")
                                        .font(.title)
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                                .disabled(currentStepIndex == 0)
                                
                                Button {
                                    isTimerRunning.toggle()
                                } label: {
                                    Image(systemName: isTimerRunning ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 72))
                                        .foregroundStyle(DesignSystem.Colors.accent)
                                }
                                
                                Button {
                                    advance()
                                } label: {
                                    Image(systemName: "forward.fill")
                                        .font(.title)
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
                    .id(step.id) // Force transition on change
                }
            }
        }
    }
    
    func advance() {
        if currentStepIndex < steps.count - 1 {
            withAnimation { currentStepIndex += 1 }
        } else {
            // Finish
            // TODO: Log session completion
            withAnimation { showCelebration = true }
        }
    }
    
    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct CelebrationView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundStyle(.yellow)
                .padding()
                .background(Circle().fill(.white.opacity(0.1)))
            
            Text("Session Complete!")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)
            
            Text("Great job taking care of your joints.")
                .font(.title3)
                .foregroundStyle(.white.opacity(0.8))
            
            Button(action: onDismiss) {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 40)
            .padding(.top, 40)
        }
        .transition(.scale.combined(with: .opacity))
    }
}

