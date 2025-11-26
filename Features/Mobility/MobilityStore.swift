//
//  MobilityStore.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

import Foundation
import SwiftUI

@MainActor
class MobilityStore: ObservableObject {
    static let shared = MobilityStore()
    
    // MARK: - User Data
    @Published var userName: String = "Anthony"
    @Published var primaryGoal: MobilityGoal = .injuryRisk
    @Published var primarySport: MobilitySport = .functional
    @Published var equipment: Set<MobilityEquipment> = [.foamRoller, .band]
    
    // MARK: - Domain Data
    @Published var tests: [MobilityTest] = []
    @Published var results: [MobilityTestResult] = []
    @Published var routines: [MobilityRoutine] = []
    
    // MARK: - Computed State
    @Published var scoreSummary: MobilityScoreSummary = MobilityScoreSummary(
        overallScore: 0,
        level: .low,
        areaScores: [:]
    )
    
    @Published var weeklyMinutes: Int = 45
    @Published var weeklyGoalMinutes: Int = 60
    
    init() {
        seedData()
        recomputeScores()
    }
    
    func saveResult(_ result: MobilityTestResult) {
        // Remove existing result for this test if any (simple latest-wins logic)
        results.removeAll { $0.testId == result.testId }
        results.append(result)
        recomputeScores()
    }
    
    private func seedData() {
        // Seed Tests
        tests = [
            MobilityTest(
                id: UUID(),
                name: "Freeze Test",
                bodyArea: .shoulders,
                shortDescription: "Shoulder external rotation assessment",
                instructions: [
                    "Sit against a wall with your back flat.",
                    "Raise your arms to 90 degrees, elbows touching the wall.",
                    "Try to rotate your hands back to touch the wall without arching your back.",
                    "Hold the position for 5 seconds."
                ],
                difficulty: .medium,
                estimatedDurationMinutes: 2,
                resultScaleDescription: "Rate 1-5: 1 = Hands far from wall, 5 = Hands touch easily"
            ),
            MobilityTest(
                id: UUID(),
                name: "Overhead Squat",
                bodyArea: .fullBody,
                shortDescription: "Global mobility assessment",
                instructions: [
                    "Stand with feet shoulder-width apart.",
                    "Hold a PVC pipe or towel overhead with arms locked.",
                    "Squat down as deep as possible while keeping heels down.",
                    "Keep the bar over your mid-foot."
                ],
                difficulty: .hard,
                estimatedDurationMinutes: 3,
                resultScaleDescription: "Rate 1-5: 1 = Can't squat below parallel, 5 = Full depth, upright torso"
            ),
            MobilityTest(
                id: UUID(),
                name: "Ankle Dorsiflexion",
                bodyArea: .ankles,
                shortDescription: "Calf and ankle range of motion",
                instructions: [
                    "Place toes 5 inches from a wall.",
                    "Try to touch your knee to the wall without lifting your heel.",
                    "Repeat on both sides."
                ],
                difficulty: .easy,
                estimatedDurationMinutes: 2,
                resultScaleDescription: "Rate 1-5: 1 = Knee >2 inches from wall, 5 = Knee touches wall easily"
            ),
            MobilityTest(
            id: UUID(),
                name: "Hip Flexor Lunge",
                bodyArea: .hips,
                shortDescription: "Hip extension capacity",
                instructions: [
                    "Kneel on one knee (lunge position).",
                    "Push hips forward while keeping torso upright.",
                    "Check for tightness in the front of the hip."
                ],
                difficulty: .medium,
                estimatedDurationMinutes: 2,
                resultScaleDescription: "Rate 1-5: 1 = Very tight/painful, 5 = Full range, no restriction"
            )
        ]
        
        // Seed Routines
        routines = [
            MobilityRoutine(
                id: UUID(),
                title: "Daily Flow",
                subtitle: "At home • Maintenance",
                type: .daily,
                durationMinutes: 12,
                focusAreas: [.hips, .spine],
                steps: [
                    MobilityRoutineStep(id: UUID(), name: "Cat-Cow", durationSeconds: 120, description: "Move with your breath"),
                    MobilityRoutineStep(id: UUID(), name: "90/90 Hip Switch", durationSeconds: 180, description: "Keep torso upright"),
                    MobilityRoutineStep(id: UUID(), name: "World's Greatest Stretch", durationSeconds: 180, description: "Alternating sides")
                ]
            ),
            MobilityRoutine(
                id: UUID(),
                title: "Pre-Workout Activate",
                subtitle: "Before training • Dynamic",
                type: .activate,
                durationMinutes: 8,
                focusAreas: [.fullBody],
                steps: [
                    MobilityRoutineStep(id: UUID(), name: "Arm Circles", durationSeconds: 60, description: nil),
                    MobilityRoutineStep(id: UUID(), name: "Leg Swings", durationSeconds: 60, description: "Front/back and side/side"),
                    MobilityRoutineStep(id: UUID(), name: "Inchworms", durationSeconds: 120, description: "Walk out to plank and back")
                ]
            ),
            MobilityRoutine(
                id: UUID(),
                title: "Post-WOD Recover",
                subtitle: "After training • Static",
                type: .recover,
                durationMinutes: 15,
                focusAreas: [.shoulders, .hips],
                steps: [
                    MobilityRoutineStep(id: UUID(), name: "Couch Stretch", durationSeconds: 240, description: "2 min per side"),
                    MobilityRoutineStep(id: UUID(), name: "Pigeon Pose", durationSeconds: 240, description: "2 min per side"),
                    MobilityRoutineStep(id: UUID(), name: "Puppy Dog Pose", durationSeconds: 120, description: "Open up shoulders")
                ]
            ),
            MobilityRoutine(
                id: UUID(),
                title: "Deep Reset",
                subtitle: "Weekend • Intense",
                type: .deepReset,
                durationMinutes: 25,
                focusAreas: [.fullBody, .spine],
                steps: [
                    MobilityRoutineStep(id: UUID(), name: "Foam Roll Quads", durationSeconds: 300, description: "Find tender spots"),
                    MobilityRoutineStep(id: UUID(), name: "Thoracic Extension", durationSeconds: 180, description: "Use foam roller or ball"),
                    MobilityRoutineStep(id: UUID(), name: "Frog Stretch", durationSeconds: 180, description: "Open hips wide")
                ]
            )
        ]
        
        // Seed some initial results to show partial completion
        saveResult(MobilityTestResult(id: UUID(), testId: tests[0].id, score: 3, date: Date().addingTimeInterval(-86400 * 2)))
    }
    
    private func recomputeScores() {
        if results.isEmpty {
            scoreSummary = MobilityScoreSummary(overallScore: 0, level: .veryLow, areaScores: [:])
            return
        }
        
        let totalScore = results.reduce(0) { $0 + $1.score }
        let avg = Double(totalScore) / Double(results.count)
        
        // Normalize 1-5 to 0-100 roughly
        let normalized = Int((avg / 5.0) * 100)
        
        let level: MobilityLevel
        switch normalized {
        case 0..<40: level = .veryLow
        case 40..<55: level = .low
        case 55..<70: level = .average
        case 70..<85: level = .good
        default: level = .excellent
        }
        
        // Mock area scores
        let areas: [MobilityBodyArea: Int] = [
            .shoulders: normalized + Int.random(in: -5...5),
            .hips: normalized + Int.random(in: -5...5),
            .ankles: normalized + Int.random(in: -5...5),
            .spine: normalized + Int.random(in: -5...5)
        ]
        
        scoreSummary = MobilityScoreSummary(overallScore: normalized, level: level, areaScores: areas)
    }
}
