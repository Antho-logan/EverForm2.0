//
//  LookMaxingStartView.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import SwiftUI
import PhotosUI
import Foundation

// MARK: - Models

struct LookMaxAssessment: Identifiable, Codable {
    var id: UUID = .init()
    var createdAt: Date = .init()

    // Photos
    var frontPhotoData: Data?
    var sidePhotoData: Data?
    var backPhotoData: Data?

    // Area of focus
    var primaryGoalArea: LookMaxArea?
    var secondaryAreas: [LookMaxArea] = []

    // User’s description
    var mainConcern: String = ""
    var desiredOutcome: String = ""

    // Context
    var ageRange: AgeRange?
    var genderPresentation: GenderPresentation?
    var lifestyleLevel: LifestyleLevel?
    var budgetLevel: BudgetLevel?

    // Constraints/preferences
    var avoidsSurgery: Bool = true
    var avoidsInjections: Bool = true
    var avoidsPrescriptionMeds: Bool = true
    var timePerDayMinutes: Int = 10
    var timePerWeekMinutes: Int = 60

    var notes: String = ""
}

enum LookMaxArea: String, CaseIterable, Codable, Identifiable {
    case skin = "Skin"
    case hair = "Hair"
    case jawline = "Jawline"
    case teeth = "Teeth"
    case physique = "Physique"
    case posture = "Posture"
    case style = "Style"
    case eyes = "Eyes"
    case generalGlow = "General Glow"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .skin: return "sparkles"
        case .hair: return "comb.fill"
        case .jawline: return "face.smiling"
        case .teeth: return "mouth"
        case .physique: return "figure.arms.open"
        case .posture: return "figure.stand"
        case .style: return "tshirt.fill"
        case .eyes: return "eye.fill"
        case .generalGlow: return "sun.max.fill"
        }
    }
}

enum AgeRange: String, CaseIterable, Codable, Identifiable {
    case age18_24 = "18-24"
    case age25_34 = "25-34"
    case age35_44 = "35-44"
    case age45plus = "45+"
    
    var id: String { rawValue }
}

enum GenderPresentation: String, CaseIterable, Codable, Identifiable {
    case masculine = "Masculine"
    case feminine = "Feminine"
    case androgynous = "Androgynous"
    case other = "Other"
    
    var id: String { rawValue }
}

enum LifestyleLevel: String, CaseIterable, Codable, Identifiable {
    case sedentary = "Sedentary"
    case lightlyActive = "Lightly Active"
    case active = "Active"
    case athlete = "Athlete"
    
    var id: String { rawValue }
}

enum BudgetLevel: String, CaseIterable, Codable, Identifiable {
    case low = "Low ($)"
    case medium = "Medium ($$)"
    case high = "High ($$$)"
    
    var id: String { rawValue }
}

struct LookMaxPlan: Identifiable, Codable {
    var id: UUID = .init()
    var createdAt: Date = .init()
    var summaryTitle: String
    var overviewText: String

    var dailyHabits: [LookMaxAction]
    var weeklyActions: [LookMaxAction]
    var monthlyActions: [LookMaxAction]

    var mindsetTips: [String]
    var safetyNotes: [String]
}

struct LookMaxAction: Identifiable, Codable {
    var id: UUID = .init()
    var area: LookMaxArea
    var title: String
    var description: String
    var estimatedMinutes: Int
    var frequencyLabel: String
}

// MARK: - ViewModel

@Observable
final class LookMaxViewModel {
    var currentAssessment: LookMaxAssessment?
    var currentPlan: LookMaxPlan?
    var history: [LookMaxPlan] = []
    
    func startNewAssessment() {
        currentAssessment = LookMaxAssessment()
        currentPlan = nil
    }
    
