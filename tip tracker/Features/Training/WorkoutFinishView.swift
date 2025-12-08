//
//  WorkoutFinishView.swift
//  EverForm
//
//  Workout completion screen with summary and notes
//  Applied: T-UI, S-OBS2, P-ARCH, C-SIMPLE, R-LOGS
//
//

import SwiftUI

struct WorkoutFinishView: View {
    let summary: WorkoutHistorySummary
    @Environment(WorkoutCoordinator.self) private var workoutCoordinator
    
    @State private var notes: String = ""
    @State private var showToast = false
    
    var body: some View {
        EFScreenContainer {
            VStack(spacing: 0) {
                EFHeader(title: "Workout Complete!", showBack: false)
                
                ScrollView {
                    VStack(spacing: EverFormTheme.Spacing.sectionSpacing) {
                        // Title
                        Text(summary.title)
                            .font(EverFormTheme.Typography.cardTitle)
                            .foregroundColor(EverFormTheme.Colors.textSecondary)
                            .padding(.horizontal, 20)
                        
                        // Summary Cards
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                SummaryCard(
                                    title: "Duration",
                                    value: summary.formattedDuration,
                                    icon: "clock.fill",
                                    color: EverFormTheme.Colors.infoBlue
                                )
                                
                                SummaryCard(
                                    title: "Total Volume",
                                    value: summary.formattedVolume,
                                    icon: "scalemass.fill",
                                    color: EverFormTheme.Colors.successGreen
                                )
                            }
                            
                            HStack(spacing: 16) {
                                SummaryCard(
                                    title: "Sets Logged",
                                    value: "\(summary.totalSets)",
                                    icon: "list.bullet.circle.fill",
                                    color: EverFormTheme.Colors.trainingGreen
                                )
                                
                                SummaryCard(
                                    title: "Total Reps",
                                    value: "\(summary.totalReps)",
                                    icon: "number.circle.fill",
                                    color: EverFormTheme.Colors.warningAmber
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Notes Section
                        VStack(alignment: .leading, spacing: 12) {
                            EFSectionHeader(title: "Workout Notes")
                            
                            TextEditor(text: $notes)
                                .font(EverFormTheme.Typography.body)
                                .padding(12)
                                .background(EverFormTheme.Colors.card)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(EverFormTheme.Colors.cardStroke, lineWidth: 1)
                                )
                                .frame(height: 120)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 40)
                        
                        // Save Button
                        VStack(spacing: 16) {
                            EFPrimaryButton("Save Workout", color: EverFormTheme.Colors.trainingGreen) {
                                saveWorkout()
                            }
                            
                            Button("Cancel") {
                                workoutCoordinator.closeAll()
                            }
                            .font(EverFormTheme.Typography.button)
                            .foregroundColor(EverFormTheme.Colors.textSecondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                    .padding(.top, 20)
                }
            }
            
            // Toast Overlay
            if showToast {
                VStack {
                    Spacer()
                    Text("Workout saved successfully!")
                        .font(EverFormTheme.Typography.body)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(EverFormTheme.Colors.successGreen)
                        .clipShape(Capsule())
                        .padding(.bottom, 60)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .zIndex(100)
            }
        }
    }
    
    private func saveWorkout() {
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        
        withAnimation { showToast = true }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            workoutCoordinator.completeWorkout()
        }
    }
}

// MARK: - Summary Card Component

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        EFCard {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(spacing: 4) {
                    Text(value)
                        .font(EverFormTheme.Typography.cardTitle)
                        .foregroundColor(EverFormTheme.Colors.textPrimary)
                    
                    Text(title)
                        .font(EverFormTheme.Typography.caption)
                        .foregroundColor(EverFormTheme.Colors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    WorkoutFinishView(
        summary: WorkoutHistorySummary(
            title: "Upper Power",
            totalVolumeKg: 2450.0,
            totalSets: 18,
            totalReps: 162,
            durationSec: 4200
        )
    )
    .environment(WorkoutCoordinator())
}
