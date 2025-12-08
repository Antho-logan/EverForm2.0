//
//  WeeklyRecoveryPlanView.swift
//  EverForm
//
//  Created by Assistant on 07/12/2025.
//

import SwiftUI

struct WeeklyRecoveryPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: RecoveryDashboardViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Weekly Recovery Focus")
                                .font(.app(.largeTitle))
                                .foregroundStyle(DesignSystem.Colors.textPrimary)
                            
                            Text("Key focus areas for this week based on your recent data.")
                                .font(.app(.bodySecondary))
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                        .padding(.top, 24)
                        
                        // Focus Areas
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.weeklyFocusAreas) { area in
                                FocusAreaCard(area: area)
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                        
                        if viewModel.weeklyFocusAreas.isEmpty {
                            // Fallback / Empty State
                            Text("No specific focus areas identified yet. Keep logging your sleep!")
                                .font(.app(.body))
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                                .padding()
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
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
    }
}

struct FocusAreaCard: View {
    let area: WeeklyRecoveryFocusArea
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(area.title)
                        .font(.app(.heading))
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    Text(area.description)
                        .font(.app(.body))
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            
            Divider()
            
            // Actions
            VStack(alignment: .leading, spacing: 12) {
                Text("Action Plan")
                    .font(.app(.label))
                    .foregroundStyle(DesignSystem.Colors.textTertiary)
                    .textCase(.uppercase)
                
                ForEach(area.actions, id: \.self) { action in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "circle")
                            .font(.system(size: 10))
                            .foregroundStyle(DesignSystem.Colors.accent)
                            .padding(.top, 6)
                        
                        Text(action)
                            .font(.app(.bodySecondary))
                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(20)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