    func generatePlan(from assessment: LookMaxAssessment) {
        let primaryArea = assessment.primaryGoalArea ?? .generalGlow
        let secondaryAreas = assessment.secondaryAreas
        
        var summaryTitle = "Glow Up Plan"
        if let area = assessment.primaryGoalArea {
            summaryTitle = "Better \(area.rawValue) & Habits"
        }
        
        var overview = "Based on your goal for \(primaryArea.rawValue.lowercased()), we've designed a routine that fits your \(assessment.lifestyleLevel?.rawValue.lowercased() ?? "active") lifestyle. It respects your budget and time constraints."
        
        // Daily Habits
        var dailyHabits: [LookMaxAction] = []
        
        if primaryArea == .skin || secondaryAreas.contains(.skin) {
            dailyHabits.append(LookMaxAction(
                area: .skin,
                title: "AM Skincare",
                description: "Cleanse, Vitamin C serum, and SPF 50+. Essential for protection.",
                estimatedMinutes: 5,
                frequencyLabel: "Daily"
            ))
            dailyHabits.append(LookMaxAction(
                area: .skin,
                title: "PM Repair",
                description: "Gentle cleanser, Retinol (if not sensitive), Moisturizer.",
                estimatedMinutes: 5,
                frequencyLabel: "Daily"
            ))
        }
        
        if primaryArea == .jawline || secondaryAreas.contains(.jawline) || primaryArea == .posture || secondaryAreas.contains(.posture) {
            dailyHabits.append(LookMaxAction(
                area: .posture,
                title: "Chin Tucks & Mewing",
                description: "Keep tongue on the roof of mouth. Do 10 chin tucks to align neck.",
                estimatedMinutes: 3,
                frequencyLabel: "Daily"
            ))
        }
        
        if primaryArea == .hair || secondaryAreas.contains(.hair) {
             dailyHabits.append(LookMaxAction(
                area: .hair,
                title: "Scalp Massage",
                description: "Stimulate blood flow for 2 minutes before bed.",
                estimatedMinutes: 2,
                frequencyLabel: "Daily"
            ))
        }
        
        // Ensure we respect time limit somewhat
        if dailyHabits.isEmpty {
             dailyHabits.append(LookMaxAction(
                area: .generalGlow,
                title: "Hydration & Sleep",
                description: "Drink 3L water, aim for 8h sleep.",
                estimatedMinutes: 0,
                frequencyLabel: "Daily"
            ))
        }
        
        // Weekly Actions
        var weeklyActions: [LookMaxAction] = []
        
        if primaryArea == .skin || secondaryAreas.contains(.skin) {
            weeklyActions.append(LookMaxAction(
                area: .skin,
                title: "Exfoliation",
                description: "Chemical exfoliant (AHA/BHA) to remove dead skin cells.",
                estimatedMinutes: 10,
                frequencyLabel: "1-2x / Week"
            ))
        }
        
        if primaryArea == .physique || secondaryAreas.contains(.physique) {
            weeklyActions.append(LookMaxAction(
                area: .physique,
                title: "Heavy Lift Session",
                description: "Focus on compound movements: Deadlift, Squat, Bench.",
                estimatedMinutes: 60,
                frequencyLabel: "3x / Week"
            ))
        }
        
        // Monthly Actions
        var monthlyActions: [LookMaxAction] = []
        monthlyActions.append(LookMaxAction(
            area: .generalGlow,
            title: "Progress Photos",
            description: "Re-take front and side photos in same lighting to track changes.",
            estimatedMinutes: 5,
            frequencyLabel: "Monthly"
        ))
        
        if primaryArea == .hair {
            monthlyActions.append(LookMaxAction(
                area: .hair,
                title: "Barber / Stylist Visit",
                description: "Maintenance cut to keep shape sharp.",
                estimatedMinutes: 45,
                frequencyLabel: "Monthly"
            ))
        }
        
        let plan = LookMaxPlan(
            summaryTitle: summaryTitle,
            overviewText: overview,
            dailyHabits: dailyHabits,
            weeklyActions: weeklyActions,
            monthlyActions: monthlyActions,
            mindsetTips: [
                "Consistency beats intensity.",
                "Focus on health first, aesthetics follow.",
                "Compare yourself to who you were yesterday, not others."
            ],
            safetyNotes: [
                "If a product burns, wash it off immediately.",
                "Don't force jaw movements if it hurts TMJ.",
                "Consult a doctor for persistent acne or hair loss."
            ]
        )
        
        self.currentPlan = plan
        history.insert(plan, at: 0)
    }
}

