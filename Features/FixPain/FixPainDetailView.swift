//
//  FixPainDetailView.swift
//  EverForm
//
//  Detailed pain relief routine for specific body regions
//

import SwiftUI

struct FixPainDetailView: View {
    let region: FixPainView.PainRegion
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var isStarted = false
    @State private var currentStep = 0
    @State private var timer: Timer?
    @State private var timeRemaining = 30
    
    var routine: [RoutineStep] {
        switch region {
        case .back:
            return [
                RoutineStep(name: "Cat-Cow Stretch", duration: 30, description: "Gentle spinal mobility"),
                RoutineStep(name: "Child's Pose", duration: 45, description: "Lower back release"),
                RoutineStep(name: "Knee to Chest", duration: 30, description: "Hip flexor stretch"),
                RoutineStep(name: "Spinal Twist", duration: 30, description: "Thoracic mobility"),
                RoutineStep(name: "Bridge Hold", duration: 20, description: "Glute activation")
            ]
        case .neck:
            return [
                RoutineStep(name: "Neck Rolls", duration: 20, description: "Gentle circular motion"),
                RoutineStep(name: "Side Stretch", duration: 30, description: "Lateral neck stretch"),
                RoutineStep(name: "Chin Tucks", duration: 20, description: "Posture correction"),
                RoutineStep(name: "Shoulder Shrugs", duration: 15, description: "Tension release")
            ]
        case .knees:
            return [
                RoutineStep(name: "Quad Stretch", duration: 30, description: "Front thigh stretch"),
                RoutineStep(name: "Hamstring Stretch", duration: 30, description: "Back thigh stretch"),
                RoutineStep(name: "Calf Stretch", duration: 25, description: "Lower leg mobility"),
                RoutineStep(name: "Ankle Circles", duration: 15, description: "Joint mobility")
            ]
        case .shoulders:
            return [
                RoutineStep(name: "Arm Circles", duration: 20, description: "Shoulder warm-up"),
                RoutineStep(name: "Cross-Body Stretch", duration: 30, description: "Posterior deltoid"),
                RoutineStep(name: "Overhead Reach", duration: 25, description: "Shoulder mobility"),
                RoutineStep(name: "Wall Angels", duration: 30, description: "Posture improvement")
            ]
        case .hips:
            return [
                RoutineStep(name: "Hip Circles", duration: 20, description: "Joint mobility"),
                RoutineStep(name: "Pigeon Pose", duration: 45, description: "Deep hip stretch"),
                RoutineStep(name: "Figure-4 Stretch", duration: 30, description: "Hip flexor release"),
                RoutineStep(name: "Glute Bridge", duration: 25, description: "Hip strengthening")
            ]
        case .wrists:
            return [
                RoutineStep(name: "Wrist Circles", duration: 15, description: "Joint mobility"),
                RoutineStep(name: "Prayer Stretch", duration: 20, description: "Flexor stretch"),
                RoutineStep(name: "Reverse Prayer", duration: 20, description: "Extensor stretch"),
                RoutineStep(name: "Tendon Glides", duration: 15, description: "Nerve mobility")
            ]
        }
    }
    
    struct RoutineStep {
        let name: String
        let duration: Int
        let description: String
    }
    
    var body: some View {
        let palette = Theme.palette(colorScheme)
        let semantic = Theme.semantic(colorScheme)
        
        NavigationView {
            VStack(spacing: Theme.Spacing.xl) {
                if !isStarted {
                    // Routine overview
                    VStack(spacing: Theme.Spacing.lg) {
                        VStack(spacing: Theme.Spacing.sm) {
                            Text("\(region.rawValue) Relief")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(palette.textPrimary)
                            
                            Text("A targeted routine to help relieve \(region.rawValue.lowercased()) discomfort")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(palette.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Routine steps
                        VStack(spacing: Theme.Spacing.md) {
                            ForEach(Array(routine.enumerated()), id: \.offset) { index, step in
                                EFCard {
                                    HStack {
                                        // Step number
                                        ZStack {
                                            Circle()
                                                .fill(semantic.danger.opacity(0.15))
                                                .frame(width: 32, height: 32)
                                            
                                            Text("\(index + 1)")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundStyle(semantic.danger)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(step.name)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundStyle(palette.textPrimary)
                                            
                                            Text(step.description)
                                                .font(.system(size: 14, weight: .regular))
                                                .foregroundStyle(palette.textSecondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text("\(step.duration)s")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundStyle(palette.textSecondary)
                                    }
                                }
                            }
                        }
                        
                        // Start button
                        Button(action: startRoutine) {
                            Text("Start Routine")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Theme.Spacing.md)
                                .background(semantic.danger)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    // Active routine
                    VStack(spacing: Theme.Spacing.xl) {
                        // Progress
                        VStack(spacing: Theme.Spacing.sm) {
                            Text("Step \(currentStep + 1) of \(routine.count)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(palette.textSecondary)
                            
                            ProgressView(value: Double(currentStep), total: Double(routine.count))
                                .progressViewStyle(LinearProgressViewStyle(tint: semantic.danger))
                        }
                        
                        Spacer()
                        
                        // Current step
                        VStack(spacing: Theme.Spacing.lg) {
                            Text(routine[currentStep].name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(palette.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text(routine[currentStep].description)
                                .font(.system(size: 18, weight: .regular))
                                .foregroundStyle(palette.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            // Timer
                            ZStack {
                                Circle()
                                    .stroke(semantic.danger.opacity(0.3), lineWidth: 8)
                                    .frame(width: 120, height: 120)
                                
                                Text("\(timeRemaining)")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundStyle(semantic.danger)
                                    .contentTransition(.numericText())
                            }
                        }
                        
                        Spacer()
                        
                        // Controls
                        HStack(spacing: Theme.Spacing.lg) {
                            Button("Skip") {
                                nextStep()
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(palette.textSecondary)
                            
                            Spacer()
                            
                            Button("Stop") {
                                stopRoutine()
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(semantic.danger)
                            .padding(.horizontal, Theme.Spacing.lg)
                            .padding(.vertical, Theme.Spacing.sm)
                            .background(semantic.danger.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.pill))
                        }
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
                        stopRoutine()
                        dismiss()
                    }
                    .foregroundStyle(palette.accent)
                }
            }
        }
        .interactiveDismissDisabled(false)
    }
    
    private func startRoutine() {
        isStarted = true
        currentStep = 0
        startStepTimer()
        
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    private func stopRoutine() {
        isStarted = false
        timer?.invalidate()
        timer = nil
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    private func startStepTimer() {
        timeRemaining = routine[currentStep].duration
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeRemaining -= 1
            
            if timeRemaining <= 0 {
                nextStep()
            }
        }
    }
    
    private func nextStep() {
        timer?.invalidate()
        
        if currentStep < routine.count - 1 {
            currentStep += 1
            startStepTimer()
        } else {
            // Routine complete
            stopRoutine()
            let success = UINotificationFeedbackGenerator()
            success.notificationOccurred(.success)
        }
    }
}

#Preview {
    FixPainDetailView(region: .back)
}
