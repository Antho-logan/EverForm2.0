//
//  EverFormApp.swift
//  EverForm
//
//  Created by Anthony Logan on 13/08/2025.
//

import SwiftUI
import Observation

@main
struct EverFormApp: App {
    @State private var appearance = AppearanceStore()
    
    // Own long-lived state here (create only for types that exist in the repo)
    @State private var appRouter          = AppRouter()
    @State private var workoutStore       = WorkoutStore()
    @State private var nutritionStore     = NutritionStore()
    @State private var hydrationService   = HydrationService()
    @State private var profileStore       = ProfileStore()
    @State private var notesStore         = ProfileNotesStore()
    @State private var attachmentStore    = AttachmentStore()
    @State private var themeManager       = ThemeManager()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(appearance)
                .preferredColorScheme(appearance.preferredColorScheme)
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

                .onAppear { 
                    print("EverForm launched; stores injected")
                    checkOnboardingStatus()
                }
        }
    }
    
    private func checkOnboardingStatus() {
        // If user hasn't completed onboarding, show express onboarding
        if !profileStore.hasCompletedOnboarding {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                appRouter.fullScreen = .expressOnboarding
            }
        }
    }
}