// MARK: - Result View

struct LookMaxResultView: View {
    let plan: LookMaxPlan
    @Binding var isPresented: Bool
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 24, pinnedViews: [.sectionHeaders]) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(plan.summaryTitle)
                        .font(DesignSystem.Typography.displaySmall())
                    Text(plan.overviewText)
                        .font(DesignSystem.Typography.bodyMedium())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Daily Focus
                Section {
                    VStack(spacing: 12) {
                        ForEach(plan.dailyHabits) { action in
                            LookMaxActionCard(action: action)
                        }
                    }
                    .padding(.horizontal, 20)
                } header: {
                    LookMaxSectionHeader(title: "Daily Focus")
                }
                
                // Weekly Focus
                if !plan.weeklyActions.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            ForEach(plan.weeklyActions) { action in
                                LookMaxActionCard(action: action)
                            }
                        }
                        .padding(.horizontal, 20)
                    } header: {
                        LookMaxSectionHeader(title: "Weekly Focus")
                    }
                }
                
                // Monthly Focus
                if !plan.monthlyActions.isEmpty {
                    Section {
                        VStack(spacing: 12) {
                            ForEach(plan.monthlyActions) { action in
                                LookMaxActionCard(action: action)
                            }
                        }
                        .padding(.horizontal, 20)
                    } header: {
                        LookMaxSectionHeader(title: "Monthly Focus")
                    }
                }
                
                // Mindset & Safety
                VStack(alignment: .leading, spacing: 16) {
                    Text("Mindset & Safety")
                        .font(DesignSystem.Typography.sectionHeader())
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(plan.mindsetTips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "brain.head.profile")
                                    .foregroundStyle(DesignSystem.Colors.accent)
                                Text(tip)
                                    .font(DesignSystem.Typography.bodyMedium())
                            }
                        }
                        
                        Divider().padding(.vertical, 4)
                        
                        ForEach(plan.safetyNotes, id: \.self) { note in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.shield.fill")
                                    .foregroundStyle(DesignSystem.Colors.warning)
                                Text(note)
                                    .font(DesignSystem.Typography.bodyMedium())
                                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                            }
                        }
                        
                        Text("EverForm is not a medical service. For medical or surgical questions, consult a professional.")
                            .font(DesignSystem.Typography.caption())
                            .foregroundStyle(DesignSystem.Colors.textSecondary)
                            .padding(.top, 8)
                    }
                    .padding(16)
                    .background(DesignSystem.Colors.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 20)
                
                Button("Done") {
                    isPresented = false
                }
                .buttonSecondaryStyle()
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LookMaxSectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(DesignSystem.Typography.sectionHeader())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(DesignSystem.Colors.background.opacity(0.95))
    }
}

