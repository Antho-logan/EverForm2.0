//
//  MobilityRootView.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

import SwiftUI

struct MobilityHomeView: View {
    @StateObject private var store = MobilityStore.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingFullDashboard = false
    
    var body: some View {
        // No NavigationStack here - pushed from Overview
        EFScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        HStack(alignment: .top) {
                            Spacer()
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(DesignSystem.Colors.neutral400)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        FeatureHeroCard(
                            title: "Mobility",
                            subtitle: "Protect your joints and stay flexible with daily routines.",
                            buttonTitle: "Open Mobility Plan",
                            onButtonTap: { showingFullDashboard = true },
                            gradientColors: [Color.purple.opacity(0.6), Color.purple.opacity(0.3)]
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // Recent Mobility
                    FeatureHistorySection(title: "Recent Routines") {
                        VStack(spacing: 12) {
                            FeatureHistoryRow(
                                title: "Morning Flow",
                                subtitle: "Today • 15 min",
                                detail: "Completed",
                                icon: "figure.flexibility",
                                iconColor: .purple
                            ) { /* Action */ }
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationDestination(isPresented: $showingFullDashboard) {
            MobilityPlanView(store: store)
        }
    }
}

struct MobilityRoutineCard: View {
    let routine: MobilityRoutine
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image placeholder gradient
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [
                        cardGradientColor(for: routine.type).opacity(0.8),
                        cardGradientColor(for: routine.type).opacity(0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(routine.type.rawValue.uppercased())
                        .font(DesignSystem.Typography.labelSmall())
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.black.opacity(0.3))
                        .clipShape(Capsule())
                    
                    Text(routine.title)
                        .font(DesignSystem.Typography.titleMedium())
                        .foregroundStyle(.white)
                }
                .padding(16)
            }
            .frame(height: 140)
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("\(routine.durationMinutes) min", systemImage: "clock")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(DesignSystem.Colors.neutral400)
                }
                .font(DesignSystem.Typography.caption())
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                
                HStack {
                    ForEach(routine.focusAreas.prefix(2)) { area in
                        Text(area.rawValue)
                            .font(DesignSystem.Typography.labelSmall())
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(DesignSystem.Colors.neutral100.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(16)
            .background(DesignSystem.Colors.cardBackground)
        }
        .frame(width: 260)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4, y: 2)
    }
    
    func cardGradientColor(for type: MobilityRoutine.RoutineType) -> Color {
        switch type {
        case .daily: return .blue
        case .activate: return .orange
        case .recover: return .purple
        case .deepReset: return .indigo
        }
    }
}

