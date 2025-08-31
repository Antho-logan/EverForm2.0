//
//  StartWorkoutSheet.swift
//  EverForm
//
//  Today's workout plan preview and start interface
//  Assumptions: Mock workout data, simple navigation
//

import SwiftUI

struct StartWorkoutSheet: View {
    @Environment(\.dismiss) private var dismiss
    let trainingService: TrainingService
    let onWorkoutStarted: () -> Void
    
    @State private var showWorkoutRun = false
    
    private var todaysWorkout: WorkoutPlan {
        trainingService.getTodaysWorkout()
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Today's Plan")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("Ready to crush it?")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    // Workout Overview Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(todaysWorkout.title)
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                HStack(spacing: 16) {
                                    Label("\(todaysWorkout.estimatedDuration) min", systemImage: "clock")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                    
                                    Label("\(todaysWorkout.exercises.count) exercises", systemImage: "dumbbell")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "dumbbell.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.blue)
                        }
                        
                        Divider()
                        
                        // Exercise List
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Exercises")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            LazyVStack(spacing: 8) {
                                ForEach(todaysWorkout.exercises) { exercise in
                                    HStack {
                                        Circle()
                                            .fill(.blue.opacity(0.2))
                                            .frame(width: 8, height: 8)
                                        
                                        Text(exercise.name)
                                            .font(.system(size: 15, weight: .medium, design: .rounded))
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        Text("\(exercise.targetSets) × \(exercise.targetReps)")
                                            .font(.system(size: 14, weight: .regular, design: .rounded))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    Spacer(minLength: 20)
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button {
                            startWorkout()
                        } label: {
                            HStack {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Start Workout")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        
                        Button("Close") {
                            dismiss()
                        }
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .buttonStyle(.plain)
                    }
                }
                .padding(20)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .fullScreenCover(isPresented: $showWorkoutRun) {
            WorkoutRunnerView(
                onFinish: {
                    showWorkoutRun = false
                    dismiss()
                    onWorkoutStarted()
                },
                onDiscard: {
                    showWorkoutRun = false
                    dismiss()
                }
            )
        }
    }
    
    private func startWorkout() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        trainingService.startWorkout()
        showWorkoutRun = true
    }
}

// MARK: - Preview
#Preview {
    StartWorkoutSheet(
        trainingService: TrainingService(),
        onWorkoutStarted: {}
    )
}

