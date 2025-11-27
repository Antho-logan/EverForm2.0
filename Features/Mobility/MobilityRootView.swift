//
//  MobilityRootView.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

import SwiftUI

struct MobilityHomeView: View {
    @StateObject private var store = MobilityStore.shared
    
    var body: some View {
        // No NavigationStack here - pushed from Overview
        EFScreenContainer {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Greeting Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hi, \(store.userName)")
                            .font(DesignSystem.Typography.displaySmall())
                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                        
                        HStack {
                            Label(store.primaryGoal.rawValue, systemImage: "target")
                            Text("•")
                            Label(store.primarySport.rawValue, systemImage: "figure.run")
                        }
                        .font(DesignSystem.Typography.caption())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // Hero Routines Pager
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(store.routines) { routine in
                                NavigationLink(destination: MobilityRoutineDetailView(routine: routine)) {
                                    MobilityRoutineCard(routine: routine)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Dashboard Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Dashboard")
                            .font(DesignSystem.Typography.titleMedium())
                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                            .padding(.horizontal)
                        
                        MobilityDashboardView(store: store)
                            .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("Mobility")
            .navigationBarTitleDisplayMode(.inline)
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
