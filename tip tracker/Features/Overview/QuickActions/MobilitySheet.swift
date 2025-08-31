//
//  MobilitySheet.swift
//  EverForm
//
//  Mobility routine selection and execution
//  Assumptions: Pre-defined routines, step-by-step timer
//

import SwiftUI

struct MobilityRoutine {
    let id = UUID()
    let title: String
    let duration: Int // minutes
    let description: String
    let steps: [MobilityStep]
    let icon: String
    let color: Color
}

struct MobilityStep {
    let id = UUID()
    let name: String
    let description: String
    let duration: Int // seconds
    let instructions: String
}

struct MobilitySheet: View {
    @Environment(\.dismiss) private var dismiss
    let onComplete: () -> Void
    
    @State private var selectedRoutine: MobilityRoutine?
    @State private var showRoutineRun = false
    
    private let routines = [
        MobilityRoutine(
            title: "Daily Flow",
            duration: 10,
            description: "Full-body mobility for daily maintenance",
            steps: [
                MobilityStep(
                    name: "Cat-Cow Stretch",
                    description: "Spinal mobility",
                    duration: 60,
                    instructions: "On hands and knees, alternate between arching and rounding your spine"
                ),
                MobilityStep(
                    name: "Hip Circles",
                    description: "Hip mobility",
                    duration: 45,
                    instructions: "Standing, hands on hips, make large circles with your hips"
                ),
                MobilityStep(
                    name: "Shoulder Rolls",
                    description: "Shoulder mobility",
                    duration: 45,
                    instructions: "Roll shoulders backward in large circles, then forward"
                ),
                MobilityStep(
                    name: "Thoracic Rotation",
                    description: "Upper back mobility",
                    duration: 60,
                    instructions: "On hands and knees, reach one arm under and across your body"
                ),
                MobilityStep(
                    name: "Ankle Circles",
                    description: "Ankle mobility",
                    duration: 45,
                    instructions: "Seated or standing, lift one foot and make circles with your ankle"
                ),
                MobilityStep(
                    name: "Neck Stretches",
                    description: "Neck mobility",
                    duration: 45,
                    instructions: "Gently tilt head side to side, forward and back"
                )
            ],
            icon: "figure.walk",
            color: .green
        ),
        MobilityRoutine(
            title: "Desk Break",
            duration: 5,
            description: "Quick reset for desk workers",
            steps: [
                MobilityStep(
                    name: "Neck Release",
                    description: "Release neck tension",
                    duration: 45,
                    instructions: "Slowly tilt head to each side, hold for 15 seconds"
                ),
                MobilityStep(
                    name: "Shoulder Blade Squeeze",
                    description: "Counter rounded shoulders",
                    duration: 30,
                    instructions: "Pull shoulder blades together, hold for 5 seconds, repeat"
                ),
                MobilityStep(
                    name: "Thoracic Extension",
                    description: "Open up the chest",
                    duration: 45,
                    instructions: "Hands behind head, lean back over chair, breathe deeply"
                ),
                MobilityStep(
                    name: "Hip Flexor Stretch",
                    description: "Counter hip tightness",
                    duration: 60,
                    instructions: "Standing, step one foot back, lean forward into stretch"
                ),
                MobilityStep(
                    name: "Wrist Circles",
                    description: "Wrist mobility",
                    duration: 30,
                    instructions: "Make circles with your wrists, both directions"
                )
            ],
            icon: "desktopcomputer",
            color: .orange
        )
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Mobility")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Keep your body moving well")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    // Routine Selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Choose a Routine")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        LazyVStack(spacing: 16) {
                            ForEach(routines, id: \.id) { routine in
                                RoutineCard(
                                    routine: routine,
                                    isSelected: selectedRoutine?.id == routine.id
                                ) {
                                    selectedRoutine = routine
                                }
                            }
                        }
                    }
                    
                    // Start Button
                    if let routine = selectedRoutine {
                        VStack(spacing: 16) {
                            // Routine Preview
                            VStack(alignment: .leading, spacing: 12) {
                                Text("What's Included")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                LazyVStack(alignment: .leading, spacing: 8) {
                                    ForEach(routine.steps, id: \.id) { step in
                                        HStack {
                                            Circle()
                                                .fill(routine.color.opacity(0.3))
                                                .frame(width: 6, height: 6)
                                            
                                            Text(step.name)
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            Text("\(step.duration)s")
                                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            .padding(16)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            
                            Button {
                                startRoutine()
                            } label: {
                                HStack {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Start \(routine.title)")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(routine.color)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(20)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showRoutineRun) {
            if let routine = selectedRoutine {
                MobilityRunView(
                    routine: routine,
                    onComplete: {
                        showRoutineRun = false
                        dismiss()
                        onComplete()
                    }
                )
            }
        }
    }
    
    private func startRoutine() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        showRoutineRun = true
        
        DebugLog.info("Started mobility routine: \(selectedRoutine?.title ?? "Unknown")")
        TelemetryService.shared.track("mobility_started", properties: [
            "routine": selectedRoutine?.title ?? "Unknown"
        ])
    }
}

// MARK: - Routine Card
struct RoutineCard: View {
    let routine: MobilityRoutine
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(routine.color.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: routine.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(routine.color)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(routine.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(routine.description)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Label("\(routine.duration) min", systemImage: "clock")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                        
                        Label("\(routine.steps.count) moves", systemImage: "figure.flexibility")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
            }
            .padding(16)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? .blue : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    MobilitySheet {
        print("Mobility completed")
    }
}
