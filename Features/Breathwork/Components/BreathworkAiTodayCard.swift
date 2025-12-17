//
//  BreathworkAiTodayCard.swift
//  EverForm
//
//  Created by Assistant on 07/12/2025.
//

import SwiftUI

struct BreathworkAiTodayCard: View {
    let state: BreathworkStore.BreathworkAiLoadState
    let data: BreathworkAiTodaySuggestionViewData?
    let onApply: () -> Void

    var body: some View {
        Group {
            switch state {
            case .idle, .loading:
                loadingCard
            case .loaded:
                if let data = data {
                    contentCard(data: data)
                } else {
                    fallbackCard
                }
            case .error:
                fallbackCard
            }
        }
    }
    
    private var loadingCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.neutral100.opacity(0.1))
                    .frame(width: 48, height: 48)
                ProgressView()
                    .tint(DesignSystem.Colors.accent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("AI Suggestion")
                    .font(DesignSystem.Typography.titleSmall())
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                
                Text("Analyzing your breathing habits...")
                    .font(DesignSystem.Typography.caption())
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
            Spacer()
        }
        .padding(16)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var fallbackCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.neutral100.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: "sparkles")
                    .foregroundStyle(DesignSystem.Colors.neutral400)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("AI Suggestion")
                    .font(DesignSystem.Typography.titleSmall())
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                
                Text("We’ll suggest a pattern once you’ve logged a few sessions.")
                    .font(DesignSystem.Typography.caption())
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
            Spacer()
        }
        .padding(16)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
    
    private func contentCard(data: BreathworkAiTodaySuggestionViewData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [DesignSystem.Colors.accent.opacity(0.2), DesignSystem.Colors.accent.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "sparkles")
                        .foregroundStyle(DesignSystem.Colors.accent)
                        .font(.system(size: 20))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(data.title)
                        .font(DesignSystem.Typography.labelSmall())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .textCase(.uppercase)
                    
                    Text(data.patternName)
                        .font(DesignSystem.Typography.titleSmall())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                }
                
                Spacer()
            }
            
            Text(data.reason)
                .font(DesignSystem.Typography.bodyMedium())
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .lineLimit(3)
            
            // Chips
            if !data.focusTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(data.focusTags, id: \.self) { tag in
                            Text(tag)
                                .font(DesignSystem.Typography.caption())
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(DesignSystem.Colors.neutral100.opacity(0.1))
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            
            Button(action: onApply) {
                HStack {
                    Text("Apply Suggestion")
                    Spacer()
                    Text(data.doseText)
                        .font(DesignSystem.Typography.caption())
                        .opacity(0.8)
                }
                .font(DesignSystem.Typography.buttonMedium())
                .padding()
                .frame(maxWidth: .infinity)
                .background(DesignSystem.Colors.accent)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(20)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: DesignSystem.Colors.accent.opacity(0.1), radius: 12, x: 0, y: 6)
    }
}





