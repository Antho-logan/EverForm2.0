//
//  PremiumDashboard.swift
//  EverForm
//
//  Created by Assistant on 14/01/2025.
//  Premium Dashboard with Enhanced Design System
//

import SwiftUI

// MARK: - Dashboard View Model (Preserved Logic)
@Observable
final class PremiumDashboardViewModel {
    var selectedTab: DashboardTab = .overview
    var userName: String = "Anthony"
    
    // MARK: - Mock data for demonstration
    var todaysWorkouts: Int = 2
    var weeklyGoal: Int = 5
    var currentStreak: Int = 7
    
    enum DashboardTab: String, CaseIterable {
        case overview = "Overview"
        case training = "Training"
        case nutrition = "Nutrition"
        case progress = "Progress"
        
        var iconName: String {
            switch self {
            case .overview: return "house.fill"
            case .training: return "dumbbell.fill"
            case .nutrition: return "leaf.fill"
            case .progress: return "chart.line.uptrend.xyaxis"
            }
        }
        
        var accessibilityHint: String {
            switch self {
            case .overview: return "View your daily overview and quick stats"
            case .training: return "Access your workout plans and training programs"
            case .nutrition: return "Track your meals and nutrition goals"
            case .progress: return "View your fitness progress and analytics"
            }
        }
    }
    
    func selectTab(_ tab: DashboardTab) {
        selectedTab = tab
        print("Selected tab: \(tab.rawValue) - R-LOGS") // R-LOGS: Debug logging
    }
}

// MARK: - Premium Dashboard View
struct PremiumDashboardView: View {
    let themeManager: ThemeManager
    let onLogout: () -> Void
    @State private var viewModel = PremiumDashboardViewModel()
    @State private var selectedTabIndex = 0
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Premium Navigation Bar
                NavBar(
                    title: "Good morning, \(viewModel.userName)",
                    subtitle: "Ready to crush your goals?",
                    onSettingsTap: {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        showingSettings = true
                        print("Settings tapped - R-LOGS") // R-LOGS: Debug logging
                    }
                )
                
                // Main Content Area
                ScrollView {
                    LazyVStack(spacing: DesignSystem.Spacing.sectionPadding) {
                        // Stats Cards Section
                        PremiumStatsSection(viewModel: viewModel)
                        
                        // Dynamic Tab Content
                        PremiumTabContent(
                            selectedTab: viewModel.selectedTab,
                            viewModel: viewModel
                        )
                    }
                    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                    .padding(.top, DesignSystem.Spacing.lg)
                }
                .background(DesignSystem.Colors.background)
                
                // Premium Tab Bar
                TabBarPrimary(
                    tabs: PremiumDashboardViewModel.DashboardTab.allCases.map { tab in
                        TabBarPrimary.TabItem(
                            title: tab.rawValue,
                            icon: tab.iconName,
                            accessibilityHint: tab.accessibilityHint
                        )
                    },
                    selectedTab: $selectedTabIndex
                )
                .onChange(of: selectedTabIndex) { _, newValue in
                    if let newTab = PremiumDashboardViewModel.DashboardTab.allCases.enumerated().first(where: { $0.offset == newValue })?.element {
                        viewModel.selectTab(newTab)
                    }
                }
            }
            .background(DesignSystem.Colors.background)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

// MARK: - Premium Stats Section
struct PremiumStatsSection: View {
    let viewModel: PremiumDashboardViewModel
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            StatCard(
                title: "Today's Workouts",
                value: "\(viewModel.todaysWorkouts)",
                subtitle: "of \(viewModel.weeklyGoal) weekly",
                accentColor: DesignSystem.Colors.accent
            ) {
                print("Workouts card tapped - R-LOGS") // R-LOGS: Debug logging
            }
            
            StatCard(
                title: "Current Streak",
                value: "\(viewModel.currentStreak)",
                subtitle: "days strong",
                accentColor: DesignSystem.Colors.success
            ) {
                print("Streak card tapped - R-LOGS") // R-LOGS: Debug logging
            }
        }
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: isVisible ? 0 : 20)
        .animation(DesignSystem.Animation.springSlow.delay(0.1), value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}

// MARK: - Premium Tab Content with Enhanced Animations
struct PremiumTabContent: View {
    let selectedTab: PremiumDashboardViewModel.DashboardTab
    let viewModel: PremiumDashboardViewModel
    
