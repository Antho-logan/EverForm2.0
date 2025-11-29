import Foundation
import Observation
import OSLog

// Define the question steps
public enum OnboardingQuestion: Int, Codable, CaseIterable {
    case basicName = 0
    case sex
    case birthdate
    case height
    case weight
    case primaryGoal
    case activityLevel
    case dietaryApproach
    
    var title: String {
        switch self {
        case .basicName: return "What is your name?"
        case .sex: return "What is your biological sex?"
        case .birthdate: return "When were you born?"
        case .height: return "How tall are you?"
        case .weight: return "How much do you weigh?"
        case .primaryGoal: return "What is your main goal?"
        case .activityLevel: return "How active are you?"
        case .dietaryApproach: return "Do you follow a specific diet?"
        }
    }
}

@MainActor
@Observable
final class OnboardingStore {
    private let logger = Logger.onboarding
    private let profileStore: ProfileStore
    
    var currentQuestion: OnboardingQuestion = .basicName
    var draft: OnboardingDraftState
    var isCompleted = false
    var isNavigatingForward = true
    var isSubmitting = false
    var submitError: String?
    
    private let draftKey = "onboarding_draft"
    private let stepKey = "onboarding_step_index"
    private let completedKey = "hasCompletedOnboarding" // Match AppStorage key if possible
    
    init(profileStore: ProfileStore, initialDraft: OnboardingDraftState? = nil) {
        self.profileStore = profileStore
        self.draft = initialDraft ?? OnboardingDraftState()
        loadState()
    }
    
    // MARK: - Persistence
    func saveDraft() {
        if let data = try? JSONEncoder().encode(draft) {
            UserDefaults.standard.set(data, forKey: draftKey)
            UserDefaults.standard.set(currentQuestion.rawValue, forKey: stepKey)
        }
    }
    
    func loadState() {
        isCompleted = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        let storedIndex = UserDefaults.standard.integer(forKey: stepKey)
        if let question = OnboardingQuestion(rawValue: storedIndex) {
            currentQuestion = question
        } else {
            currentQuestion = .basicName
        }
        
        if let data = UserDefaults.standard.data(forKey: draftKey) {
            do {
                draft = try JSONDecoder().decode(OnboardingDraftState.self, from: data)
            } catch {
                draft = OnboardingDraftState()
            }
        }
    }
    
    func nextQuestion() {
        if let next = OnboardingQuestion(rawValue: currentQuestion.rawValue + 1) {
            isNavigatingForward = true
            currentQuestion = next
            saveDraft()
        } else {
            // Last step
            Task {
                await submitOnboarding()
            }
        }
    }
    
    func previousQuestion() {
        if let prev = OnboardingQuestion(rawValue: currentQuestion.rawValue - 1) {
            isNavigatingForward = false
            currentQuestion = prev
            saveDraft()
        }
    }
    
    func reset() {
        isCompleted = false
        currentQuestion = .basicName
        draft = OnboardingDraftState()
        
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        UserDefaults.standard.removeObject(forKey: draftKey)
        UserDefaults.standard.removeObject(forKey: stepKey)
    }
    
    // MARK: - Helpers
    static func feetInchesToCm(feet: Int, inches: Int) -> Double {
        let totalInches = Double(feet * 12 + inches)
        return totalInches * 2.54
    }
    
    static func cmToFeetInches(_ cm: Double) -> (feet: Int, inches: Int) {
        let totalInches = cm / 2.54
        let feet = Int(totalInches / 12.0)
        let inches = Int(round(totalInches - Double(feet * 12)))
        return (feet, inches)
    }
    
    // MARK: - Completion
    func complete() {
        isCompleted = true
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        UserDefaults.standard.removeObject(forKey: draftKey)
        UserDefaults.standard.removeObject(forKey: stepKey)
    }
    
    func submitOnboarding() async {
        isSubmitting = true
        defer { isSubmitting = false }
        
        let profile = UserProfile(
            name: draft.name,
            sex: draft.sex,
            birthdate: draft.birthdate,
            heightCm: draft.heightCm,
            weightKg: draft.weightKg ?? 70.0,
            goal: draft.goal,
            diet: draft.diet,
            activity: draft.activity,
            allergies: draft.allergies,
            injuries: [],
            equipment: []
        )
        
        let targets = calculateTargets(from: profile)
        profileStore.save(profile: profile, targets: targets)
        
        // Optional: Submit to backend if implemented
        // ...
        
        complete()
    }
    
    private func calculateTargets(from profile: UserProfile) -> UserTargets {
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
            sleepHours: 8.0,
            steps: 10000
        )
    }
}