struct LookMaxActionCard: View {
    let action: LookMaxAction
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(DesignSystem.Colors.accent.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: action.area.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(DesignSystem.Colors.accent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(action.title)
                        .font(DesignSystem.Typography.headline())
                    Spacer()
                    Text(action.frequencyLabel)
                        .font(DesignSystem.Typography.caption())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(DesignSystem.Colors.neutral100)
                        .clipShape(Capsule())
                }
                
                Text(action.description)
                    .font(DesignSystem.Typography.bodyMedium())
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                
                if action.estimatedMinutes > 0 {
                    Text("~\(action.estimatedMinutes) min")
                        .font(DesignSystem.Typography.caption())
                        .foregroundStyle(DesignSystem.Colors.neutral400)
                        .padding(.top, 2)
                }
            }
        }
        .padding(16)
        .background(DesignSystem.Colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Wizard View

enum LookMaxStep {
    case intro, photos, goalArea, concerns, context, constraints, review
}

struct LookMaxWizardView: View {
    @Bindable var viewModel: LookMaxViewModel
    @Binding var isPresented: Bool
    @State private var step: LookMaxStep = .intro
    @State private var showResult = false
    
    @State private var frontItem: PhotosPickerItem?
    @State private var sideItem: PhotosPickerItem?
    @State private var backItem: PhotosPickerItem?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if step != .intro {
                    HStack(spacing: 4) {
                        ForEach(0..<7) { index in
                            Rectangle()
                                .fill(index <= stepIndex ? DesignSystem.Colors.accent : DesignSystem.Colors.neutral200)
                                .frame(height: 4)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        switch step {
                        case .intro:
                            IntroStep(onNext: { withAnimation { step = .photos } })
                        case .photos:
                            PhotosStep(
                                assessment: Binding(get: { viewModel.currentAssessment ?? LookMaxAssessment() }, set: { viewModel.currentAssessment = $0 }),
                                frontItem: $frontItem, sideItem: $sideItem, backItem: $backItem
                            )
                        case .goalArea:
                            GoalAreaStep(assessment: Binding(get: { viewModel.currentAssessment ?? LookMaxAssessment() }, set: { viewModel.currentAssessment = $0 }))
                        case .concerns:
                            ConcernsStep(assessment: Binding(get: { viewModel.currentAssessment ?? LookMaxAssessment() }, set: { viewModel.currentAssessment = $0 }))
                        case .context:
                            ContextStep(assessment: Binding(get: { viewModel.currentAssessment ?? LookMaxAssessment() }, set: { viewModel.currentAssessment = $0 }))
                        case .constraints:
                            ConstraintsStep(assessment: Binding(get: { viewModel.currentAssessment ?? LookMaxAssessment() }, set: { viewModel.currentAssessment = $0 }))
                        case .review:
                            ReviewStep(assessment: Binding(get: { viewModel.currentAssessment ?? LookMaxAssessment() }, set: { viewModel.currentAssessment = $0 })) {
                                if let assessment = viewModel.currentAssessment {
                                    viewModel.generatePlan(from: assessment)
                                    showResult = true
                                }
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
                
                if step != .intro {
                    HStack {
                        if step != .photos {
                            Button("Back") { withAnimation { goBack() } }
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                        } else {
                             Button("Back") { withAnimation { step = .intro } }
                                 .foregroundStyle(DesignSystem.Colors.textSecondary)
                        }
                        Spacer()
                        if step != .review {
                            Button("Next") { withAnimation { goNext() } }
                                .buttonPrimaryStyle()
                                .frame(width: 120)
                        }
                    }
                    .padding(20)
                    .background(DesignSystem.Colors.background)
                }
            }
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                }
            }
            .navigationDestination(isPresented: $showResult) {
                if let plan = viewModel.currentPlan {
                    LookMaxResultView(plan: plan, isPresented: $isPresented)
                }
            }
        }
        .onChange(of: frontItem) { _, newItem in
             Task {
                 if let data = try? await newItem?.loadTransferable(type: Data.self) {
                     viewModel.currentAssessment?.frontPhotoData = data
                 }
             }
        }
        .onChange(of: sideItem) { _, newItem in
             Task {
                 if let data = try? await newItem?.loadTransferable(type: Data.self) {
                     viewModel.currentAssessment?.sidePhotoData = data
                 }
             }
        }
        .onChange(of: backItem) { _, newItem in
             Task {
                 if let data = try? await newItem?.loadTransferable(type: Data.self) {
                     viewModel.currentAssessment?.backPhotoData = data
                 }
             }
        }
    }
    
    private var stepTitle: String {
        switch step {
        case .intro: return "Welcome"
        case .photos: return "Photos"
        case .goalArea: return "Goals"
        case .concerns: return "Concerns"
        case .context: return "Context"
        case .constraints: return "Preferences"
        case .review: return "Review"
        }
    }
    
    private var stepIndex: Int {
        switch step {
        case .intro: return 0
        case .photos: return 0
        case .goalArea: return 1
        case .concerns: return 2
        case .context: return 3
        case .constraints: return 4
        case .review: return 5
        }
    }
    
    private func goNext() {
        switch step {
        case .intro: step = .photos
        case .photos: step = .goalArea
        case .goalArea: step = .concerns
        case .concerns: step = .context
        case .context: step = .constraints
        case .constraints: step = .review
        case .review: break
        }
    }
    
    private func goBack() {
        switch step {
        case .intro: break
        case .photos: step = .intro
        case .goalArea: step = .photos
        case .concerns: step = .goalArea
        case .context: step = .concerns
        case .constraints: step = .context
        case .review: step = .constraints
        }
    }
}

struct IntroStep: View {
    let onNext: () -> Void
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundStyle(DesignSystem.Colors.accent)
                .padding()
                .background(Circle().fill(DesignSystem.Colors.accent.opacity(0.1)))
            Text("Let’s build your glow-up plan.")
                .font(DesignSystem.Typography.displayMedium())
                .multilineTextAlignment(.center)
            Text("Upload a few photos, tell us what you want to change, and we’ll design a realistic, healthy Look Max roadmap.")
                .font(DesignSystem.Typography.bodyLarge())
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
            Button(action: onNext) {
                Text("Continue")
                    .font(DesignSystem.Typography.buttonLarge())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(DesignSystem.Colors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 20)
        }
    }
}

