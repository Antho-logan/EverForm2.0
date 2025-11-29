import SwiftUI
import Observation

// MARK: - Shared View Modifier for Step Transition
struct OnboardingStepModifier: ViewModifier {
    let show: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(show ? 1 : 0)
            .offset(y: show ? 0 : 10)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: show)
    }
}

extension View {
    func onboardingStepContent(show: Bool) -> some View {
        modifier(OnboardingStepModifier(show: show))
    }
}

// MARK: - Step 1: Help with
struct OnboardingStep1: View {
    @Bindable var draft: OnboardingDraftState
    @State private var showOptions = false
    
    let options = [
        "Training & performance",
        "Nutrition & fat loss",
        "Recovery & sleep",
        "Fixing pain & injuries",
        "Mobility & flexibility",
        "Breathwork & stress",
        "LookMax & aesthetics"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            TypewriterText(
                text: "What do you want EverForm to help you with?",
                font: DesignSystem.Typography.displayMedium(),
                onComplete: { showOptions = true }
            )
            .padding(.horizontal, DesignSystem.Spacing.screenPadding)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        let isSelected = draft.primaryModules.contains(option)
                        Button {
                            if isSelected {
                                draft.primaryModules.removeAll { $0 == option }
                            } else {
                                draft.primaryModules.append(option)
                            }
                        } label: {
                            Text(option)
                                .font(DesignSystem.Typography.bodyMedium())
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: .infinity)
                                .background(isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.backgroundSecondary)
                                .foregroundStyle(isSelected ? .white : DesignSystem.Colors.textPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(DesignSystem.Colors.border, lineWidth: isSelected ? 0 : 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                .padding(.bottom, 20)
            }
            .onboardingStepContent(show: showOptions)
        }
    }
}

// MARK: - Step 2: Body & Goal
struct OnboardingStep2: View {
    @Bindable var draft: OnboardingDraftState
    @State private var showOptions = false
    @State private var showSecondQuestion = false
    
    let goals = [
        "Lose fat", "Build muscle", "Improve energy & focus",
        "Reduce pain", "Improve sleep & recovery", "Look better / aesthetics"
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Question 1
                TypewriterText(
                    text: "Tell us a bit about your body.",
                    font: DesignSystem.Typography.displayMedium(),
                    onComplete: { showOptions = true }
                )
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                
                // Inputs
                VStack(spacing: 20) {
                    Picker("Sex", selection: $draft.sex) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                        Text("Other").tag("Other")
                    }
                    .pickerStyle(.segmented)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Age").font(DesignSystem.Typography.labelMedium())
                            TextField("30", value: $draft.age, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                        }
                        VStack(alignment: .leading) {
                            Text("Height (cm)").font(DesignSystem.Typography.labelMedium())
                            TextField("175", value: $draft.heightCm, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                        }
                        VStack(alignment: .leading) {
                            Text("Weight (kg)").font(DesignSystem.Typography.labelMedium())
                            TextField("75", value: $draft.weightKg, format: .number)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.decimalPad)
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                .onboardingStepContent(show: showOptions)
                .onChange(of: showOptions) { _, shown in
                    if shown {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            showSecondQuestion = true
                        }
                    }
                }
                
                // Question 2
                if showOptions {
                    VStack(alignment: .leading, spacing: 20) {
                        TypewriterText(
                            text: "What’s your main goal right now?",
                            font: DesignSystem.Typography.displayMedium(),
                            startDelay: 0, // Immediate when shown
                            onComplete: {}
                        )
                        
                        // Goals
                        ForEach(goals, id: \.self) { goal in
                            let isSelected = draft.primaryGoal == goal
                            Button {
                                draft.primaryGoal = goal
                            } label: {
                                HStack {
                                    Text(goal)
                                    Spacer()
                                    if isSelected {
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .padding()
                                .background(isSelected ? DesignSystem.Colors.accent.opacity(0.1) : DesignSystem.Colors.backgroundSecondary)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.border, lineWidth: 1)
                                )
                            }
                            .foregroundStyle(DesignSystem.Colors.textPrimary)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                    .onboardingStepContent(show: showSecondQuestion)
                }
                
                Spacer().frame(height: 40)
            }
        }
    }
}