    var body: some View {
        ZStack {
            // Content with optimized slide animations (200ms as specified)
            Group {
                switch selectedTab {
                case .overview:
                    PremiumOverviewContent()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .training:
                    PremiumTrainingContent()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .nutrition:
                    PremiumNutritionContent()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .progress:
                    PremiumProgressContent()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .id(selectedTab) // Force view recreation for smooth transitions
        }
        .clipped()
        .animation(.easeInOut(duration: 0.2), value: selectedTab) // 200ms as specified
    }
}

// MARK: - Premium Content Views
struct PremiumOverviewContent: View {
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            PremiumContentCard(
                title: "Today's Focus",
                content: "Upper body strength training and 30 minutes of cardio",
                icon: "target",
                accentColor: DesignSystem.Colors.info
            )
            
            PremiumContentCard(
                title: "Nutrition Reminder",
                content: "Don't forget your post-workout protein shake!",
                icon: "bell.fill",
                accentColor: DesignSystem.Colors.warning
            )
            
            PremiumContentCard(
                title: "Quick Actions",
                content: "Log a workout • Track nutrition • View progress",
                icon: "bolt.fill",
                accentColor: DesignSystem.Colors.accent
            )
        }
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: isVisible ? 0 : 30)
        .animation(DesignSystem.Animation.springSlow, value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
        .onDisappear {
            isVisible = false
        }
    }
}

struct PremiumTrainingContent: View {
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            PremiumContentCard(
                title: "Training Hub",
                content: "Your personalized workout plans and exercise library will appear here.",
                icon: "dumbbell.fill",
                accentColor: DesignSystem.Colors.accent
            )
            
            PremiumContentCard(
                title: "Today's Workout",
                content: "Upper Body Strength • 45 minutes • 8 exercises",
                icon: "clock.fill",
                accentColor: DesignSystem.Colors.success
            )
        }
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: isVisible ? 0 : 30)
        .animation(DesignSystem.Animation.springSlow, value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
        .onDisappear {
            isVisible = false
        }
    }
}

struct PremiumNutritionContent: View {
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            PremiumContentCard(
                title: "Nutrition Tracker",
                content: "Track your meals, calories, and macronutrients to fuel your fitness journey.",
                icon: "leaf.fill",
                accentColor: DesignSystem.Colors.success
            )
            
            PremiumContentCard(
                title: "Today's Intake",
                content: "1,850 calories • 120g protein • 180g carbs • 65g fat",
                icon: "chart.pie.fill",
                accentColor: DesignSystem.Colors.info
            )
        }
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: isVisible ? 0 : 30)
        .animation(DesignSystem.Animation.springSlow, value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
        .onDisappear {
            isVisible = false
        }
    }
}

struct PremiumProgressContent: View {
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            PremiumContentCard(
                title: "Progress Analytics",
                content: "Visualize your fitness journey with comprehensive charts and insights.",
                icon: "chart.line.uptrend.xyaxis",
                accentColor: DesignSystem.Colors.accent
            )
            
            PremiumContentCard(
                title: "This Week's Progress",
                content: "5 workouts completed • 2,400 calories burned • 95% goal achievement",
                icon: "trophy.fill",
                accentColor: DesignSystem.Colors.warning
            )
        }
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: isVisible ? 0 : 30)
        .animation(DesignSystem.Animation.springSlow, value: isVisible)
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
        .onDisappear {
            isVisible = false
        }
    }
}

// MARK: - Premium Content Card with Icon
struct PremiumContentCard: View {
    let title: String
    let content: String
    let icon: String
    let accentColor: Color
    let onTap: (() -> Void)?
    
    @State private var isVisible = false
    
    init(
        title: String,
        content: String,
        icon: String,
        accentColor: Color = DesignSystem.Colors.accent,
        onTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.content = content
        self.icon = icon
        self.accentColor = accentColor
        self.onTap = onTap
    }
    
    var body: some View {
        CardDefault(onTap: onTap) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Icon Section
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: DesignSystem.IconSize.medium, weight: .semibold))
                        .foregroundColor(accentColor)
                }
                .opacity(isVisible ? 1.0 : 0.0)
                .scaleEffect(isVisible ? 1.0 : 0.8)
                .animation(DesignSystem.Animation.springSlow.delay(0.1), value: isVisible)
                
                // Content Section
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(title)
                        .font(DesignSystem.Typography.sectionHeader())
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .opacity(isVisible ? 1.0 : 0.0)
                        .offset(x: isVisible ? 0 : 20)
                        .animation(DesignSystem.Animation.springSlow.delay(0.2), value: isVisible)
                    
                    Text(content)
                        .font(DesignSystem.Typography.bodyMedium())
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.leading)
                        .opacity(isVisible ? 1.0 : 0.0)
                        .offset(x: isVisible ? 0 : 20)
                        .animation(DesignSystem.Animation.springSlow.delay(0.3), value: isVisible)
                }
                
                Spacer()
            }
        }
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
        .onDisappear {
            isVisible = false
        }
        .accessibilityLabel("\(title): \(content)")
    }
}

// MARK: - Preview
#Preview {
    PremiumDashboardView(
        themeManager: ThemeManager(),
        onLogout: { print("Logout preview") }
    )
}
