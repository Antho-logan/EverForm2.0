import SwiftUI
import OSLog
import Observation

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

struct OnboardingFlow: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(ProfileStore.self) private var profileStore

    @State private var onboardingStore: OnboardingStore?
    @State private var isValid = false
    @Namespace private var cardNamespace
    
    var body: some View {
        Group {
            if let onboardingStore {
                flowView(with: onboardingStore)
                    .environment(onboardingStore)
            } else {
                ProgressView()
                    .task {
                        if onboardingStore == nil {
                            onboardingStore = OnboardingStore(profileStore: profileStore)
                        }
                    }
            }
        }
    }
    
    private func flowView(with onboardingStore: OnboardingStore) -> some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.1), .purple.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    progressHeader(store: onboardingStore)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            cardContent(store: onboardingStore)
                            navigationButtons(store: onboardingStore)
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
        }
        .interactiveDismissDisabled()
        .onAppear {
            validateCurrentStep(store: onboardingStore)
            UX.A11y.announce("Onboarding: \(onboardingStore.currentStep.title)")
        }
        .onChange(of: onboardingStore.currentStep) { _, _ in
            onboardingStore.saveDraft()
            validateCurrentStep(store: onboardingStore)
            UX.A11y.announce("Step \(onboardingStore.currentStep.rawValue + 1): \(onboardingStore.currentStep.title)")
            UX.A11y.focusChanged()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
            onboardingStore.saveDraft()
        }
    }
    
    private func progressHeader(store: OnboardingStore) -> some View {
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
    private func cardContent(store: OnboardingStore) -> some View {
        VStack(spacing: 24) {
            currentStepView(store: store)
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
    private func currentStepView(store: OnboardingStore) -> some View {
        let transition = reduceMotion ? UX.Transition.fade : 
            (store.isNavigatingForward ? UX.Transition.slideTrailing : UX.Transition.slideLeading)
        
        Group {
            switch store.currentStep {
            case .basic:
                StepBasicView(
                    draft: Binding(get: { store.draft }, set: { store.draft = $0 }),
                    isValid: $isValid
                )
            case .lifestyle:
                StepLifestyleView(
                    draft: Binding(get: { store.draft }, set: { store.draft = $0 }),
                    isValid: $isValid
                )
            case .goals:
                StepGoalsView(
                    draft: Binding(get: { store.draft }, set: { store.draft = $0 }),
                    isValid: $isValid
                )
            }
        }
        .transition(transition)
        .animation(UX.Anim.fast, value: store.currentStep)
    }
    
    private func navigationButtons(store: OnboardingStore) -> some View {
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
                    Task {
                        await completeOnboarding(store: store)
                    }
                } else {
                    UX.Haptic.light()
                    advanceStep(store: store)
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
    
    private func advanceStep(store: OnboardingStore) {
        store.isNavigatingForward = true
        withAnimation(UX.Anim.adaptive(UX.Anim.fast, reduceMotion: reduceMotion)) {
            if let nextStep = OnboardingStep(rawValue: store.currentStep.rawValue + 1) {
                DebugLog.info("Onboarding: Advancing to step \(nextStep.rawValue)")
                store.currentStep = nextStep
            }
        }
    }
    
    private func completeOnboarding(store: OnboardingStore) async {
        await store.submitOnboarding()
        if store.isCompleted {
            UX.A11y.announce("Onboarding completed! Welcome to EverForm")
            dismiss()
        }
    }

    private func validateCurrentStep(store: OnboardingStore) {
        switch store.currentStep {
        case .basic:
            isValid = !store.draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .lifestyle:
            isValid = true // Always valid with defaults
        case .goals:
            isValid = true // Always valid (optional step)
        }
    }
}

#Preview {
    let profileStore = ProfileStore()
    let onboardingStore = OnboardingStore(profileStore: profileStore)
    return OnboardingFlow()
        .environment(profileStore)
        .environment(onboardingStore)
}
