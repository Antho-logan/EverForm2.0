//
//  RecoveryInsightDetailView.swift
//  EverForm
//
//  Created by Assistant on 07/12/2025.
//

import SwiftUI

struct RecoveryInsightDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let insight: RecoveryDailyInsights?
    
    var body: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if let insight = insight {
                            // Headline
                            Text(insight.headline)
                                .font(DesignSystem.Typography.displaySmall())
                                .foregroundStyle(DesignSystem.Colors.textPrimary)
                                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                                .padding(.top, 24)
                            
                            // Main Summary
                            EFCard {
                                Text(insight.summary)
                                    .font(.app(.body))
                                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                                    .lineSpacing(6)
                            }
                            .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                            
                            // Key Issues / Focus
                            if !insight.keyIssues.isEmpty && insight.keyIssues != ["None"] {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Key Observations")
                                        .font(.app(.heading))
                                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                                        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                                    
                                    ForEach(insight.keyIssues, id: \.self) { issue in
                                        HStack(alignment: .top, spacing: 12) {
                                            Image(systemName: "info.circle")
                                                .foregroundStyle(DesignSystem.Colors.accent)
                                            Text(issue)
                                                .font(.app(.bodySecondary))
                                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                                        }
                                        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                                    }
                                }
                            }
                            
                        } else {
                            Text("No insight details available.")
                                .font(.app(.body))
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                                .padding()
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(title)
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
