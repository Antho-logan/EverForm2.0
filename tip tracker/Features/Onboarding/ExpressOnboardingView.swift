//
//  ExpressOnboardingView.swift
//  EverForm
//
//  Created by Anthony Logan on 23/08/2025.
//

import SwiftUI

/// Express onboarding flow for ≤60s setup
struct ExpressOnboardingView: View {
    @Environment(AppRouter.self) private var router
    @Environment(ProfileStore.self) private var profileStore

    @State private var draft = UserProfile(
        name: "",
        sex: .male,
        birthdate: Calendar.current.date(byAdding: .year, value: -28, to: Date()) ?? Date(),
        heightCm: 178,
        weightKg: 78,
        goal: .recomposition,
        diet: .omnivore,
        activity: .moderate,
        allergies: [],
        injuries: [],
        equipment: [],
        usualBedtime: nil,
        usualWake: nil
    )
    
    @State private var goal30 = ""
    @State private var goal90 = ""
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            Form {
                Section("👋 Welcome to EverForm") {
                    Text("Let's get you set up with personalized nutrition and fitness targets in under 60 seconds.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Section("Basic Info") {
                    TextField("Your name", text: $draft.name)
                        .textContentType(.name)
                    
                    Picker("Sex", selection: $draft.sex) {
                        ForEach([UserProfile.Sex.male, .female, .other], id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    DatePicker("Birthdate", selection: $draft.birthdate, displayedComponents: .date)
                    
                    HStack {
                        Text("Height (cm)")
                        Spacer()
                        TextField("178", value: $draft.heightCm, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }
                    
                    HStack {
                        Text("Weight (kg)")
                        Spacer()
                        TextField("78", value: $draft.weightKg, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }
                }
                
                Section("Lifestyle") {
                    Picker("Primary goal", selection: $draft.goal) {
                        ForEach([
                            UserProfile.Goal.fatLoss,
                            .recomposition,
                            .muscleGain,
                            .performance,
                            .longevity
                        ], id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    
                    Picker("Activity level", selection: $draft.activity) {
                        ForEach([
                            UserProfile.Activity.sedentary,
                            .light,
                            .moderate,
                            .high,
                            .athlete
                        ], id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    
                    Picker("Dietary approach", selection: $draft.diet) {
                        ForEach([
                            UserProfile.Diet.none,
                            .mediterranean,
                            .paleo,
                            .plantBased,
                            .omnivore,
                            .lowCarb,
                            .highProtein
                        ], id: \.self) {
                            Text($0.rawValue).tag($0)
                        }
                    }
                    
                    TextField("Allergies (comma separated)", text: .init(
                        get: { draft.allergies.joined(separator: ", ") },
                        set: { newValue in
                            draft.allergies = newValue
                                .split(separator: ",")
                                .map { $0.trimmingCharacters(in: .whitespaces) }
                                .filter { !$0.isEmpty }
                        }
                    ))
                    .textContentType(.none)
                }
                
                Section("Your Goals (Optional)") {
                    TextField("30-day focus", text: $goal30, prompt: Text("e.g., Lose 5kg, Build strength"))
                        .textContentType(.none)
                    
                    TextField("90-day focus", text: $goal90, prompt: Text("e.g., Run 10K, Gain 3kg muscle"))
                        .textContentType(.none)
                }
                
                Section {
                    Button(action: { finish() }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            Text("Complete Setup")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isLoading || draft.name.isEmpty)
                    
                    Button("Skip for now →") {
                        finish(skipGoals: true)
                    }
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Quick Setup")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        router.closeFullScreen()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Advanced…") {
                        router.fullScreen = .advancedProfile
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func finish(skipGoals: Bool = false) {
        isLoading = true
        
        // Add goals as equipment tags for now
        var finalProfile = draft
        if !goal30.isEmpty {
            finalProfile.equipment.append("goal30:\(goal30)")
        }
        if !goal90.isEmpty {
            finalProfile.equipment.append("goal90:\(goal90)")
        }
        
        // Compute personalized targets
        let targets = Calculators.computeTargets(for: finalProfile)
        
        // Save profile and targets
        profileStore.save(profile: finalProfile, targets: targets)
        
        // Navigate to dashboard
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isLoading = false
            router.closeFullScreen()
            router.go(.overview)
        }
        
        print("✅ ExpressOnboarding: Completed setup for \(finalProfile.name)")
    }
}

#Preview {
    ExpressOnboardingView()
        .environment(AppRouter())
        .environment(ProfileStore())
}

