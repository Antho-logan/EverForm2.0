import SwiftUI

struct OnboardingFlow: View {
    @Environment(ThemeManager.self) private var themeManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    // Shared draft state
    @State private var draft = OnboardingDraftState()
    @State private var currentStep = 0
    
    private let totalSteps = 6 // Steps 1-5 + Summary
    
    var body: some View {
        ZStack {
            // Background
            themeManager.beigeBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (Step Indicator)
                if currentStep < totalSteps - 1 {
                    HStack {
                        // Back Button
                        if currentStep > 0 {
                            Button {
                                withAnimation(.spring()) {
                                    currentStep -= 1
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                                    .padding(12)
                                    .background(Circle().fill(DesignSystem.Colors.backgroundSecondary))
                            }
                        } else {
                            Spacer().frame(width: 44)
                        }
                        
                        Spacer()
                        
                        // Step Indicator
                        Text("Step \(currentStep + 1) of 5")
                            .font(DesignSystem.Typography.labelMedium())
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(DesignSystem.Colors.backgroundSecondary))
                        
                        Spacer()
                        
                        // Balance for back button
                        Spacer().frame(width: 44)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                    .padding(.top, 16)
                }
                
                // Content
                TabView(selection: $currentStep) {
                    OnboardingStep1(draft: draft)
                        .tag(0)
                    
                    OnboardingStep2(draft: draft)
                        .tag(1)
                    
                    OnboardingStep3(draft: draft)
                        .tag(2)
                    
                    OnboardingStep4(draft: draft)
                        .tag(3)
                    
                    OnboardingStep5(draft: draft)
                        .tag(4)
                    
                    OnboardingSummaryView(
                        draft: draft,
                        onGenerate: { completeOnboarding() },
                        onSkip: { completeOnboarding() }
                    )
                    .tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                // Disable swipe if desired, or allow it. Requirement implies explicit Next/Back.
                // Disabling swipe for strict flow control.
                .gesture(DragGesture())
                
                // Footer (Next Button)
                if currentStep < totalSteps - 1 {
                    VStack {
                        Button {
                            withAnimation(.spring()) {
                                currentStep += 1
                            }
                        } label: {
                            Text("Next")
                                .font(DesignSystem.Typography.buttonLarge())
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(DesignSystem.Colors.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(DesignSystem.Spacing.screenPadding)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(themeManager.backgroundPrimary).opacity(0),
                                Color(themeManager.backgroundPrimary)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
        }
        .animation(.default, value: currentStep)
    }
    
    private func completeOnboarding() {
        // Mark as completed
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

#Preview {
    OnboardingFlow()
        .environment(ThemeManager())
}

