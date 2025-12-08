//
//  FixPainViewModel.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import Foundation
import SwiftUI
@MainActor
final class FixPainViewModel: ObservableObject {
    @Published var currentAssessment: FixPainAssessment?
    @Published var recentAssessments: [FixPainAssessment] = []
    @Published var generatedPlan: FixPainPlan?
    
    // AI-backed plan
    @Published var plan: PainAiPlanDTO?
    @Published var isLoadingPlan: Bool = false
    @Published var submitErrorMessage: String?
    
    private let service = FixPainService()
    
    init() {
        // Mock recent assessments for demo
        recentAssessments = [
            FixPainAssessment(
                region: .lowerBack,
                side: .central,
                intensity: 4.0,
                quality: .stiff,
                onset: .gradual,
                durationInDays: 3,
                notes: "After long drive"
            )
        ]
    }
    
    func startNewAssessment() {
        currentAssessment = FixPainAssessment()
        generatedPlan = nil
        plan = nil
        submitErrorMessage = nil
    }
    
    // MARK: - API
    @MainActor
    func submitAssessmentAndLoadPlan() async {
        guard let input = makeAssessmentInput() else {
            submitErrorMessage = "Please complete all required fields."
            return
        }
        
        isLoadingPlan = true
        submitErrorMessage = nil
        
        do {
            let newPlan = try await service.submitAssessment(input)
            self.plan = newPlan
            print("[FixPain] Loaded plan from backend with triageLevel: \(newPlan.triageLevel.rawValue)")
            self.isLoadingPlan = false
        } catch {
            self.isLoadingPlan = false
            self.submitErrorMessage = "We couldn’t generate a plan right now. Please try again."
            if let backendError = error as? BackendError {
                print("[FixPain] Backend error: \(backendError)")
            } else {
                print("[FixPain] Submit error:", error)
            }
        }
    }
    
    // MARK: - Mapping to backend DTO
    private func makeAssessmentInput() -> PainAssessmentInputDTO? {
        guard let assessment = currentAssessment,
              let region = assessment.region,
              let side = assessment.side else {
            return nil
        }
        
        let regionKey = mapRegion(region)
        let sideKey = mapSide(side)
        
        // Backend enum: acute (<14d), subacute (<42d), chronic (>=42d), sudden, unknown
        let durationKey: String = {
            if assessment.onset == .sudden { return "sudden" }
            if assessment.durationInDays < 14 { return "acute" }
            if assessment.durationInDays < 42 { return "subacute" }
            return "chronic"
        }()
        
        var characters: [String] = []
        if let q = assessment.quality { characters.append(q.rawValue.lowercased()) }
        
        var aggravating: [String] = []
        if assessment.movementWorse { aggravating.append("movement") }
        if assessment.restWorse { aggravating.append("rest") }
        if assessment.postureStrain { aggravating.append("posture/desk") }
        
        var redFlags: [String] = []
        if assessment.recentTrauma { redFlags.append("recent trauma") }
        if assessment.numbnessOrTingling { redFlags.append("numbness/tingling") }
        if assessment.nightPain { redFlags.append("night pain") }
        if assessment.feverOrIllness { redFlags.append("fever/illness") }
        
        var context: [String] = []
        if let activity = assessment.activityLevel { context.append("activity: \(activity.rawValue)") }
        if let training = assessment.recentTrainingChange { context.append("training: \(training.rawValue)") }
        if let stress = assessment.stressLevel { context.append("stress: \(stress.rawValue)") }
        
        return PainAssessmentInputDTO(
            bodyRegion: regionKey,
            side: sideKey,
            painDuration: durationKey,
            painIntensity: Int(assessment.intensity),
            painCharacter: characters,
            aggravatingFactors: aggravating,
            relievingFactors: [],
            activityContext: context,
            redFlags: redFlags,
            functionalLimitations: [],
            notes: assessment.notes.isEmpty ? nil : assessment.notes,
            photoUrl: nil // photo upload not wired yet
        )
    }
    
    private func mapRegion(_ region: PainRegion) -> String {
        switch region {
        case .neck: return "neck"
        case .upperBack: return "upper_back"
        case .lowerBack: return "lower_back"
        case .shoulder: return "shoulder"
        case .hip: return "hip"
        case .knee: return "knee"
        case .ankle: return "ankle"
        case .foot: return "foot"
        case .elbow: return "elbow"
        case .wrist: return "wrist"
        case .hand: return "hand"
        }
    }
    
