//
//  MobilityRunView.swift
//  EverForm
//
//  Active mobility routine execution with step-by-step timer
//  Assumptions: Simple timer logic, haptic feedback
//

import SwiftUI

struct MobilityRunView: View {
    @Environment(\.dismiss) private var dismiss
    let routine: QuickActionMobilityRoutine
    let onComplete: () -> Void
    
    @State private var currentStepIndex = 0
    @State private var stepTimeRemaining: Int = 0
    @State private var totalTimeElapsed: Int = 0
    @State private var timer: Timer?
    @State private var isPaused = false
    @State private var showCompletionSheet = false
    
    private var currentStep: QuickActionMobilityStep? {
        guard currentStepIndex < routine.steps.count else { return nil }
        return routine.steps[currentStepIndex]
    }
    
    private var progress: Double {
        let completedSteps = currentStepIndex
        let currentStepProgress = currentStep != nil ? 
            Double(currentStep!.duration - stepTimeRemaining) / Double(currentStep!.duration) : 0
        return (Double(completedSteps) + currentStepProgress) / Double(routine.steps.count)
    }
    
    private var totalDuration: Int {
        routine.steps.reduce(0) { $0 + $1.duration }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header with progress
                VStack(spacing: 16) {
                    HStack {
                        Button("End") {
                            endRoutine()
                        }
                        .foregroundColor(.red)
                        
                        Spacer()
                        
                        Text(formatTime(totalTimeElapsed))
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    
                    // Progress bar
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(routine.title)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                            
                            Spacer()
                            
                            Text("\(Int(progress * 100))%")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(routine.color)
                        }
                        
                        ProgressView(value: progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: routine.color))
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial)
                
                if let step = currentStep {
                    // Current Step
                    ScrollView {
                        VStack(spacing: 32) {
                            Spacer(minLength: 40)
                            
                            // Step Info
                            VStack(spacing: 16) {
                                Text("Step \(currentStepIndex + 1) of \(routine.steps.count)")
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .foregroundColor(routine.color)
                                
                                Text(step.name)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .multilineTextAlignment(.center)
                                
                                Text(step.description)
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            // Timer Circle
                            VStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .stroke(routine.color.opacity(0.2), lineWidth: 8)
                                        .frame(width: 160, height: 160)
                                    
                                    Circle()
                                        .trim(from: 0, to: 1 - Double(stepTimeRemaining) / Double(step.duration))
                                        .stroke(routine.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                        .frame(width: 160, height: 160)
                                        .rotationEffect(.degrees(-90))
                                        .animation(.linear(duration: 1), value: stepTimeRemaining)
                                    
                                    VStack(spacing: 4) {
                                        Text("\(stepTimeRemaining)")
                                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                                            .foregroundColor(routine.color)
                                        
                                        Text("seconds")
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                // Play/Pause Button
                                Button {
                                    togglePause()
                                } label: {
                                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .frame(width: 60, height: 60)
                                        .background(routine.color)
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Instructions
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Instructions")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text(step.instructions)
                                    .font(.system(size: 15, weight: .regular, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(16)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            // Navigation buttons
                            HStack(spacing: 20) {
                                if currentStepIndex > 0 {
                                    Button("Previous") {
                                        previousStep()
                                    }
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(routine.color)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                
                                if currentStepIndex < routine.steps.count - 1 {
                                    Button("Next") {
                                        nextStep()
                                    }
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(routine.color)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                } else {
                                    Button("Finish") {
                                        finishRoutine()
                                    }
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(.green)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            
                            Spacer(minLength: 40)
                        }
                        .padding(20)
                    }
                } else {
                    Spacer()
                    Text("No steps available")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .sheet(isPresented: $showCompletionSheet) {
            MobilityCompletionSheet(
                routine: routine,
                totalTime: totalTimeElapsed,
                onDismiss: {
                    showCompletionSheet = false
                    dismiss()
                    onComplete()
                }
            )
        }
    }
    
    private func startTimer() {
        guard let step = currentStep else { return }
        stepTimeRemaining = step.duration
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            guard !isPaused else { return }
            
            totalTimeElapsed += 1
            stepTimeRemaining -= 1
            
            if stepTimeRemaining <= 0 {
                // Auto-advance to next step
                if currentStepIndex < routine.steps.count - 1 {
                    nextStep()
                } else {
                    finishRoutine()
                }
            }
        }
    }
    
    private func togglePause() {
        isPaused.toggle()
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    private func nextStep() {
        guard currentStepIndex < routine.steps.count - 1 else { return }
        
        currentStepIndex += 1
        if let step = currentStep {
            stepTimeRemaining = step.duration
        }
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    private func previousStep() {
        guard currentStepIndex > 0 else { return }
        
        currentStepIndex -= 1
        if let step = currentStep {
            stepTimeRemaining = step.duration
        }
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    private func finishRoutine() {
        timer?.invalidate()
        showCompletionSheet = true
        
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        
        DebugLog.info("Mobility routine completed: \(routine.title)")
        TelemetryService.shared.track("mobility_completed", properties: [
            "routine": routine.title,
            "duration_seconds": "\(totalTimeElapsed)"
        ])
    }
    
    private func endRoutine() {
        timer?.invalidate()
        dismiss()
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Mobility Completion Sheet
struct MobilityCompletionSheet: View {
    let routine: QuickActionMobilityRoutine
    let totalTime: Int
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // Success Icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.green)
                
                // Title
                VStack(spacing: 8) {
                    Text("Mobility Complete!")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    
                    Text("Great work keeping your body moving")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                // Summary
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(routine.title)
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                            Spacer()
                        }
                        
                        HStack {
                            Label(formatTime(totalTime), systemImage: "clock")
                            Spacer()
                            Label("\(routine.steps.count) moves", systemImage: "figure.flexibility")
                        }
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Spacer()
                
                // Done Button
                Button("Done") {
                    onDismiss()
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(routine.color)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(20)
            .navigationTitle("")
            .navigationBarHidden(true)
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        return "\(minutes) min"
    }
}

// MARK: - Preview
#Preview {
    MobilityRunView(
        routine: QuickActionMobilityRoutine(
            title: "Daily Flow",
            duration: 10,
            description: "Full-body mobility",
            steps: [
                QuickActionMobilityStep(name: "Cat-Cow", description: "Spinal mobility", duration: 60, instructions: "Move spine")
            ],
            icon: "figure.walk",
            color: .green
        )
    ) {
        print("Completed")
    }
}
