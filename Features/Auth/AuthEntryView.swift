import SwiftUI

struct AuthEntryView: View {
  @Environment(ThemeManager.self) private var themeManager
  @Environment(AppSessionStore.self) private var sessionStore

  @State private var showingOnboarding = false

  var onCreateAccount: () -> Void

  var body: some View {
    EFScreenContainer {
      VStack(spacing: EverFormTheme.Spacing.xxl) {
        Spacer()

        // Logo Section
        VStack(spacing: EverFormTheme.Spacing.lg) {
          Text("EverForm")
            .font(EverFormTheme.Typography.screenTitle)
            .fontWeight(.bold)
            .foregroundStyle(EverFormTheme.Colors.textPrimary)
            .tracking(1.5)

          Text("We’ll set up your plan in under 60 seconds.")
            .font(EverFormTheme.Typography.body)
            .foregroundStyle(EverFormTheme.Colors.textSecondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, EverFormTheme.Spacing.screenPadding)
        }
        .padding(.horizontal, EverFormTheme.Spacing.screenPadding)

        Spacer()

        // Buttons Section
        VStack(spacing: EverFormTheme.Spacing.md) {
          // Apple
          EFPrimaryButton(
            "Continue with Apple",
            icon: "apple.logo",
            color: EverFormTheme.Colors.textPrimary
          ) {
            handleLogin(provider: .apple)
          }

          // Google
          EFSecondaryButton(
            "Continue with Google",
            icon: "globe"
          ) {
            handleLogin(provider: .google)
          }

          // Create Account
          Button {
            onCreateAccount()
          } label: {
            Text("Create account")
              .font(EverFormTheme.Typography.button)
              .foregroundStyle(EverFormTheme.Colors.textSecondary)
          }
          .padding(.top, EverFormTheme.Spacing.sm)
        }
        .padding(.horizontal, EverFormTheme.Spacing.screenPadding)
        .padding(.bottom, EverFormTheme.Spacing.xxl)
      }
    }
    .fullScreenCover(isPresented: $showingOnboarding) {
      OnboardingFlowView()
    }
  }

  private enum AuthProvider {
    case apple, google
  }

  private func handleLogin(provider: AuthProvider) {
    // Dev mode: Simulate successful login
    // In a real app, you'd trigger the SDK flow here.

    let impact = UIImpactFeedbackGenerator(style: .medium)
    impact.impactOccurred()

    // Delay slightly for UX
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      withAnimation {
        sessionStore.signIn()
        // Assume returning users have completed onboarding or checks elsewhere will handle it
        sessionStore.completeOnboarding()
      }
    }
  }
}

#Preview {
  AuthEntryView(onCreateAccount: {})
    .environment(ThemeManager())
    .environment(AppSessionStore())
}
