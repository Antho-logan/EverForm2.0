import SwiftUI
import OSLog

enum OnboardingStep: Int, CaseIterable {
    case basic = 0
    case lifestyle = 1
    case goals = 2
    
    var title: String {
        switch self {
        case .basic: return "Basic Info"
        case .lifestyle: return "Lifestyle"
        case .goals: return "Goals"
        }
    }
}

enum GoalFocus: String, Codable, CaseIterable, Hashable {
    case loseFat = "Lose fat"
    case buildMuscle = "Build muscle"
    case feelBetter = "Feel better"
    case improveHealth = "Improve health"
    case increaseEnergy = "Increase energy"
    case betterSleep = "Better sleep"
}

struct OnboardingDraft: Codable {
    var name = ""
    var birthdate = Date()
    var heightCm: Double = 170
    var weightKg: Double? = 70
    var weightUnknown = false
    var sex: UserProfile.Sex = .male
    var goal: UserProfile.Goal = .maintainWeight
    var activity: UserProfile.Activity = .moderate
    var diet: UserProfile.Diet = .balanced
    var allergies: [String] = []
    var goals: [String] = []
    var goalFocus: Set<GoalFocus> = []
    var notes = ""
    
    init() {}
}

@MainActor
@Observable
class OnboardingStore {
    private let logger = Logger.onboarding
    
    var currentStep: OnboardingStep = .basic
    var draft = OnboardingDraft()
    var isCompleted = false
    var isNavigatingForward = true // Track navigation direction
    
    private let draftKey = "onboarding_draft"
    private let stepKey = "onboarding_step"
    private let completedKey = "onboarding_completed"
    
    init() {
        loadState()
    }
    
    func saveDraft() {
        if let data = try? JSONEncoder().encode(draft) {
            UserDefaults.standard.set(data, forKey: draftKey)
            UserDefaults.standard.set(currentStep.rawValue, forKey: stepKey)
            logger.info("Onboarding draft saved at step \(self.currentStep.rawValue)")
        }
    }
    
    func loadState() {
        // Load completion status
        isCompleted = UserDefaults.standard.bool(forKey: completedKey)
        
        // Load draft and step with defensive decoding
        if let data = UserDefaults.standard.data(forKey: draftKey) {
            do {
                let decoded = try JSONDecoder().decode(OnboardingDraft.self, from: data)
                draft = decoded
                currentStep = OnboardingStep(rawValue: UserDefaults.standard.integer(forKey: stepKey)) ?? .basic
                logger.info("Onboarding state loaded: step \(self.currentStep.rawValue), completed: \(self.isCompleted)")
            } catch {
                logger.info("Failed to decode onboarding draft, using defaults: \(error.localizedDescription)")
                draft = OnboardingDraft() // Use default values
                currentStep = .basic
                // Clear corrupted data
                UserDefaults.standard.removeObject(forKey: draftKey)
                UserDefaults.standard.removeObject(forKey: stepKey)
            }
        } else {
            logger.info("No onboarding draft found, using defaults")
        }
    }
    
    func complete() {
        isCompleted = true
        UserDefaults.standard.set(true, forKey: completedKey)
        
        // Clear draft
        UserDefaults.standard.removeObject(forKey: draftKey)
        UserDefaults.standard.removeObject(forKey: stepKey)
        
        logger.info("Onboarding completed")
    }
    
    // Helper methods for height conversion
    static func feetInchesToCm(feet: Int, inches: Int) -> Double {
        let totalInches = Double(feet * 12 + inches)
        return totalInches * 2.54
    }
    
    static func cmToFeetInches(_ cm: Double) -> (feet: Int, inches: Int) {
        let totalInches = cm / 2.54
        let feet = Int(totalInches / 12)
        let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
        return (feet: feet, inches: inches)
    }
    
