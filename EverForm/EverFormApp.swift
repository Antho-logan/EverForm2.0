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
    
    // Session State (Single Source of Truth for Auth/Onboarding gating)
    @State private var sessionStore       = AppSessionStore()
    
    // Onboarding Store (Local to App root, injected into onboarding flow)
    @State private var onboardingStore: OnboardingStore?

    init() {
        // Initial setup if needed
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if !sessionStore.isSignedIn {
                    if let store = onboardingStore {
                        AuthEntryView(onCreateAccount: {
                            // Legacy callback, effectively handled by AuthEntryView internal state now
                        })
                        .environment(store)
                    } else {
                        ProgressView()
                    }
                } else if !sessionStore.hasCompletedOnboarding {
                    // New Unified Onboarding Entry
                    if let store = onboardingStore {
                        OnboardingEntryFlowView(onOnboardingFinished: {
                            withAnimation {
                                sessionStore.completeOnboarding()
                            }
                        })
                        .environment(store)
                    } else {
                        ProgressView() // Should generally not happen or very briefly
                    }
                } else {
                    ContentView()
                }
            }
            .environment(sessionStore)
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
                if onboardingStore == nil {
                    onboardingStore = OnboardingStore(profileStore: profileStore)
                }
            }
            .onChange(of: themeManager.selectedTheme) { _, _ in
                updateUIKitAppearance()
            }
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
