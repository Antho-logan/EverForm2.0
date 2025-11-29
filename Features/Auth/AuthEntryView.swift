import SwiftUI

struct AuthEntryView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(AppSessionStore.self) private var sessionStore
    
    @State private var showingOnboarding = false
    
    var onCreateAccount: () -> Void
    
    var body: some View {
        ZStack {
            // Background
            themeManager.beigeBackground
                .ignoresSafeArea()
            
            VStack(spacing: DesignSystem.Spacing.xxl) {
                Spacer()
                
                // Title Section
                VStack(spacing: DesignSystem.Spacing.md) {
                    Text("Welcome to EverForm")
                        .font(DesignSystem.Typography.displayMedium())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("We’ll set up your plan in under 60 seconds.")
                        .font(DesignSystem.Typography.bodyLarge())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                
                Spacer()
                
                // Buttons Section
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Apple
                    Button {
                        handleLogin(provider: .apple)
                    } label: {
                        HStack {
                            Image(systemName: "apple.logo")
                            Text("Continue with Apple")
                        }
                        .font(DesignSystem.Typography.buttonLarge())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
                    }
                    
                    // Google
                    Button {
                        handleLogin(provider: .google)
                    } label: {
                        HStack {
                            Image(systemName: "globe")
                            Text("Continue with Google")
                        }
                        .font(DesignSystem.Typography.buttonLarge())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                                .stroke(DesignSystem.Colors.border, lineWidth: 1)
                        )
                    }
                    
                    // Create Account
                    Button {
                        showingOnboarding = true
                    } label: {
                        Text("Create account")
                            .font(DesignSystem.Typography.buttonMedium())
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                    }
                    .padding(.top, DesignSystem.Spacing.sm)
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                .padding(.bottom, DesignSystem.Spacing.xxl)
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
                // If we want to force onboarding for new users, we'd check a backend flag.
                // For dev-mode, we assume "Continue" means "I have an account" -> Skip onboarding
                // unless the session store logic dictates otherwise.
                // However, if sessionStore.hasCompletedOnboarding is false, EverFormApp will show onboarding.
                // Let's assume for "Continue with..." we simulate an existing user who has done it.
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