    func reset() {
        isCompleted = false
        currentStep = .basic
        draft = OnboardingDraft()
        
        UserDefaults.standard.removeObject(forKey: completedKey)
        UserDefaults.standard.removeObject(forKey: draftKey)
        UserDefaults.standard.removeObject(forKey: stepKey)
        
        logger.info("Onboarding reset")
    }
}

struct OnboardingFlow: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(ProfileStore.self) private var profileStore
    
    @State private var store = OnboardingStore()
    @State private var isValid = false
    @Namespace private var cardNamespace
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [.blue.opacity(0.1), .purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress Header
                    progressHeader
                    
                    // Content Card
                    ScrollView {
                        VStack(spacing: 20) {
                            cardContent
                            navigationButtons
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
        }
        .interactiveDismissDisabled()
        .onAppear {
            validateCurrentStep()
            UX.A11y.announce("Onboarding: \(store.currentStep.title)")
        }
        .onChange(of: store.currentStep) { _, _ in
            store.saveDraft()
            validateCurrentStep()
            UX.A11y.announce("Step \(store.currentStep.rawValue + 1): \(store.currentStep.title)")
            UX.A11y.focusChanged()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            store.saveDraft()
        }
    }
    
    private var progressHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Step \(store.currentStep.rawValue + 1) of \(OnboardingStep.allCases.count)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            
            // Progress dots
            HStack(spacing: 8) {
                ForEach(OnboardingStep.allCases, id: \.self) { step in
                    Circle()
                        .fill(step.rawValue <= store.currentStep.rawValue ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(step == store.currentStep ? 1.2 : 1.0)
                        .animation(UX.Anim.snappy(), value: store.currentStep)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.regularMaterial)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress: Step \(store.currentStep.rawValue + 1) of \(OnboardingStep.allCases.count)")
    }
    
    @ViewBuilder
    private var cardContent: some View {
        VStack(spacing: 24) {
            currentStepView
        }
        .padding(32)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
        }
        .padding(.horizontal, 20)
        .matchedGeometryEffect(id: "onboardingCard", in: cardNamespace)
    }
    
    @ViewBuilder
    private var currentStepView: some View {
        let transition = reduceMotion ? UX.Transition.fade : 
            (store.isNavigatingForward ? UX.Transition.slideTrailing : UX.Transition.slideLeading)
        
        Group {
            switch store.currentStep {
            case .basic:
                StepBasicView(draft: $store.draft, isValid: $isValid)
            case .lifestyle:
                StepLifestyleView(draft: $store.draft, isValid: $isValid)
            case .goals:
                StepGoalsView(draft: $store.draft, isValid: $isValid)
            }
        }
        .transition(transition)
        .animation(UX.Anim.fast, value: store.currentStep)
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 12) {
            // Back button
            if store.currentStep != .basic {
                Button("Back") {
                    DebugLog.info("Onboarding: Back button tapped from step \(store.currentStep.rawValue)")
                    UX.Haptic.light()
                    store.isNavigatingForward = false
                    withAnimation(UX.Anim.adaptive(UX.Anim.fast, reduceMotion: reduceMotion)) {
                        if let previousStep = OnboardingStep(rawValue: store.currentStep.rawValue - 1) {
                            store.currentStep = previousStep
                        }
                    }
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                .accessibilityLabel("Go back to previous step")
            }
            
            // Skip button (only on goals step)
            if store.currentStep == .goals {
                Button("Skip") {
                    UX.Haptic.light()
                    completeOnboarding()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                .accessibilityLabel("Skip goals and finish onboarding")
            }
            
            // Next/Finish button
            Button(store.currentStep == .goals ? "Finish" : "Next") {
                DebugLog.info("Onboarding: Next/Finish button tapped on step \(store.currentStep.rawValue), isValid: \(isValid)")
                if !isValid && store.currentStep != .goals {
                    UX.Haptic.warning()
                    return
                }
                
                if store.currentStep == .goals {
                    UX.Haptic.success()
                    completeOnboarding()
                } else {
                    UX.Haptic.light()
                    advanceStep()
                }
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity)
            .opacity(isValid ? 1.0 : 0.6)
            .animation(UX.Anim.snappy(0.2), value: isValid)
            .accessibilityLabel(store.currentStep == .goals ? "Finish onboarding" : "Continue to next step")
            .accessibilityHint(isValid ? "" : "Complete required fields to continue")
        }
        .padding(.horizontal, 20)
    }
    
    private func advanceStep() {
        store.isNavigatingForward = true
        withAnimation(UX.Anim.adaptive(UX.Anim.fast, reduceMotion: reduceMotion)) {
            if let nextStep = OnboardingStep(rawValue: store.currentStep.rawValue + 1) {
                DebugLog.info("Onboarding: Advancing to step \(nextStep.rawValue)")
                store.currentStep = nextStep
            }
        }
    }
    
    private func completeOnboarding() {
        // Save to ProfileStore
        let profile = UserProfile(
            name: store.draft.name,
            sex: store.draft.sex,
            birthdate: store.draft.birthdate,
            heightCm: store.draft.heightCm,
            weightKg: store.draft.weightKg ?? 70.0,
            goal: store.draft.goal,
            diet: store.draft.diet,
            activity: store.draft.activity,
            allergies: store.draft.allergies,
            injuries: [],
            equipment: []
        )
        
        let targets = calculateTargets(from: profile)
        profileStore.save(profile: profile, targets: targets)
        
        // Save goals to advanced profile if any
        if !store.draft.goals.isEmpty {
            var advanced = profileStore.advanced ?? ProfileAdvanced()
            // Store goals in budgetNotes for now (could add dedicated field later)
            let goalsText = "Goals: " + store.draft.goals.joined(separator: ", ")
            advanced.budgetNotes = advanced.budgetNotes?.isEmpty == false ? "\(advanced.budgetNotes!)\n\(goalsText)" : goalsText
            profileStore.saveAdvanced(advanced)
        }
        
        store.complete()
        UX.A11y.announce("Onboarding completed! Welcome to EverForm")
        dismiss()
    }
    
    private func validateCurrentStep() {
        switch store.currentStep {
        case .basic:
            isValid = !store.draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .lifestyle:
            isValid = true // Always valid with defaults
        case .goals:
            isValid = true // Always valid (optional step)
        }
    }
    
    private func calculateTargets(from profile: UserProfile) -> UserTargets {
        // Basic BMR calculation
        let age = Calendar.current.dateComponents([.year], from: profile.birthdate, to: Date()).year ?? 25
        let weight = profile.weightKg
        let height = profile.heightCm
        
        let bmr: Double
        switch profile.sex {
        case .male:
            bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * Double(age))
        case .female:
            bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * Double(age))
        case .other:
            // Use average of male/female formulas
            let maleBmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * Double(age))
            let femaleBmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * Double(age))
            bmr = (maleBmr + femaleBmr) / 2
        }
        
        let activityMultiplier: Double = switch profile.activity {
        case .sedentary: 1.2
        case .light: 1.375
        case .moderate: 1.55
        case .high: 1.725
        case .athlete: 1.9
        }
        
        let maintenanceCalories = bmr * activityMultiplier
        
        let targetCalories: Double = switch profile.goal {
        case .fatLoss: maintenanceCalories - 500
        case .maintainWeight: maintenanceCalories
        case .muscleGain: maintenanceCalories + 500
        case .recomposition: maintenanceCalories - 200
        case .performance: maintenanceCalories + 200
        case .longevity: maintenanceCalories - 100
        }
        
        return UserTargets(
            targetCalories: Int(targetCalories),
            proteinG: Int(weight * 1.6),
            carbsG: Int(targetCalories * 0.45 / 4),
            fatG: Int(targetCalories * 0.25 / 9),
            hydrationMl: 2500,
            sleepHours: 8.0
        )
    }
}

#Preview {
    OnboardingFlow()
        .environment(ProfileStore())
}