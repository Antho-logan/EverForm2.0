//
//  MobilityTestsOverviewView.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

import SwiftUI

struct MobilityTestsOverviewView: View {
    @ObservedObject var store: MobilityStore
    @StateObject private var aiViewModel = MobilityAiViewModel()
    @State private var showingSummary = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mobility Test")
                        .font(DesignSystem.Typography.displaySmall())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    
                    Text("Run through a 10–15 minute assessment to get your mobility score and unlock personalized plans.")
                        .font(DesignSystem.Typography.bodyMedium())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .lineSpacing(4)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                // Test List by Area
                VStack(spacing: 24) {
                    ForEach(store.tests) { test in
                        NavigationLink(destination: MobilityTestDetailView(test: test, store: store)) {
                            TestRow(test: test, isCompleted: isCompleted(test))
                        }
                    }
                }
                .padding(.horizontal)
                
                // Sticky-ish CTA
                VStack(spacing: 16) {
                    if allTestsCompleted {
                        Button {
                            Task {
                                await aiViewModel.submitAssessment(from: store, notes: nil)
                            }
                        } label: {
                            HStack {
                                if case .submitting = aiViewModel.assessmentState {
                                    ProgressView()
                                        .tint(.white)
                                        .padding(.trailing, 8)
                                    Text("Analyzing...")
                                } else {
                                    Text("Complete Assessment")
                                }
                            }
                            .font(DesignSystem.Typography.buttonLarge())
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(DesignSystem.Colors.accent)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(aiViewModel.assessmentState.isSubmitting)
                    } else {
                        NavigationLink(destination: MobilityTestDetailView(test: nextTest ?? store.tests.first!, store: store)) {
                            Text("Start guided test")
                                .font(DesignSystem.Typography.buttonLarge())
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(DesignSystem.Colors.accent)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    
                    if case .error(let msg) = aiViewModel.assessmentState {
                        Text(msg)
                            .font(DesignSystem.Typography.caption())
                            .foregroundStyle(DesignSystem.Colors.error)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                Spacer(minLength: 40)
            }
        }
        .background(DesignSystem.Colors.background.ignoresSafeArea())
        .navigationTitle("Assessment")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingSummary) {
            if let summary = aiViewModel.latestSummary {
                MobilityAssessmentSummaryView(summary: summary)
            }
        }
        .onChange(of: aiViewModel.assessmentState) { newState in
            if case .loaded = newState {
                showingSummary = true
            }
        }
    }
    
    var allTestsCompleted: Bool {
        // Simple check: do we have a result for every test ID?
        let testIds = Set(store.tests.map { $0.id })
        let resultIds = Set(store.results.map { $0.testId })
        return testIds.isSubset(of: resultIds)
    }
    
    var nextTest: MobilityTest? {
        store.tests.first { !isCompleted($0) }
    }
    
    func isCompleted(_ test: MobilityTest) -> Bool {
        store.results.contains { $0.testId == test.id }
    }
}

extension MobilityAiViewModel.AssessmentState {
    var isSubmitting: Bool {
        if case .submitting = self { return true }
        return false
    }
}


struct TestRow: View {
    let test: MobilityTest
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.neutral100.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: test.bodyArea.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isCompleted ? DesignSystem.Colors.success : DesignSystem.Colors.accent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(test.name)
                    .font(DesignSystem.Typography.titleSmall())
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                
                Text("\(test.estimatedDurationMinutes) min • \(test.bodyArea.rawValue)")
                    .font(DesignSystem.Typography.caption())
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
            
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(DesignSystem.Colors.success)
            } else {
                Image(systemName: "circle")
                    .foregroundStyle(DesignSystem.Colors.neutral400)
            }
        }
        .padding()
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

