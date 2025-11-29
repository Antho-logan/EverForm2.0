//
//  MobilityPlanView.swift
//  EverForm
//
//  Created by Assistant on 27/11/2025.
//

import SwiftUI

struct MobilityPlanView: View {
    @ObservedObject var store: MobilityStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        EFScreenContainer {
            VStack(spacing: 0) {
                navigationHeader
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Greeting Header (Moved from Landing)
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
                        .padding(.horizontal, 20)
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
                            .padding(.horizontal, 20)
                        }
                        
                        // Dashboard Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Dashboard")
                                .font(DesignSystem.Typography.titleMedium())
                                .foregroundStyle(DesignSystem.Colors.textPrimary)
                                .padding(.horizontal, 20)
                            
                            MobilityDashboardView(store: store)
                                .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var navigationHeader: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    Text("Back")
                    .font(.app(.body))
                }
                .foregroundStyle(DesignSystem.Colors.accent)
            }
            
            Spacer()
            
            Text("Mobility Plan")
                .font(.app(.heading))
                .foregroundStyle(DesignSystem.Colors.textPrimary)
                
            Spacer()
            
            Button { } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
            }
            .hidden()
        }
        .padding(.horizontal, DesignSystem.Spacing.screenPadding)
        .padding(.vertical, 12)
        .background(DesignSystem.Colors.background)
    }
}
