//
//  ProfileStore.swift
//  EverForm
//
//  Created by Anthony Logan on 23/08/2025.
//

import Foundation
import Observation

/// Main profile data store managing user profile and targets
@Observable
final class ProfileStore {

    var profile: UserProfile?
    var targets: UserTargets?
    var advanced: ProfileAdvanced = ProfileAdvanced()
    private let backend = BackendClient.shared
    
    // File URLs for persistence
    private var profileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("EverForm")
            .appendingPathComponent("profile.json")
    }
    
    private var targetsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("EverForm")
            .appendingPathComponent("targets.json")
    }
    
    private var advancedURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("EverForm")
            .appendingPathComponent("profile")
            .appendingPathComponent("advanced_profile.json")
    }
    
    /// Whether user has completed basic onboarding
    var hasCompletedOnboarding: Bool {
        return profile != nil && targets != nil
    }

    init() {
        loadProfile()
        loadTargets()
        Task { @MainActor in
            loadAdvanced()
        }
        
        // Fetch from backend as the source of truth
        Task { await syncFromBackend() }
    }
    
    /// Save profile and targets together
    func save(profile: UserProfile, targets: UserTargets) {
        self.profile = profile
        self.targets = targets
        Task { await persistToBackend(profile: profile) }
        persist()
        print("💾 ProfileStore: Saved profile and targets")
    }
    
    /// Save advanced profile data
    func saveAdvanced(_ advanced: ProfileAdvanced) {
        self.advanced = advanced.withDefaultsApplied()
        Task { @MainActor in
            persistAdvanced()
        }
        print("💾 ProfileStore: Saved advanced profile")
    }
    
    /// Update targets only
    func updateTargets(_ targets: UserTargets) {
        self.targets = targets
        persistTargets()
        print("💾 ProfileStore: Updated targets")
    }
    
    /// Fetch profile from backend and hydrate local cache
    @MainActor
    func syncFromBackend() async {
        do {
            let decoded: BackendProfileResponse = try await backend.get("profile")
            if let backendProfile = decoded.profile {
                self.profile = mapBackendProfile(backendProfile)
            }
            persist()
        } catch {
            print("⚠️ ProfileStore: Failed to fetch profile from backend - \(error)")
        }
    }
    
    /// Push latest profile to backend
    private func persistToBackend(profile: UserProfile) async {
        let payload = BackendProfileRequest(
            fullName: profile.name,
            email: profile.email,
            dateOfBirth: ISO8601DateFormatter().string(from: profile.birthdate),
            gender: profile.sex.rawValue.lowercased(),
            heightCm: profile.heightCm,
            weightKg: profile.weightKg,
            activityLevel: profile.activity.rawValue.lowercased(),
            primaryGoal: profile.goal.rawValue,
            goalType: profile.goal.rawValue.lowercased(),
            bodyFat: nil
        )
        do {
            let _: BackendProfileResponse = try await backend.put("profile", body: payload)
        } catch {
            print("⚠️ ProfileStore: Failed to persist profile to backend - \(error)")
        }
    }
    
    func submitOnboarding(answers: [BackendOnboardingAnswerRequest]) async {
        let payload = BackendOnboardingRequest(answers: answers)
        do {
            let _: BackendProfileResponse = try await backend.post("profile/onboarding", body: payload)
        } catch {
            print("⚠️ ProfileStore: Failed to submit onboarding answers - \(error)")
        }
    }
    
    private func mapBackendProfile(_ backendProfile: BackendProfile) -> UserProfile {
        var profile = UserProfile()
        profile.name = backendProfile.full_name ?? ""
        profile.email = backendProfile.email ?? ""
        profile.heightCm = backendProfile.height_cm ?? profile.heightCm
        profile.weightKg = backendProfile.weight_kg ?? profile.weightKg
        profile.goal = UserProfile.Goal(rawValue: backendProfile.primary_goal ?? "") ?? profile.goal
        profile.activity = UserProfile.Activity(rawValue: (backendProfile.activity_level ?? "").capitalized) ?? profile.activity
        if let gender = backendProfile.gender {
            profile.sex = UserProfile.Sex(rawValue: gender.capitalized) ?? profile.sex
        }
        if let dobString = backendProfile.date_of_birth, let date = ISO8601DateFormatter().date(from: dobString) {
            profile.birthdate = date
        }
        return profile
    }
    
    /// Clear all profile data (for testing/reset)
    func clearAll() {
        profile = nil
        targets = nil
        advanced = ProfileAdvanced()
        
        try? FileManager.default.removeItem(at: profileURL)
        try? FileManager.default.removeItem(at: targetsURL)
        try? FileManager.default.removeItem(at: advancedURL)
        
        print("🗑️ ProfileStore: Cleared all profile data")
    }
    
    /// Reset advanced profile to defaults
    @MainActor
    func resetAdvancedProfile() {
        // Delete existing file and recreate defaults
        try? FileManager.default.removeItem(at: advancedURL)
        self.advanced = ProfileAdvanced()
        try? saveAdvancedProfileSafely()
        
        // Show user feedback
        Task { @MainActor in
            UX.Banner.show(message: "Profile reset to defaults")
        }
        print("🔄 ProfileStore: Advanced profile reset to defaults")
    }

    private func persist() {
        persistProfile()
        persistTargets()
    }
    
    private func persistProfile() {
        guard let profile = profile else { return }
        do {
            try SafeFileIO.save(profile, to: "profile.json")
        } catch {
            print("⚠️ ProfileStore: Failed to save profile - \(error)")
            Task { @MainActor in
                UX.Banner.show(message: "Failed to save profile")
            }
        }
    }
    
    private func persistTargets() {
        guard let targets = targets else { return }
        do {
            try SafeFileIO.save(targets, to: "targets.json")
        } catch {
            print("⚠️ ProfileStore: Failed to save targets - \(error)")
            Task { @MainActor in
                UX.Banner.show(message: "Failed to save targets")
            }
        }
    }
    
    @MainActor
    private func persistAdvanced() {
        do {
            try saveAdvancedProfileSafely()
        } catch {
            print("⚠️ ProfileStore: Failed to save advanced profile - \(error)")
            UX.Banner.show(message: "Failed to save advanced profile")
        }
    }
    
    /// Safe save with pretty-printed JSON to the profile subdirectory
    @MainActor
    private func saveAdvancedProfileSafely() throws {
        let url = advancedURL
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(self.advanced.withDefaultsApplied())
        try data.write(to: url, options: .atomic)
    }
    

    
    private func loadProfile() {
        profile = SafeFileIO.load(UserProfile.self, from: "profile.json")
    }
    
    private func loadTargets() {
        targets = SafeFileIO.load(UserTargets.self, from: "targets.json")
    }
    
    @MainActor
    private func loadAdvanced() {
        let url = advancedURL
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let decoded = try decoder.decode(ProfileAdvanced.self, from: data)
                self.advanced = decoded.withDefaultsApplied()
                print("✅ ProfileStore: Loaded advanced profile from \(url.lastPathComponent)")
            } else {
                self.advanced = ProfileAdvanced()
                try saveAdvancedProfileSafely() // Write fresh file
                print("📝 ProfileStore: Created fresh advanced profile")
            }
        } catch {
            // Auto-heal: move bad file to _corrupted with timestamp, then write a fresh file
            backupCorruptedAdvancedProfile(url: url)
            self.advanced = ProfileAdvanced()
            try? saveAdvancedProfileSafely()
            
            Task { @MainActor in
                UX.Banner.show(message: "Recovered profile data")
            }
            print("🔧 ProfileStore: Auto-healed advanced_profile.json: \(error)")
        }
    }
    
    /// Backup a corrupted file with timestamp
    private func backupCorruptedAdvancedProfile(url: URL) {
        let stamp = ISO8601DateFormatter().string(from: Date())
        let backupDir = url.deletingLastPathComponent().appendingPathComponent("_corrupted", isDirectory: true)
        
        do {
            try FileManager.default.createDirectory(at: backupDir, withIntermediateDirectories: true)
            if FileManager.default.fileExists(atPath: url.path) {
                let backupURL = backupDir.appendingPathComponent("advanced_profile.json.\(stamp).bak")
                try FileManager.default.moveItem(at: url, to: backupURL)
                print("📦 ProfileStore: Backed up corrupted file to \(backupURL.lastPathComponent)")
            }
        } catch {
            print("⚠️ ProfileStore: Failed to backup corrupted file: \(error)")
        }
    }
    
    func seedDemoData() {
        // Create demo profile with correct argument order
        let demoProfile = UserProfile(
            name: "Demo User",
            sex: .male,
            birthdate: Calendar.current.date(from: DateComponents(year: 1990, month: 6, day: 15)) ?? Date(),
            heightCm: 175,
            weightKg: 75,
            goal: .maintainWeight,
            diet: .balanced,
            activity: .moderate,
            allergies: ["Peanuts"],
            injuries: [],
            equipment: []
        )
        
        // Create demo targets with correct property names
        let demoTargets = UserTargets(
            targetCalories: 2400,
            proteinG: 120,
            carbsG: 270,
            fatG: 67,
            hydrationMl: 2500,
            sleepHours: 8.0,
            steps: 10000
        )
        
        // Create demo advanced profile with correct enum values
        var demoAdvanced = ProfileAdvanced()
        demoAdvanced.bloodType = .Opos
        demoAdvanced.chronotype = .lark
        demoAdvanced.isPregnantOrPostpartum = false
        demoAdvanced.knownConditions = []
        demoAdvanced.injuries = []
        demoAdvanced.supplements = ["Vitamin D", "Omega-3"]
        demoAdvanced.foodDislikes = ["Mushrooms"]
        demoAdvanced.budgetNotes = "Moderate budget"
        
        save(profile: demoProfile, targets: demoTargets)
        saveAdvanced(demoAdvanced)
        
        print("Demo data seeded successfully")
    }
}

// MARK: - Backend payloads
private struct BackendProfileRequest: Codable {
    let fullName: String?
    let email: String?
    let dateOfBirth: String?
    let gender: String?
    let heightCm: Double?
    let weightKg: Double?
    let activityLevel: String?
    let primaryGoal: String?
    let goalType: String?
    let bodyFat: Double?
}

private struct BackendProfileResponse: Codable {
    let profile: BackendProfile?
    let onboardingAnswers: [BackendOnboardingAnswer]?
}

struct BackendOnboardingAnswerRequest: Codable {
    let questionKey: String
    let answerText: String?
    let answerNumeric: Double?
}

struct BackendOnboardingRequest: Codable {
    let answers: [BackendOnboardingAnswerRequest]
}
