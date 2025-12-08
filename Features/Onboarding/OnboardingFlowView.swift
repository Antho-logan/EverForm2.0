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
      EFScreenContainer {
        VStack(spacing: 0) {
          // Progress
          ProgressBar(
            progress: Double(currentStep.rawValue + 1) / Double(OnboardingStep.allCases.count)
          )
          .padding(.top, EverFormTheme.Spacing.md)

          // Main Content
          ScrollView {
            VStack(alignment: .leading, spacing: EverFormTheme.Spacing.sectionSpacing) {
              // Typewriter Title
              TypewriterText(
                text: currentStep.title,
                font: EverFormTheme.Typography.screenTitle,
                delay: 0.03,
                onComplete: {
                  withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    questionFinishedTyping = true
                  }
                }
              )
              .foregroundStyle(EverFormTheme.Colors.textPrimary)
              .fixedSize(horizontal: false, vertical: true)
              .padding(.top, EverFormTheme.Spacing.screenPadding)
              .id("Title-\(currentStep.rawValue)")  // Force redraw on step change

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
            .padding(EverFormTheme.Spacing.screenPadding)
          }
          .scrollDismissesKeyboard(.interactively)

          // Footer Controls
          if questionFinishedTyping {
            VStack(spacing: EverFormTheme.Spacing.md) {
              EFPrimaryButton(currentStep.nextButtonTitle) {
                handleNext()
              }
              .disabled(!isStepValid)
              .opacity(isStepValid ? 1.0 : 0.6) // Visual hint for disabled state if component doesn't handle it fully

              if currentStep != .basic {
                Button("Back") {
                  withAnimation {
                    handleBack()
                  }
                }
                .font(EverFormTheme.Typography.button)
                .foregroundStyle(EverFormTheme.Colors.textSecondary)
              }
            }
            .padding(EverFormTheme.Spacing.screenPadding)
            .background(EverFormTheme.Colors.background.opacity(0.95))
            .transition(.move(edge: .bottom).combined(with: .opacity))
          }
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            dismiss()
          }
          .foregroundStyle(EverFormTheme.Colors.textSecondary)
        }
      }
      // Reset animation state when step changes
      .onChange(of: currentStep) { _, _ in
        questionFinishedTyping = false
        isStepValid = false  // Reset validity, let the view re-validate on appear
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
          .fill(EverFormTheme.Colors.surface) // Updated to theme
          .frame(height: 4)

        Capsule()
          .fill(EverFormTheme.Colors.trainingGreen)
          .frame(width: geo.size.width * progress, height: 4)
          .animation(.spring, value: progress)
      }
    }
    .frame(height: 4)
    .padding(.horizontal, EverFormTheme.Spacing.screenPadding)
  }
}
