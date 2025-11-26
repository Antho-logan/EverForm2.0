//
//  BreathworkHomeView.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import SwiftUI

struct BreathworkHomeView: View {
    @State private var store = BreathworkStore.mock()
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedTab: BreathworkTab = .practice
    
    enum BreathworkTab: String, CaseIterable {
        case practice = "Practice"
        case programs = "Programs"
        case insights = "Insights"
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                DesignSystem.Colors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Breathwork")
                                    .font(DesignSystem.Typography.displaySmall())
                                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                                
                                Text("Calm your nervous system")
                                    .font(DesignSystem.Typography.subheadline())
                                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                            }
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
                        .padding(.top, 10)
                        
                        // Custom Segmented Control
                        HStack(spacing: 0) {
                            ForEach(BreathworkTab.allCases, id: \.self) { tab in
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedTab = tab
                                    }
                                } label: {
                                    VStack(spacing: 8) {
                                        Text(tab.rawValue)
                                            .font(DesignSystem.Typography.labelLarge())
                                            .foregroundStyle(selectedTab == tab ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textSecondary)
                                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                                        
                                        Rectangle()
                                            .fill(selectedTab == tab ? DesignSystem.Colors.accent : Color.clear)
                                            .frame(height: 2)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .background(DesignSystem.Colors.background.opacity(0.95))
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        BreathworkPracticeView()
                            .tag(BreathworkTab.practice)
                        
                        BreathworkProgramsView()
                            .tag(BreathworkTab.programs)
                        
                        BreathworkInsightsView()
                            .tag(BreathworkTab.insights)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
        }
        .environment(store)
    }
}

