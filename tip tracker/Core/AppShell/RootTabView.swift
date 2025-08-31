import SwiftUI
import Observation

/// Root tab shell using unified AppRouter for all navigation
struct RootTabView: View {
    @Environment(AppRouter.self) private var router
    @Environment(ProfileStore.self) private var profileStore
    @Environment(ThemeManager.self) private var themeManager
    @State private var onboardingStore = OnboardingStore()
    @State private var showOnboarding = false
    @State private var dashboardViewModel = DashboardViewModel()

    // Local sheet state for quick actions (not menu-driven)
    @State private var showWorkoutSession = false
    @State private var showBreathwork = false
    @State private var showWater = false
    @State private var showMoreSheet = false
    
    private var selectedTabBinding: Binding<AppRouter.Tab> {
        Binding(get: { router.selectedTab }, set: { router.selectedTab = $0 })
    }

    var body: some View {
        ZStack(alignment: .leading) {

            // ==== MAIN TABS ====
            TabView(selection: selectedTabBinding) {

                // OVERVIEW
                NavigationStack {
                    OverviewView(
                        viewModel: dashboardViewModel,
                        openExplain: { _, _ in },
                        onScanCalories: { },
                        onQuickMeal: { },
                        onStartMobility: { }
                    )
                }
                .tabItem { Label("Overview", systemImage: "house") }
                .tag(AppRouter.Tab.overview)

                // COACH
                NavigationStack {
                    CoachView()
                }
                .tabItem { Label("Coach", systemImage: "brain.head.profile") }
                .tag(AppRouter.Tab.coach)

                // SCAN
                NavigationStack {
                    ScanView()
                }
                .tabItem { Label("Scan", systemImage: "camera.viewfinder") }
                .tag(AppRouter.Tab.scan)

                // MORE
                Color.clear
                    .onAppear {
                        showMoreSheet = true
                    }
                .tabItem { Label("More", systemImage: "ellipsis.circle") }
                .tag(AppRouter.Tab.more)
            }
            .onAppear {
                setupTabBarAppearance()
            }
            .onChange(of: router.selectedTab) { _, newTab in
                // Add haptic feedback and animation on tab change
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()

                // Add subtle spring animation
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    // Animation will be handled by the tab bar appearance
                }
            }

            // ==== SCRIM when drawer is open ====
            if router.isSideMenuOpen {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture { 
                        UX.Haptic.light()
                        withAnimation(UX.Anim.snappy()) {
                            router.isSideMenuOpen = false 
                        }
                    }
                    .zIndex(1)
                    .transition(.opacity)
            }

            // ==== DRAWER ====
            DrawerMenu(onClose: { 
                UX.Haptic.light()
                withAnimation(UX.Anim.snappy()) {
                    router.isSideMenuOpen = false 
                }
            })
                .frame(maxWidth: 320)
                .offset(x: router.isSideMenuOpen ? 0 : -340)
                .shadow(radius: 10)
                .zIndex(2)
                .allowsHitTesting(router.isSideMenuOpen)   // when closed, do not block taps
                .accessibilityHidden(!router.isSideMenuOpen)
                .animation(UX.Anim.snappy(), value: router.isSideMenuOpen)
        }
        .overlay(alignment: .top) {
            ErrorBannerView()
                .zIndex(999)
        }
        .environment(onboardingStore)
        .onAppear {
            showOnboarding = !onboardingStore.isCompleted
        }
        // ==== ONBOARDING FULL SCREEN COVER ====
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingFlow()
                .environment(profileStore)
        }
        // ==== FULL SCREEN COVERS FOR MENU-DRIVEN ACTIONS ====
        .fullScreenCover(item: Binding<AppRouter.FullScreen?>(
            get: { router.fullScreen },
            set: { router.fullScreen = $0 }
        )) { screen in
            NavigationStack {
                switch screen {
                case .logMeal:
                    LogMealSheet(
                        onScanCalories: {
                            router.closeFullScreen()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                router.go(.scan)
                            }
                        },
                        onClose: { router.closeFullScreen() }
                    )
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarCloseButton { router.closeFullScreen() }
                case .startWorkout:
                    TodayPlanSheet(
                        onStartWorkout: {
                            router.closeFullScreen()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                showWorkoutSession = true
                            }
                        },
                        onClose: { router.closeFullScreen() }
                    )
                    .navigationBarTitleDisplayMode(.inline)
                case .mobility:
                    MobilityRoutineSheet(onClose: { router.closeFullScreen() })
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarCloseButton { router.closeFullScreen() }
                case .sleep:
                    SleepRoutineSheet(onClose: { router.closeFullScreen() })
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarCloseButton { router.closeFullScreen() }
                case .nutritionTrends:
                    WeeklyTrendsView(onClose: { router.closeFullScreen() })
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarCloseButton { router.closeFullScreen() }
                case .workoutHistory:
                    WorkoutHistoryListView(onClose: { router.closeFullScreen() })
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarCloseButton { router.closeFullScreen() }
                case .settings:
                    SettingsView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarCloseButton { router.closeFullScreen() }
                case .expressOnboarding:
                    ExpressOnboardingView()
                case .advancedProfile:
                    AdvancedProfileView()
                case .editProfile:
                    OnboardingFlow()
                case .profile:
                    AdvancedProfileView()
                }
            }
        }
        
        // ==== FULL SCREEN COVERS FOR QUICK ACTIONS ====
        .fullScreenCover(isPresented: $showWorkoutSession) {
            NavigationStack {
                WorkoutRunnerView(
                    onFinish: { showWorkoutSession = false },
                    onDiscard: { showWorkoutSession = false }
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbarCloseButton { showWorkoutSession = false }
            }
            .interactiveDismissDisabled() // don't lose a session by swipe
        }
        .sheet(isPresented: $showBreathwork) {
            NavigationStack {
                BreathworkSheet(onClose: { showBreathwork = false })
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarCloseButton { showBreathwork = false }
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showWater) {
            NavigationStack {
                WaterQuickAddSheet(onClose: { showWater = false })
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarCloseButton { showWater = false }
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showMoreSheet) {
            VStack {
                Text("More Options")
                Text("Coming Soon")
            }
            .presentationDetents([.medium, .large])
                .onDisappear {
                    // Return to previous tab when more sheet is dismissed
                    if router.selectedTab == .more {
                        router.selectedTab = .overview
                    }
                }
        }
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()

        // Frosted background effect
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        appearance.backgroundColor = UIColor.clear
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.1)

        // Normal state (inactive tabs) - smaller icons, no labels
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Theme.palette(.light).textSecondary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.clear, // Hide labels for inactive tabs
            .font: UIFont.systemFont(ofSize: 0, weight: .medium)
        ]
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 100)

        // Selected state (active tab) - larger icons, show labels
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Theme.palette(.light).accent)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Theme.palette(.light).accent),
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 0)

        // Apply the appearance
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance

        // Add corner radius and shadow
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let tabBar = window.rootViewController?.view.subviews.first(where: { $0 is UITabBar }) as? UITabBar {
                tabBar.layer.cornerRadius = 24
                tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                tabBar.layer.shadowColor = UIColor.black.cgColor
                tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
                tabBar.layer.shadowRadius = 8
                tabBar.layer.shadowOpacity = 0.1
            }
        }
    }
}

#Preview { 
    RootTabView()
        .environment(AppRouter())
        .environment(WorkoutStore())
        .environment(NutritionStore())
        .environment(HydrationService())
        .environment(ProfileStore())
        .environment(ProfileNotesStore())
        .environment(AttachmentStore())
        .environment(OnboardingStore())
        .environment(ThemeManager())
        .environmentObject(CoachCoordinator.shared)
}