//
//  BreathworkStore.swift
//  EverForm
//
//  Created by Gemini on 19/11/2025.
//

import Foundation
import SwiftUI

@Observable
final class BreathworkStore {
    var patterns: [BreathworkPattern] = []
    var templates: [BreathworkSessionTemplate] = []
    var sessionLogs: [BreathworkSessionLog] = []
    var programs: [BreathworkProgram] = []
    var activeProgramId: UUID?
    var selectedPatternType: BreathworkPatternType = .wimHof
    var activeSessionPattern: BreathworkPattern? // Tracks the currently running session
    
    // MARK: - Safe Defaults
    
    var defaultPattern: BreathworkPattern? {
        patterns.first { $0.type == .box } ?? patterns.first
    }
    
    func makeFallbackPattern() -> BreathworkPattern {
        BreathworkPattern(
            id: UUID(),
            type: .box,
            displayName: "Box Breathing (Fallback)",
            description: "Fallback pattern",
            targetEffect: "Calm",
            defaultRounds: 4,
            phases: [
                BreathPhase(type: .inhale, durationSeconds: 4, instruction: "Inhale"),
                BreathPhase(type: .hold, durationSeconds: 4, instruction: "Hold"),
                BreathPhase(type: .exhale, durationSeconds: 4, instruction: "Exhale"),
                BreathPhase(type: .hold, durationSeconds: 4, instruction: "Hold")
            ]
        )
    }
    
    init() {}
    
    // MARK: - Computed Stats
    
    var totalMinutes: Int {
        sessionLogs.reduce(0) { $0 + $1.durationMinutes }
    }
    
    var totalSessions: Int {
        sessionLogs.count
    }
    
    var longestStreak: Int {
        // Simplified streak calculation
        guard !sessionLogs.isEmpty else { return 0 }
        // In a real app, analyze dates
        return 3 // Mock
    }
    
    var longestRetentionSeconds: Int {
        sessionLogs.map { $0.longestHoldSeconds }.max() ?? 0
    }
    
    // MARK: - Actions
    
    func logSession(_ log: BreathworkSessionLog) {
        sessionLogs.append(log)
    }
    
    func activeProgram() -> BreathworkProgram? {
        guard let id = activeProgramId else { return nil }
        return programs.first { $0.id == id }
    }
    
    func toggleProgramDayCompletion(programId: UUID, dayId: UUID) {
        guard let pIndex = programs.firstIndex(where: { $0.id == programId }),
              let dIndex = programs[pIndex].sessions.firstIndex(where: { $0.id == dayId }) else {
            return
        }
        programs[pIndex].sessions[dIndex].completed.toggle()
    }
    
    // MARK: - Mock Data
    
    func makeFallbackPattern() -> BreathworkPattern? {
        BreathworkPattern(
            id: UUID(),
            type: .box,
            displayName: "Box Breathing (Fallback)",
            description: "Fallback pattern",
            targetEffect: "Calm",
            defaultRounds: 4,
            phases: [
                BreathPhase(type: .inhale, durationSeconds: 4, instruction: "Inhale"),
                BreathPhase(type: .hold, durationSeconds: 4, instruction: "Hold"),
                BreathPhase(type: .exhale, durationSeconds: 4, instruction: "Exhale"),
                BreathPhase(type: .hold, durationSeconds: 4, instruction: "Hold")
            ]
        )
    }
    
    static func mock() -> BreathworkStore {
        let store = BreathworkStore()
        
        // Patterns
        let boxPattern = BreathworkPattern(
            id: UUID(),
            type: .box,
            displayName: "Box Breathing",
            description: "Equal duration for inhale, hold, exhale, and hold. Great for focus and stress relief.",
            targetEffect: "Focus & Calm",
            defaultRounds: 4, // 4 minutes typically
            phases: [
                BreathPhase(type: .inhale, durationSeconds: 4, instruction: "Inhale through nose"),
                BreathPhase(type: .hold, durationSeconds: 4, instruction: "Hold breath"),
                BreathPhase(type: .exhale, durationSeconds: 4, instruction: "Exhale through mouth"),
                BreathPhase(type: .hold, durationSeconds: 4, instruction: "Hold empty")
            ]
        )
        
        let wimHofPattern = BreathworkPattern(
            id: UUID(),
            type: .wimHof,
            displayName: "Wim Hof Method",
            description: "Deep breathing rounds followed by breath retention. Boosts energy and immune system.",
            targetEffect: "Energy & Immunity",
            defaultRounds: 3,
            phases: [
                // This is simplified for the model; real WHM is ~30 reps then retention.
                // We will simulate "phases" as the big chunks of the cycle in the UI logic,
                // or use a special "Cyclic" phase type. For now, simple linear representation.
                BreathPhase(type: .inhale, durationSeconds: 2.0, instruction: "Fully in"),
                BreathPhase(type: .exhale, durationSeconds: 1.5, instruction: "Let go")
            ]
        )
        
        let sleep478 = BreathworkPattern(
            id: UUID(),
            type: .fourSevenEight,
            displayName: "4-7-8 Sleep",
            description: "Natural tranquilizer for the nervous system.",
            targetEffect: "Sleep",
            defaultRounds: 4,
            phases: [
                BreathPhase(type: .inhale, durationSeconds: 4, instruction: "Quiet inhale through nose"),
                BreathPhase(type: .hold, durationSeconds: 7, instruction: "Hold breath"),
                BreathPhase(type: .exhale, durationSeconds: 8, instruction: "Whoosh exhale through mouth")
            ]
        )
        
        let coherent = BreathworkPattern(
            id: UUID(),
            type: .coherent,
            displayName: "Coherent Breathing",
            description: "5-second inhale, 5-second exhale. Balances the nervous system.",
            targetEffect: "Balance",
            defaultRounds: 5,
            phases: [
                BreathPhase(type: .inhale, durationSeconds: 5.5, instruction: "Inhale 5.5s"),
                BreathPhase(type: .exhale, durationSeconds: 5.5, instruction: "Exhale 5.5s")
            ]
        )
        
        store.patterns = [wimHofPattern, boxPattern, sleep478, coherent]
        
        // Programs
        let resetProgram = BreathworkProgram(
            id: UUID(),
            name: "21-Day Nervous System Reset",
            description: "Rebuild your stress resilience from the ground up.",
            daysCount: 21,
            dailyMinutes: 10,
            level: .beginner,
            sessions: (1...21).map { i in
                ProgramDay(
                    id: UUID(),
                    dayIndex: i,
                    template: BreathworkSessionTemplate(
                        id: UUID(),
                        pattern: i % 2 == 0 ? boxPattern : coherent,
                        rounds: 3,
                        totalEstimatedMinutes: 10
                    ),
                    completed: i < 5,
                    locked: i > 5
                )
            }
        )
        
        store.programs = [resetProgram]
        store.activeProgramId = resetProgram.id
        
        // Logs
        store.sessionLogs = [
            BreathworkSessionLog(id: UUID(), date: Date().addingTimeInterval(-86400 * 2), templateId: nil, patternName: "Box Breathing", durationMinutes: 5, roundsCompleted: 1, longestHoldSeconds: 0, notes: nil),
            BreathworkSessionLog(id: UUID(), date: Date().addingTimeInterval(-86400), templateId: nil, patternName: "Wim Hof Method", durationMinutes: 12, roundsCompleted: 3, longestHoldSeconds: 90, notes: "Felt tingling in hands")
        ]
        
        return store
    }
}

