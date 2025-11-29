import Foundation
import Observation
import SwiftUI

@Observable
final class AppSessionStore {
    var isSignedIn: Bool = false
    var hasCompletedOnboarding: Bool = false
    
    init() {
        self.isSignedIn = UserDefaults.standard.bool(forKey: "isAuthenticated")
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
    
    func signIn() {
        isSignedIn = true
        UserDefaults.standard.set(true, forKey: "isAuthenticated")
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
    
    func signOut() {
        // Clear local state
        isSignedIn = false
        hasCompletedOnboarding = false
        
        // Clear persistence
        UserDefaults.standard.removeObject(forKey: "isAuthenticated")
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: "onboarding_draft")
        UserDefaults.standard.removeObject(forKey: "onboarding_step_index")
        
        // Note: In a real app, we would also clear ProfileStore and potentially 
        // call a backend logout endpoint here.
    }
}

