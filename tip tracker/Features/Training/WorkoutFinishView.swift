//
//  WorkoutFinishView.swift
//  EverForm
//
//  Workout completion screen with summary and notes
//  Applied: T-UI, S-OBS2, P-ARCH, C-SIMPLE, R-LOGS
//

import SwiftUI

struct WorkoutFinishView: View {
    let summary: WorkoutHistorySummary
    @Environment(WorkoutCoordinator.self) private var workoutCoordinator
    
    @State private var notes: String = ""
    @State private var showToast = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Header
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Text("Workout Complete!")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(summary.title)
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, DesignSystem.Spacing.lg)
                    
                    // Summary Cards
                    VStack(spacing: DesignSystem.Spacing.md) {
                        HStack(spacing: DesignSystem.Spacing.md) {
                            SummaryCard(
                                title: "Duration",
                                value: summary.formattedDuration,
                                icon: "clock.fill",
                                color: DesignSystem.Colors.info
                            )
                            
                            SummaryCard(
                                title: "Total Volume",
                                value: summary.formattedVolume,
                                icon: "scalemass.fill",
                                color: DesignSystem.Colors.success
                            )
                        }
                        
                        HStack(spacing: DesignSystem.Spacing.md) {
                            SummaryCard(
                                title: "Sets Logged",
                                value: "\(summary.totalSets)",
                                icon: "list.bullet.circle.fill",
                                color: DesignSystem.Colors.accent
                            )
                            
                            SummaryCard(
                                title: "Total Reps",
                                value: "\(summary.totalReps)",
                                icon: "number.circle.fill",
                                color: DesignSystem.Colors.warning
                            )
                        }
                    }
                    
                    // Notes Section
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                        Text("Workout Notes")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        TextEditor(text: $notes)
                            .font(.system(size: 16, design: .rounded))
                            .padding(DesignSystem.Spacing.sm)
                            .background(DesignSystem.Colors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                                    .stroke(DesignSystem.Border.outlineColor, lineWidth: DesignSystem.Border.outline)
                            )
                            .frame(height: 120)
                    }
                    
                    Spacer(minLength: 40)
                    
                    // Save Button
                    ButtonPrimary("Save Workout") {
                        saveWorkout()
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                .padding(.vertical, DesignSystem.Spacing.lg)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        // Don't save, just close
                        workoutCoordinator.closeAll()
                    }
                }
            }
        }
        .presentationDetents([.large])
        .overlay(
            // Toast overlay
            VStack {
                Spacer()
                if showToast {
                    Text("Workout saved successfully!")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.green.opacity(0.9))
                        .clipShape(Capsule())
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showToast)
                }
            }
            .padding(.bottom, 100),
            alignment: .bottom
        )
    }
    
    private func saveWorkout() {
        DebugLog.info("Saving workout with notes: \(notes)")
        
        // Success haptic
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
        
        // Note: Workout is already saved by WorkoutStore.endSession(save: true)
        // This view just shows the summary and allows adding notes
        
        // Show success toast
        showToast = true
        
        // Close after showing toast
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            workoutCoordinator.completeWorkout()
        }
        
        // Hide toast
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showToast = false
            }
        }
        
        TelemetryService.shared.track("workout_summary_viewed", properties: [
            "title": summary.title,
            "duration_min": summary.durationSec / 60,
            "total_volume": summary.totalVolumeKg
        ])
    }
}

// MARK: - Summary Card Component

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.md)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                .stroke(DesignSystem.Border.outlineColor, lineWidth: DesignSystem.Border.outline)
        )
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
