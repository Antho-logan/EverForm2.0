import SwiftUI
import Observation

struct OnboardingEntryFlowView: View {
    @Environment(OnboardingStore.self) private var store
    @State private var entryPhase: EntryPhase = .auth
    @State private var opacity = 0.0
    
    // Completion handler called when onboarding is fully done
    var onOnboardingFinished: () -> Void
    
    enum EntryPhase {
        case auth
        case questions
    }
    
    var body: some View {
        ZStack {
            // Shared Background
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            switch entryPhase {
            case .auth:
                AuthEntryView(onCreateAccount: {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        entryPhase = .questions
                    }
                })
                .transition(.move(edge: .leading).combined(with: .opacity))
                
            case .questions:
                QuestionOnboardingFlowView(onFinished: onOnboardingFinished)
                    .environment(store)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: entryPhase)
    }
}

// MARK: - Question Flow
struct QuestionOnboardingFlowView: View {
    @Environment(OnboardingStore.self) private var store
    @State private var showContent = false
    
    var onFinished: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header: Progress
            HStack {
                if store.currentQuestion != .basicName {
                    Button {
                        withAnimation {
                            store.previousQuestion()
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
                
                Text("Step \(store.currentQuestion.rawValue + 1) of \(OnboardingQuestion.allCases.count)")
                    .font(DesignSystem.Typography.labelMedium())
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(DesignSystem.Colors.backgroundSecondary))
                
                Spacer()
                
                Spacer().frame(width: 44) // Balance
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // Question Content
            TabView(selection: Bindable(store).currentQuestion) {
                ForEach(OnboardingQuestion.allCases, id: \.self) { question in
                    OnboardingQuestionView(question: question, onNext: {
                        if question == OnboardingQuestion.allCases.last {
                            onFinished()
                        } else {
                            withAnimation {
                                store.nextQuestion()
                            }
                        }
                    })
                    .tag(question)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            // Disable swipe to enforce "Next" logic and validation
            .gesture(DragGesture())
            
            Spacer()
        }
    }
}

struct OnboardingQuestionView: View {
    let question: OnboardingQuestion
    let onNext: () -> Void
    
    @Environment(OnboardingStore.self) private var store
    @State private var optionsVisible = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer().frame(height: 20)
            
            // Typewriter Title
            TypewriterText(
                text: question.title,
                font: DesignSystem.Typography.displayMedium(),
                onComplete: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        optionsVisible = true
                    }
                }
            )
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            
            // Content container
            if optionsVisible {
                VStack(spacing: 24) {
                    questionContent
                    
                    // Next Button
                    Button {
                        onNext()
                    } label: {
                        Text(question == .dietaryApproach ? "Finish" : "Next")
                            .font(DesignSystem.Typography.buttonLarge())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(DesignSystem.Colors.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.top, 16)
                    .disabled(!isValid)
                    .opacity(isValid ? 1.0 : 0.5)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.horizontal, 24)
            }
            
            Spacer()
        }
        .onAppear {
            // Reset visibility on appear to re-trigger animation if navigating back/forth
            optionsVisible = false
        }
    }
    
    private var isValid: Bool {
        switch question {
        case .basicName:
            return !store.draft.name.trimmingCharacters(in: .whitespaces).isEmpty
        case .sex:
            return true // default is set
        case .birthdate:
            return true // default is set
        case .height:
            return store.draft.heightCm > 0
        case .weight:
            return (store.draft.weightKg ?? 0) > 0
        case .primaryGoal:
            return true // default is set
        case .activityLevel:
            return true // default is set
        case .dietaryApproach:
            return true // default is set
        }
    }
    
    @ViewBuilder
    private var questionContent: some View {
        switch question {
        case .basicName:
            TextField("Your name", text: Bindable(store).draft.name)
                .textFieldStyle(OnboardingTextFieldStyle())
                .textContentType(.name)
            
        case .sex:
            Picker("Sex", selection: Bindable(store).draft.sex) {
                ForEach(UserProfile.Sex.allCases, id: \.self) { sex in
                    Text(sex.rawValue.capitalized).tag(sex)
                }
            }
            .pickerStyle(.wheel)
            
        case .birthdate:
            DatePicker(
                "Birthdate",
                selection: Bindable(store).draft.birthdate,
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            
        case .height:
            HStack {
                TextField("175", value: Bindable(store).draft.heightCm, format: .number)
                    .textFieldStyle(OnboardingTextFieldStyle())
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                Text("cm").font(DesignSystem.Typography.titleMedium())
            }
            
        case .weight:
            HStack {
                TextField("70", value: Bindable(store).draft.weightKg, format: .number)
                    .textFieldStyle(OnboardingTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                Text("kg").font(DesignSystem.Typography.titleMedium())
            }
            
        case .primaryGoal:
            Picker("Goal", selection: Bindable(store).draft.goal) {
                ForEach(UserProfile.Goal.allCases, id: \.self) { goal in
                    Text(goal.rawValue).tag(goal)
                }
            }
            .pickerStyle(.wheel)
            
        case .activityLevel:
            Picker("Activity", selection: Bindable(store).draft.activity) {
                ForEach(UserProfile.Activity.allCases, id: \.self) { activity in
                    Text(activity.rawValue).tag(activity)
                }
            }
            .pickerStyle(.wheel)
            
        case .dietaryApproach:
            Picker("Diet", selection: Bindable(store).draft.diet) {
                ForEach(UserProfile.Diet.allCases, id: \.self) { diet in
                    Text(diet.rawValue).tag(diet)
                }
            }
            .pickerStyle(.wheel)
        }
    }
}

// MARK: - Styles
struct OnboardingTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(DesignSystem.Typography.titleMedium())
            .padding()
            .background(DesignSystem.Colors.backgroundSecondary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
    }
}

