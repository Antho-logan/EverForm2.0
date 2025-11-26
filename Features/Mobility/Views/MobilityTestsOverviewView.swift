//
//  MobilityTestsOverviewView.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

import SwiftUI

struct MobilityTestsOverviewView: View {
    @ObservedObject var store: MobilityStore
    
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
                    // Group tests by area logic if we wanted sections, 
                    // but for now just a flat list or sorted by area is fine.
                    // Let's just list them all.
                    
                    ForEach(store.tests) { test in
                        NavigationLink(destination: MobilityTestDetailView(test: test, store: store)) {
                            TestRow(test: test, isCompleted: isCompleted(test))
                        }
                    }
                }
                .padding(.horizontal)
                
                // Sticky-ish CTA
                NavigationLink(destination: MobilityTestDetailView(test: store.tests.first!, store: store)) {
                    Text("Start guided test")
                        .font(DesignSystem.Typography.buttonLarge())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(DesignSystem.Colors.accent)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .padding(.top, 16)
                
                Spacer(minLength: 40)
            }
        }
        .background(DesignSystem.Colors.background.ignoresSafeArea())
        .navigationTitle("Assessment")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func isCompleted(_ test: MobilityTest) -> Bool {
        store.results.contains { $0.testId == test.id }
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