struct PhotosStep: View {
    @Binding var assessment: LookMaxAssessment
    @Binding var frontItem: PhotosPickerItem?
    @Binding var sideItem: PhotosPickerItem?
    @Binding var backItem: PhotosPickerItem?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Add photos")
                .font(DesignSystem.Typography.displaySmall())
            Text("These stay private on your device unless you choose to sync.")
                .font(DesignSystem.Typography.bodyMedium())
                .foregroundStyle(DesignSystem.Colors.textSecondary)
            
            LookMaxPhotoCard(title: "Front View", caption: "Neutral face, natural lighting.", imageData: assessment.frontPhotoData, item: $frontItem)
            LookMaxPhotoCard(title: "Side View", caption: "Turn 90°, relaxed jaw.", imageData: assessment.sidePhotoData, item: $sideItem)
            LookMaxPhotoCard(title: "Back View (Optional)", caption: "For posture/back goals.", imageData: assessment.backPhotoData, item: $backItem)
        }
        .padding(.horizontal, 20)
    }
}

struct LookMaxPhotoCard: View {
    let title: String
    let caption: String
    let imageData: Data?
    @Binding var item: PhotosPickerItem?
    
    var body: some View {
        PhotosPicker(selection: $item, matching: .images) {
            HStack(spacing: 16) {
                if let data = imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .transition(.scale(scale: 0.95).combined(with: .opacity))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(DesignSystem.Colors.neutral100)
                            .frame(width: 80, height: 80)
                        Image(systemName: "camera.fill")
                            .foregroundStyle(DesignSystem.Colors.neutral400)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(DesignSystem.Typography.headline())
                        .foregroundStyle(DesignSystem.Colors.textPrimary)
                    Text(caption)
                        .font(DesignSystem.Typography.caption())
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                }
                Spacer()
                if imageData != nil {
                    Text("Change")
                        .font(DesignSystem.Typography.labelSmall())
                        .foregroundStyle(DesignSystem.Colors.accent)
                } else {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(DesignSystem.Colors.accent)
                        .font(.title2)
                }
            }
            .padding(12)
            .background(DesignSystem.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

struct GoalAreaStep: View {
    @Binding var assessment: LookMaxAssessment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("What do you want to improve first?")
                .font(DesignSystem.Typography.displaySmall())
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                ForEach(LookMaxArea.allCases) { area in
                    let isSelected = assessment.primaryGoalArea == area || assessment.secondaryAreas.contains(area)
                    Button {
                        if assessment.primaryGoalArea == area {
                            assessment.primaryGoalArea = nil
                        } else if assessment.primaryGoalArea == nil {
                            assessment.primaryGoalArea = area
                        } else {
                            if let idx = assessment.secondaryAreas.firstIndex(of: area) {
                                assessment.secondaryAreas.remove(at: idx)
                            } else {
                                assessment.secondaryAreas.append(area)
                            }
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: area.icon)
                                .font(.title2)
                            Text(area.rawValue)
                                .font(DesignSystem.Typography.labelMedium())
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isSelected ? DesignSystem.Colors.accent.opacity(0.1) : DesignSystem.Colors.cardBackground)
                        .foregroundStyle(isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.textPrimary)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? DesignSystem.Colors.accent : Color.clear, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            
            if let primary = assessment.primaryGoalArea {
                Text("Primary Focus: \(primary.rawValue)")
                    .font(DesignSystem.Typography.bodySmall())
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
                    .padding(.top, 8)
            }
        }
        .padding(.horizontal, 20)
    }
}

struct ConcernsStep: View {
    @Binding var assessment: LookMaxAssessment
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Tell us about it")
                .font(DesignSystem.Typography.displaySmall())
            VStack(alignment: .leading, spacing: 8) {
                Text("What bothers you right now?")
                    .font(DesignSystem.Typography.headline())
                TextField("e.g., acne on cheeks, weak jawline", text: $assessment.mainConcern, axis: .vertical)
                    .lineLimit(3...4)
                    .padding()
                    .background(DesignSystem.Colors.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Desired outcome")
                    .font(DesignSystem.Typography.headline())
                TextField("e.g., clearer skin, sharper definition", text: $assessment.desiredOutcome, axis: .vertical)
                    .lineLimit(3...4)
                    .padding()
                    .background(DesignSystem.Colors.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Notes (Optional)")
                    .font(DesignSystem.Typography.headline())
                TextField("Anything you absolutely DON'T want to do?", text: $assessment.notes, axis: .vertical)
                    .lineLimit(2...3)
                    .padding()
                    .background(DesignSystem.Colors.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, 20)
    }
}

struct ContextStep: View {
    @Binding var assessment: LookMaxAssessment
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Your Context")
                .font(DesignSystem.Typography.displaySmall())
            Text("This helps tailor advice that fits your life.")
                .font(DesignSystem.Typography.bodyMedium())
                .foregroundStyle(DesignSystem.Colors.textSecondary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Age Range")
                    .font(DesignSystem.Typography.headline())
                Picker("Age", selection: $assessment.ageRange) {
                    Text("Select").tag(Optional<AgeRange>.none)
                    ForEach(AgeRange.allCases) { range in Text(range.rawValue).tag(Optional(range)) }
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Gender Presentation")
                    .font(DesignSystem.Typography.headline())
                Picker("Gender", selection: $assessment.genderPresentation) {
                    Text("Select").tag(Optional<GenderPresentation>.none)
                    ForEach(GenderPresentation.allCases) { gender in Text(gender.rawValue).tag(Optional(gender)) }
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Lifestyle")
                    .font(DesignSystem.Typography.headline())
                Picker("Lifestyle", selection: $assessment.lifestyleLevel) {
                    Text("Select").tag(Optional<LifestyleLevel>.none)
                    ForEach(LifestyleLevel.allCases) { level in Text(level.rawValue).tag(Optional(level)) }
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Budget")
                    .font(DesignSystem.Typography.headline())
                Picker("Budget", selection: $assessment.budgetLevel) {
                    Text("Select").tag(Optional<BudgetLevel>.none)
                    ForEach(BudgetLevel.allCases) { level in Text(level.rawValue).tag(Optional(level)) }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

struct ConstraintsStep: View {
    @Binding var assessment: LookMaxAssessment
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Preferences")
                .font(DesignSystem.Typography.displaySmall())
            Text("What are you comfortable with?")
                .font(DesignSystem.Typography.bodyMedium())
                .foregroundStyle(DesignSystem.Colors.textSecondary)
            
            VStack(alignment: .leading, spacing: 16) {
                Toggle("Avoid Surgery / Invasive", isOn: $assessment.avoidsSurgery)
                Toggle("Avoid Injections (Fillers/Botox)", isOn: $assessment.avoidsInjections)
                Toggle("Avoid Prescriptions", isOn: $assessment.avoidsPrescriptionMeds)
            }
            .padding(16)
            .background(DesignSystem.Colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Time per Day (Minutes)")
                    .font(DesignSystem.Typography.headline())
                Picker("Minutes", selection: $assessment.timePerDayMinutes) {
                    ForEach([5, 10, 20, 30], id: \.self) { min in Text("\(min) min").tag(min) }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(.horizontal, 20)
    }
}

struct ReviewStep: View {
    @Binding var assessment: LookMaxAssessment
    let onGenerate: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Ready?")
                .font(DesignSystem.Typography.displaySmall())
            
            EFCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        if let data = assessment.frontPhotoData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage).resizable().scaledToFill().frame(width: 40, height: 40).clipShape(Circle())
                        }
                        if let data = assessment.sidePhotoData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage).resizable().scaledToFill().frame(width: 40, height: 40).clipShape(Circle())
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Photos Ready")
                                .font(DesignSystem.Typography.headline())
                            Text(assessment.primaryGoalArea?.rawValue ?? "General Glow")
                                .font(DesignSystem.Typography.caption())
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                        }
                    }
                    Divider()
                    Text("Focus: \(assessment.mainConcern.isEmpty ? "General" : assessment.mainConcern)")
                        .lineLimit(1)
                        .font(DesignSystem.Typography.bodyMedium())
                    Text("Budget: \(assessment.budgetLevel?.rawValue ?? "-")")
                        .font(DesignSystem.Typography.bodyMedium())
                    Text("Time: \(assessment.timePerDayMinutes) min/day")
                        .font(DesignSystem.Typography.bodyMedium())
                }
                .padding(12)
            }
            
            Button(action: onGenerate) {
                Text("Generate Look Max Plan")
                    .font(DesignSystem.Typography.buttonLarge())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(DesignSystem.Colors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Home View

struct LookMaxHomeView: View {
    @State private var viewModel = LookMaxViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isPresentingWizard = false
    
    var body: some View {
        NavigationStack {
            EFScreenContainer {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            EFHeader(title: "Look Max")
                            Text("Upgrade your looks, naturally.")
                                .font(DesignSystem.Typography.subheadline())
                                .foregroundStyle(DesignSystem.Colors.textSecondary)
                        }
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(DesignSystem.Colors.neutral400)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    EFCard(style: .gradient(LinearGradient(colors: [Color.black, Color(hex: "1C1C1E")], startPoint: .top, endPoint: .bottom))) {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Ready for your glow up?")
                                .font(DesignSystem.Typography.displaySmall())
                                .foregroundStyle(.white)
                            Text("Upload photos, tell us what you want to improve, and we’ll build a personalized, healthy plan.")
                                .font(DesignSystem.Typography.bodyMedium())
                                .foregroundStyle(.white.opacity(0.8))
                                .lineLimit(3)
                            Button {
                                viewModel.startNewAssessment()
                                isPresentingWizard = true
                            } label: {
                                Text("Start Session")
                                    .font(DesignSystem.Typography.buttonLarge())
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(8)
                    }
                    .padding(.horizontal, 20)
                    
                    if let lastPlan = viewModel.history.first {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Current Plan")
                                .font(DesignSystem.Typography.sectionHeader())
                                .padding(.horizontal, 20)
                            EFCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(lastPlan.summaryTitle)
                                        .font(DesignSystem.Typography.headline())
                                    Text("\(lastPlan.dailyHabits.count) Daily Habits • \(lastPlan.weeklyActions.count) Weekly")
                                        .font(DesignSystem.Typography.caption())
                                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ideas")
                            .font(DesignSystem.Typography.sectionHeader())
                            .padding(.horizontal, 20)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(["Jawline", "Hair", "Skin", "Posture", "Style"], id: \.self) { tag in
                                    Text(tag)
                                        .font(DesignSystem.Typography.labelMedium())
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(DesignSystem.Colors.backgroundSecondary)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 20)
            }
            .fullScreenCover(isPresented: $isPresentingWizard) {
                LookMaxWizardView(viewModel: viewModel, isPresented: $isPresentingWizard)
            }
        }
    }
}

// MARK: - Start View

struct LookMaxingStartView: View {
    var body: some View {
        LookMaxHomeView()
    }
}
