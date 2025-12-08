//
//  RecoveryPlanSheet.swift
//  EverForm
//
//  Created by Assistant on 07/12/2025.
//

import SwiftUI

struct RecoveryPlanSheet: View {
    @ObservedObject var viewModel: RecoveryDashboardViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.background
                    .ignoresSafeArea()
                
                content
            }
            .navigationTitle("Smart Recovery Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.app(.body))
                    .foregroundStyle(DesignSystem.Colors.accent)
                }
            }
        }
        .task {
            print("📄 [RecoveryPlanSheet] appeared")
            if case .idle = viewModel.planState {
                viewModel.loadDayPlan()
            }
        }
        .onDisappear {
            print("📄 [RecoveryPlanSheet] dismissed")
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.planState {
        case .idle, .loading:
            loadingView
        case .loaded(let plan):
            planView(plan)
        case .error(let message):
            errorView(message)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Generating tonight's recovery protocol...")
                .font(.app(.body))
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Text("This can take a few seconds")
                .font(.app(.caption))
                .foregroundStyle(DesignSystem.Colors.textTertiary)
        }
    }
    
    private func planView(_ plan: RecoveryDayPlan) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(plan.headline)
                        .font(.app(.title))
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    HStack {
                        Image(systemName: "moon.stars.fill")
                            .foregroundStyle(DesignSystem.Colors.accent)
                        Text(plan.planType.capitalized + " Protocol")
                            .font(.app(.bodySecondary))
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                .padding(.top, 24)
                
                // Steps with Checklist
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tonight's Checklist")
                        .font(.app(.heading))
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                    
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.smartPlanSteps) { step in
                            stepRow(step)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                }
                
                // Footer
                Text("This plan is adapted to your recent sleep data and recovery score.")
                    .font(.app(.caption))
                    .foregroundStyle(DesignSystem.Colors.textTertiary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
            }
        }
    }
    
    private func stepRow(_ step: RecoveryPlanStepUI) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                viewModel.togglePlanStep(id: step.id)
            }
        } label: {
            HStack(alignment: .top, spacing: 16) {
                
                // Timing & Checkbox
                VStack(spacing: 6) {
                    ZStack {
                        if step.isCompleted {
                            Circle()
                                .fill(DesignSystem.Colors.success)
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        } else {
                            Circle()
                                .stroke(DesignSystem.Colors.neutral300, lineWidth: 2)
                                .frame(width: 32, height: 32)
                        }
                    }
                    
                    if let minutes = step.relativeMinutes, minutes < 0 {
                        Text("T\(minutes)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(DesignSystem.Colors.textTertiary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(step.title)
                        .font(.app(.heading))
                        .foregroundStyle(step.isCompleted ? DesignSystem.Colors.textSecondary : DesignSystem.Colors.textPrimary)
                        .strikethrough(step.isCompleted)
                    
                    Text(step.description)
                        .font(.app(.body))
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .opacity(step.isCompleted ? 0.7 : 1.0)
                }
                
                Spacer()
            }
            .padding(16)
            .background(DesignSystem.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundStyle(.red)
            
            Text("We couldn't generate a plan right now.")
                .font(.app(.heading))
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(.app(.body))
                .foregroundStyle(DesignSystem.Colors.textSecondary)
            
            Button("Try Again") {
                viewModel.loadDayPlan(force: true)
            }
            .font(.app(.button))
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(DesignSystem.Colors.accent)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.top, 8)
        }
        .padding(32)
    }
}
