//
//  BreathworkHomeView.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import SwiftUI
import Observation

struct BreathworkHomeView: View {
    @State private var store = BreathworkStore.mock()
    @Environment(\.dismiss) private var dismiss
    @State private var showingFullDashboard = false
    @State private var startSession = false // To trigger navigation to session
    
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
                        // Back Button Row
                        HStack {
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
                            title: "Breathwork",
                            subtitle: "Calm your nervous system with guided breathing.",
                            buttonTitle: "Start Session",
                            onButtonTap: {
                                handleStartSession()
                            },
                            gradientColors: [Color.green.opacity(0.5), Color.teal.opacity(0.3)]
                        )
                        .padding(.horizontal, 20)
                        
                        // Recent Sessions
                        FeatureHistorySection(title: "Recent Sessions") {
                            VStack(spacing: 12) {
                                FeatureHistoryRow(
                                    title: "Box Breathing",
                                    subtitle: "Today • 5 min",
                                    detail: "Completed",
                                    icon: "wind",
                                    iconColor: .teal
                                ) { /* Action */ }
                            }
                        }
                        .padding(.bottom, 8)
                        
                    }
                    .background(DesignSystem.Colors.background.opacity(0.95))
                }
            }
        }
        .navigationDestination(isPresented: $showingFullDashboard) {
            BreathworkFullDashboardView(store: store, selectedTab: $selectedTab)
        }
        .navigationDestination(isPresented: $startSession) {
            if let pattern = store.activeSessionPattern {
                LiveBreathworkSessionView(pattern: pattern)
                    .environment(store) // Explicitly pass store to avoid environment crashes
            } else {
                Text("Error starting session")
                    .onAppear {
                        print("[Breathwork] ERROR: Navigation triggered with no activeSessionPattern")
                    }
            }
        }
        .environment(store)
    }
    
    private func handleStartSession() {
        print("[Breathwork] Start Session tapped")
        
        // Safe start logic: ensure we have a pattern to run
        // Prioritize default (Box) -> First Available -> Fallback
        let pattern = store.defaultPattern ?? store.makeFallbackPattern()
            
        print("[Breathwork] Starting session with pattern: \(pattern.displayName)")
        
        store.activeSessionPattern = pattern
        startSession = true
    }
}

struct BreathworkFullDashboardView: View {
    @Bindable var store: BreathworkStore
    @Binding var selectedTab: BreathworkHomeView.BreathworkTab
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Segmented Control
            HStack(spacing: 0) {
                ForEach(BreathworkHomeView.BreathworkTab.allCases, id: \.self) { tab in
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
            .padding(.top, 10)
            .background(DesignSystem.Colors.background)
            
            // Content
            TabView(selection: $selectedTab) {
                BreathworkPracticeView()
                    .tag(BreathworkHomeView.BreathworkTab.practice)
                
                BreathworkProgramsView()
                    .tag(BreathworkHomeView.BreathworkTab.programs)
                
                BreathworkInsightsView()
                    .tag(BreathworkHomeView.BreathworkTab.insights)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("Breathwork Dashboard")
        .navigationBarTitleDisplayMode(.inline)
    }
}
