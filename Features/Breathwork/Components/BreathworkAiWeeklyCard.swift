//
//  BreathworkAiWeeklyCard.swift
//  EverForm
//
//  Created by Assistant on 07/12/2025.
//

import SwiftUI

struct BreathworkAiWeeklyCard: View {
    let state: BreathworkStore.BreathworkAiLoadState
    let data: BreathworkAiWeeklyInsightViewData?

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
            ProgressView()
                .tint(DesignSystem.Colors.accent)
            Text("Loading weekly insights...")
                .font(DesignSystem.Typography.caption())
                .foregroundStyle(DesignSystem.Colors.textSecondary)
            Spacer()
        }
        .padding(16)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var fallbackCard: some View {
        // Only show if loaded but empty, or error. 
        // Ideally we might hide it, but requirement says "friendly text".
        HStack(spacing: 16) {
            Image(systemName: "chart.bar.doc.horizontal")
                .foregroundStyle(DesignSystem.Colors.neutral400)
            Text("Check back next week for insights.")
                .font(DesignSystem.Typography.caption())
                .foregroundStyle(DesignSystem.Colors.textSecondary)
            Spacer()
        }
        .padding(16)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func contentCard(data: BreathworkAiWeeklyInsightViewData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(DesignSystem.Colors.accent)
                        .font(.system(size: 14))
                    Text(data.headline)
                        .font(DesignSystem.Typography.titleSmall())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                }
                
                Spacer()
                
                Text(data.periodLabel)
                    .font(DesignSystem.Typography.caption())
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(DesignSystem.Colors.neutral100.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            // Insight Body
            VStack(alignment: .leading, spacing: 8) {
                Text(data.insightText)
                    .font(DesignSystem.Typography.bodyMedium())
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 4) {
                    Text("Focus:")
                        .font(DesignSystem.Typography.labelSmall())
                        .foregroundStyle(DesignSystem.Colors.textTertiary)
                    Text(data.recommendedFocus)
                        .font(DesignSystem.Typography.labelSmall())
                        .foregroundStyle(DesignSystem.Colors.accent)
                }
                .padding(.top, 4)
            }
            
            Divider()
                .background(DesignSystem.Colors.neutral200)
            
            // Footer Stats
            HStack {
                Text(data.statsSummary)
                    .font(DesignSystem.Typography.caption())
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                
                Spacer()
                
                // Tags
                ForEach(data.focusTags.prefix(2), id: \.self) { tag in
                    Text(tag)
                        .font(DesignSystem.Typography.caption())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(DesignSystem.Colors.neutral100.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}





