import SwiftUI

struct OnboardingFlowView: View {
    @Environment(OnboardingStore.self) private var store
    @Environment(AppSessionStore.self) private var sessionStore
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    
    @State private var currentStep: OnboardingStep = .basic
    @State private var questionFinishedTyping = false
    @State private var isStepValid = false
    
    // Map high-level steps to our view groups
    enum OnboardingStep: Int, CaseIterable {
        case basic
        case goals
        case lifestyle
        
        var title: String {
            switch self {
            case .basic: return "Let's start with the basics."
            case .goals: return "What are you aiming for?"
            case .lifestyle: return "Tell us about your lifestyle."
            }
        }
        
        var nextButtonTitle: String {
            switch self {
            case .lifestyle: return "Finish"
            default: return "Next"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                themeManager.beigeBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Progress
                    ProgressBar(progress: Double(currentStep.rawValue + 1) / Double(OnboardingStep.allCases.count))
                        .padding(.top, 16)
                    
                    // Main Content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Typewriter Title
                            TypewriterText(
                                text: currentStep.title,
                                font: DesignSystem.Typography.displayMedium(),
                                delay: 0.03,
                                onComplete: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        questionFinishedTyping = true
                                    }
                                }
                            )
                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 20)
                            .id("Title-\(currentStep.rawValue)") // Force redraw on step change
                            
                            // Content "falls in"
                            if questionFinishedTyping {
                                stepContent
                                    .transition(
                                        .asymmetric(
                                            insertion: .move(edge: .bottom).combined(with: .opacity),
                                            removal: .opacity
                                        )
                                    )
                            }
                        }
                        .padding(20)
                    }
                    .scrollDismissesKeyboard(.interactively)
                    
                    // Footer Controls
                    if questionFinishedTyping {
                        VStack(spacing: 16) {
                            Button(action: handleNext) {
                                Text(currentStep.nextButtonTitle)
                                    .font(DesignSystem.Typography.buttonLarge())
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(isStepValid ? DesignSystem.Colors.accent : DesignSystem.Colors.neutral400)
                                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
                            }
                            .disabled(!isStepValid)
                            
                            if currentStep != .basic {
                                Button("Back") {
                                    withAnimation {
                                        handleBack()
                                    }
                                }
                                .font(DesignSystem.Typography.buttonMedium())
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                            }
                        }
                        .padding(20)
                        .background(themeManager.beigeBackground.opacity(0.95))
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
            }
            // Reset animation state when step changes
            .onChange(of: currentStep) { _, _ in
                questionFinishedTyping = false
                isStepValid = false // Reset validity, let the view re-validate on appear
            }
        }
    }
    
    @ViewBuilder
    private var stepContent: some View {
        VStack {
            switch currentStep {
            case .basic:
                StepBasicView(
                    draft: Bindable(store).draft,
                    isValid: $isStepValid
                )
            case .goals:
                StepGoalsView(
                    draft: Bindable(store).draft,
                    isValid: $isStepValid
                )
            case .lifestyle:
                StepLifestyleView(
                    draft: Bindable(store).draft,
                    isValid: $isStepValid
                )
            }
        }
    }
    
    private func handleNext() {
        guard isStepValid else { return }
        
        if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            withAnimation {
                currentStep = nextStep
            }
        } else {
            // Final Step
            Task {
                await store.submitOnboarding()
                await MainActor.run {
                    sessionStore.signIn()
                    sessionStore.completeOnboarding()
                    dismiss()
                }
            }
        }
    }
    
    private func handleBack() {
        if let prevStep = OnboardingStep(rawValue: currentStep.rawValue - 1) {
            withAnimation {
                currentStep = prevStep
            }
        }
    }
}

private struct ProgressBar: View {
    var progress: Double
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 4)
                
                Capsule()
                    .fill(DesignSystem.Colors.accent)
                    .frame(width: geo.size.width * progress, height: 4)
                    .animation(.spring, value: progress)
            }
        }
        .frame(height: 4)
        .padding(.horizontal, 20)
    }
}

