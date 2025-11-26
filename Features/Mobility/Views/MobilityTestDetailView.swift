//
//  MobilityTestDetailView.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

import SwiftUI

struct MobilityTestDetailView: View {
    let test: MobilityTest
    @ObservedObject var store: MobilityStore
    @State private var selectedScore: Int = 3
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Video Placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black)
                        .aspectRatio(16/9, contentMode: .fit)
                    
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.8))
                    
                    VStack {
                        Spacer()
                        Text("Demo Video Placeholder")
                            .font(DesignSystem.Typography.caption())
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.bottom, 8)
                    }
                }
                .padding(.horizontal)
                
                // Header
                VStack(spacing: 8) {
                    Text(test.name)
                        .font(DesignSystem.Typography.displaySmall())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(test.shortDescription)
                        .font(DesignSystem.Typography.bodyMedium())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
                .padding(.horizontal)
                
                // Instructions
                VStack(alignment: .leading, spacing: 16) {
                    Text("Instructions")
                        .font(DesignSystem.Typography.titleSmall())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(test.instructions.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(DesignSystem.Typography.labelSmall())
                                    .frame(width: 24, height: 24)
                                    .background(DesignSystem.Colors.neutral100.opacity(0.1))
                                    .clipShape(Circle())
                                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                                
                                Text(step)
                                    .font(DesignSystem.Typography.bodyMedium())
                                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .padding(16)
                .background(DesignSystem.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                
                // Scoring Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Score Yourself")
                        .font(DesignSystem.Typography.titleSmall())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    Text(test.resultScaleDescription)
                        .font(DesignSystem.Typography.bodyMedium())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .italic()
                    
                    Picker("Score", selection: $selectedScore) {
                        ForEach(1...5, id: \.self) { score in
                            Text("\(score)").tag(score)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 8)
                }
                .padding(16)
                .background(DesignSystem.Colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                
                Spacer(minLength: 20)
                
                // Actions
                VStack(spacing: 16) {
                    Button {
                        saveAndContinue()
                    } label: {
                        Text("Save result")
                            .font(DesignSystem.Typography.buttonLarge())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(DesignSystem.Colors.accent)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Skip this test")
                            .font(DesignSystem.Typography.buttonMedium())
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding(.top)
        }
        .background(DesignSystem.Colors.background.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func saveAndContinue() {
        let result = MobilityTestResult(
            id: UUID(),
            testId: test.id,
            score: selectedScore,
            date: Date()
        )
        store.saveResult(result)
        dismiss()
    }
}

