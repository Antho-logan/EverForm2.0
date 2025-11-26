
import SwiftUI
import Observation
#if os(iOS)
import UIKit
#endif

@main
struct EverFormApp: App {
    @State private var appearance = AppearanceStore()
    @State private var themeManager = ThemeManager()

    // Own long-lived state here (create only for types that exist in the repo)
    @State private var appRouter          = AppRouter()
    @State private var workoutStore       = WorkoutStore()
    @State private var nutritionStore     = NutritionStore()
    @State private var hydrationService   = HydrationService()
    @State private var profileStore       = ProfileStore()
    @State private var notesStore         = ProfileNotesStore()
    @State private var attachmentStore    = AttachmentStore()


    init() {
        // Initial setup if needed
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appearance)
                // Inject Observation (@Observable) stores
                .environment(appRouter)
                .environment(workoutStore)
                .environment(nutritionStore)
                .environment(hydrationService)
                .environment(profileStore)
                .environment(notesStore)
                .environment(attachmentStore)
                .environment(themeManager)

                // ALSO inject as EnvironmentObject for any store that conforms to ObservableObject.
                // CoachCoordinator uses singleton pattern, so we don't inject it here
                .environmentObject(CoachCoordinator.shared)
                .background(themeManager.beigeBackground.ignoresSafeArea())
                .preferredColorScheme(themeManager.selectedTheme.colorScheme)
                .onAppear {
                    updateUIKitAppearance()
                }
                .onChange(of: themeManager.selectedTheme) { _, _ in
                    updateUIKitAppearance()
                }

                .task {
                    print("EverForm launched; stores injected")
                    checkOnboardingStatus()
                }
                .onChange(of: profileStore.hasCompletedOnboarding) { _, completed in
                    if !completed {
                        appRouter.fullScreen = .expressOnboarding
                    }
                }
        }
    }
    
    private func checkOnboardingStatus() {
        // If user hasn't completed onboarding, show express onboarding
        if !profileStore.hasCompletedOnboarding {
            appRouter.fullScreen = .expressOnboarding
        }
    }
    
    private func updateUIKitAppearance() {
        #if os(iOS)
        let backgroundColor = UIColor(themeManager.backgroundPrimary)
        let activeColor = UIColor(DesignSystem.Colors.accent)
        let inactiveColor = UIColor(themeManager.textSecondary)
        
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = backgroundColor
        
        let layouts = [
            tabAppearance.stackedLayoutAppearance,
            tabAppearance.inlineLayoutAppearance,
            tabAppearance.compactInlineLayoutAppearance
        ]
        
        layouts.forEach { appearance in
            appearance.normal.iconColor = inactiveColor
            appearance.normal.titleTextAttributes = [.foregroundColor: inactiveColor]
            appearance.selected.iconColor = activeColor
            appearance.selected.titleTextAttributes = [.foregroundColor: activeColor]
        }
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            switch themeManager.selectedTheme {
            case .dark: window.overrideUserInterfaceStyle = .dark
            case .light: window.overrideUserInterfaceStyle = .light
            case .system: window.overrideUserInterfaceStyle = .unspecified
            }
        }
        #endif
    }
}