// MARK: - Step 3: Time & Equipment
struct OnboardingStep3: View {
    @Bindable var draft: OnboardingDraftState
    @State private var showOptions = false
    @State private var showSecondQuestion = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                TypewriterText(
                    text: "How much time can you realistically invest?",
                    font: DesignSystem.Typography.displayMedium(),
                    onComplete: { showOptions = true }
                )
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Days
                    VStack(alignment: .leading) {
                        Text("Days per week").font(DesignSystem.Typography.labelMedium())
                        Picker("Days", selection: $draft.trainingDaysPerWeek) {
                            Text("1-2").tag("1-2")
                            Text("3-4").tag("3-4")
                            Text("5+").tag("5+")
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Length
                    VStack(alignment: .leading) {
                        Text("Session length").font(DesignSystem.Typography.labelMedium())
                        Picker("Length", selection: $draft.sessionLengthPreference) {
                            Text("20-30m").tag("20-30 min")
                            Text("30-45m").tag("30-45 min")
                            Text("45-60+m").tag("45-60+ min")
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Experience
                    VStack(alignment: .leading) {
                        Text("Experience").font(DesignSystem.Typography.labelMedium())
                        Picker("Exp", selection: $draft.trainingExperience) {
                            Text("Beginner").tag("Beginner")
                            Text("Intermediate").tag("Intermediate")
                            Text("Advanced").tag("Advanced")
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                .onboardingStepContent(show: showOptions)
                .onChange(of: showOptions) { _, shown in
                    if shown {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            showSecondQuestion = true
                        }
                    }
                }
                
                if showOptions {
                    VStack(alignment: .leading, spacing: 16) {
                        TypewriterText(
                            text: "What equipment do you have access to?",
                            font: DesignSystem.Typography.titleLarge(),
                            startDelay: 0
                        )
                        
                        let equipment = ["Gym with machines", "Free weights", "Home bands", "Just bodyweight"]
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(equipment, id: \.self) { item in
                                let isSelected = draft.equipmentAvailable.contains(item)
                                Button {
                                    if isSelected {
                                        draft.equipmentAvailable.removeAll { $0 == item }
                                    } else {
                                        draft.equipmentAvailable.append(item)
                                    }
                                } label: {
                                    Text(item)
                                        .font(DesignSystem.Typography.bodySmall())
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.backgroundSecondary)
                                        .foregroundStyle(isSelected ? .white : DesignSystem.Colors.textPrimary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                    .onboardingStepContent(show: showSecondQuestion)
                }
            }
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Step 4: Pain
struct OnboardingStep4: View {
    @Bindable var draft: OnboardingDraftState
    @State private var showOptions = false
    @State private var showMobility = false
    
    let areas = ["Lower back", "Neck / shoulders", "Knees", "Hips", "Ankles / feet", "Other"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                TypewriterText(
                    text: "Any pain or injuries we should know about?",
                    font: DesignSystem.Typography.displayMedium(),
                    onComplete: { showOptions = true }
                )
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                
                VStack(alignment: .leading, spacing: 20) {
                    Toggle("I have pain or injuries", isOn: $draft.hasPain)
                        .toggleStyle(SwitchToggleStyle(tint: DesignSystem.Colors.accent))
                    
                    if draft.hasPain {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(areas, id: \.self) { area in
                                let isSelected = draft.painAreas.contains(area)
                                Button {
                                    if isSelected {
                                        draft.painAreas.removeAll { $0 == area }
                                    } else {
                                        draft.painAreas.append(area)
                                    }
                                } label: {
                                    Text(area)
                                        .font(DesignSystem.Typography.bodySmall())
                                        .padding(10)
                                        .frame(maxWidth: .infinity)
                                        .background(isSelected ? DesignSystem.Colors.accent.opacity(0.1) : DesignSystem.Colors.backgroundSecondary)
                                        .foregroundStyle(isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.textPrimary)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.border, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        
                        TextField("Anything specific?", text: $draft.painNotes)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                .onboardingStepContent(show: showOptions)
                .onChange(of: showOptions) { _, shown in
                    if shown {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            showMobility = true
                        }
                    }
                }
                
                if showOptions {
                    VStack(alignment: .leading, spacing: 16) {
                        TypewriterText(
                            text: "How would you describe your mobility?",
                            font: DesignSystem.Typography.titleLarge(),
                            startDelay: 0
                        )
                        
                        Picker("Mobility", selection: $draft.mobilityLevel) {
                            Text("Very stiff").tag("Very stiff")
                            Text("Average").tag("Average")
                            Text("Pretty mobile").tag("Pretty mobile")
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                    .onboardingStepContent(show: showMobility)
                }
            }
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Step 5: Lifestyle
struct OnboardingStep5: View {
    @Bindable var draft: OnboardingDraftState
    @State private var showOptions = false
    @State private var showLifestyle = false
    
    let diets = ["No specific diet", "High protein", "Vegetarian", "Vegan", "Low carb", "Halal / Kosher", "Gluten free", "Lactose sensitive"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                TypewriterText(
                    text: "How do you like to eat?",
                    font: DesignSystem.Typography.displayMedium(),
                    onComplete: { showOptions = true }
                )
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 12) {
                    ForEach(diets, id: \.self) { diet in
                        let isSelected = draft.dietPreferences.contains(diet)
                        Button {
                            if isSelected {
                                draft.dietPreferences.removeAll { $0 == diet }
                            } else {
                                draft.dietPreferences.append(diet)
                            }
                        } label: {
                            Text(diet)
                                .font(DesignSystem.Typography.bodySmall())
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.backgroundSecondary)
                                .foregroundStyle(isSelected ? .white : DesignSystem.Colors.textPrimary)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                .onboardingStepContent(show: showOptions)
                .onChange(of: showOptions) { _, shown in
                    if shown {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            showLifestyle = true
                        }
                    }
                }
                
                if showOptions {
                    VStack(alignment: .leading, spacing: 24) {
                        TypewriterText(
                            text: "How is your lifestyle right now?",
                            font: DesignSystem.Typography.titleLarge(),
                            startDelay: 0
                        )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Average sleep").font(DesignSystem.Typography.labelMedium())
                            Picker("Sleep", selection: $draft.sleepHoursBand) {
                                Text("< 6h").tag("< 6 hours")
                                Text("6-7h").tag("6-7 hours")
                                Text("7-8h").tag("7-8 hours")
                                Text("8+h").tag("8+ hours")
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Activity level").font(DesignSystem.Typography.labelMedium())
                            Picker("Activity", selection: $draft.activityLevel) {
                                Text("Sitting").tag("Mostly sitting")
                                Text("Standing").tag("On my feet sometimes")
                                Text("Active").tag("Moving a lot")
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                    .onboardingStepContent(show: showLifestyle)
                }
            }
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Step Summary
struct OnboardingSummaryView: View {
    @Bindable var draft: OnboardingDraftState
    @State private var showContent = false
    var onGenerate: () -> Void
    var onSkip: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            TypewriterText(
                text: "All set, ready for your plan?",
                font: DesignSystem.Typography.displayLarge(),
                onComplete: { showContent = true }
            )
            .padding(.horizontal, DesignSystem.Spacing.screenPadding)
            
            VStack(spacing: 20) {
                // Summary Card
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Profile Summary")
                        .font(DesignSystem.Typography.titleMedium())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                    
                    Divider()
                    
                    SummaryRow(icon: "target", title: "Goal", value: draft.primaryGoal.isEmpty ? "Not set" : draft.primaryGoal)
                    SummaryRow(icon: "calendar", title: "Commitment", value: "\(draft.trainingDaysPerWeek) days, \(draft.sessionLengthPreference)")
                    SummaryRow(icon: "heart.fill", title: "Focus", value: draft.primaryModules.isEmpty ? "General" : draft.primaryModules.prefix(2).joined(separator: ", "))
                }
                .padding(20)
                .background(DesignSystem.Colors.cardBackground)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
                
                Spacer()
                
                Button {
                    onGenerate()
                } label: {
                    Text("Generate my plan")
                        .font(DesignSystem.Typography.buttonLarge())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(DesignSystem.Colors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: DesignSystem.Colors.accent.opacity(0.3), radius: 10, y: 5)
                }
                
                Button {
                    onSkip()
                } label: {
                    Text("Skip for now")
                        .font(DesignSystem.Typography.buttonMedium())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
            }
            .padding(DesignSystem.Spacing.screenPadding)
            .onboardingStepContent(show: showContent)
        }
    }
}

struct SummaryRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(DesignSystem.Colors.accent)
                .frame(width: 24)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(DesignSystem.Typography.labelSmall())
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                Text(value)
                    .font(DesignSystem.Typography.bodyMedium())
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
            }
        }
    }
}