    private func mapSide(_ side: PainSide) -> String {
        switch side {
        case .left: return "left"
        case .right: return "right"
        case .both: return "both"
        case .central: return "center"
        }
    }
    
    func generatePlan(for assessment: FixPainAssessment) {
        // Mock Logic Rule Engine
        
        var risk: RiskLevel = .selfCareOk
        var explanation = "Based on your inputs, this seems manageable with conservative care."
        
        let redFlags = [
            assessment.recentTrauma,
            assessment.feverOrIllness,
            assessment.numbnessOrTingling,
            assessment.nightPain
        ]
        
        if redFlags.contains(true) && assessment.intensity >= 7 {
            risk = .seeDoctorASAP
            explanation = "Your symptoms (high intensity + red flags) suggest you should seek professional evaluation soon."
        } else if assessment.intensity >= 7 || assessment.durationInDays > 10 {
            risk = .caution
            explanation = "Persistent or high-intensity pain warrants caution. Go slow and stop if pain increases."
        }
        
        // Exercises based on region
        let exercises = exercisesFor(region: assessment.region ?? .lowerBack)
        
        let plan = FixPainPlan(
            riskLevel: risk,
            explanation: explanation,
            warmupAndMobility: exercises.warmup,
            strengthAndActivation: exercises.strength,
            recoveryAdvice: [
                RecoveryAdvice(title: "Heat vs Ice", description: assessment.onset == .sudden ? "Use ice for the first 48h to reduce inflammation." : "Heat packs can help relax stiff muscles."),
                RecoveryAdvice(title: "Sleep Position", description: "Try placing a pillow between your knees (side sleeper) or under knees (back sleeper).")
            ],
            whenToStop: ["Sharp shooting pain", "Dizziness", "Numbness spreading"],
            whenToSeeDoctor: ["No improvement after 3 days", "Fever develops", "Loss of motor control"]
        )
        
        self.generatedPlan = plan
        
        // Save to history
        if !recentAssessments.contains(where: { $0.id == assessment.id }) {
            recentAssessments.insert(assessment, at: 0)
        }
    }
    
    private func exercisesFor(region: PainRegion) -> (warmup: [PainExercise], strength: [PainExercise]) {
        switch region {
        case .lowerBack:
            return (
                [
                    PainExercise(title: "Cat-Cow", description: "Gently arch and round your back.", sets: 2, reps: 10, sideSpecific: false),
                    PainExercise(title: "Child's Pose", description: "Sit back on heels, arms forward.", holdSeconds: 30, sideSpecific: false)
                ],
                [
                    PainExercise(title: "Bird-Dog", description: "Extend opposite arm and leg.", sets: 3, reps: 8, sideSpecific: true),
                    PainExercise(title: "Glute Bridges", description: "Lift hips while squeezing glutes.", sets: 3, reps: 12, sideSpecific: false)
                ]
            )
        case .neck, .shoulder:
            return (
                [
                    PainExercise(title: "Neck Retractions", description: "Gently pull head back (double chin).", sets: 2, reps: 10, sideSpecific: false),
                    PainExercise(title: "Doorway Stretch", description: "Open chest muscles in doorway.", holdSeconds: 30, sideSpecific: false)
                ],
                [
                    PainExercise(title: "Scapular Squeezes", description: "Squeeze shoulder blades together.", sets: 3, reps: 15, sideSpecific: false)
                ]
            )
        case .knee, .hip:
            return (
                [
                    PainExercise(title: "Knee Hugs", description: "Pull knee to chest while lying down.", holdSeconds: 20, sideSpecific: true)
                ],
                [
                    PainExercise(title: "Clamshells", description: "Side lying, open knees like a clam.", sets: 3, reps: 12, sideSpecific: true),
                    PainExercise(title: "Wall Sits", description: "Sit against wall.", holdSeconds: 30, sideSpecific: false)
                ]
            )
        default:
            // Generic
            return (
                [PainExercise(title: "Gentle Movement", description: "Move joint through pain-free range.", reps: 10, sideSpecific: true)],
                [PainExercise(title: "Isometrics", description: "Push against resistance without moving.", holdSeconds: 10, sideSpecific: true)]
            )
        }
    }
}

