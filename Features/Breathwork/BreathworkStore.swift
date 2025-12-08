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
    var selectedPatternType: BreathworkPatternType = .box // Default to Box for safety
    
    /// Tracks whether we've loaded patterns from the backend
    private(set) var patternsLoaded = false
    
    /// Tracks whether we've loaded recent sessions from the backend
    private(set) var sessionsLoaded = false
    
    /// Tracks sessions that failed to sync and need retry
    var pendingSyncSessions: [BreathworkSessionLog] = []
    
    /// Loading states
    var isLoadingPatterns = false
    var isLoadingSessions = false
    var isSyncing = false
    
    /// Error state for UI feedback
    var lastError: String?
    
    // MARK: - AI State
    
    enum BreathworkAiLoadState: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }
    
    var todaySuggestionState: BreathworkAiLoadState = .idle
    var todaySuggestion: BreathworkAiTodaySuggestionViewData?
    
    // UI Signal for applying suggestion
    var suggestedRoundsOverride: Int?
    
    var weeklyInsightState: BreathworkAiLoadState = .idle
    var weeklyInsight: BreathworkAiWeeklyInsightViewData?
    
    private let aiService = BreathworkService.shared
    
    init() {}
    
    // MARK: - AI Actions
    
    @MainActor
    func loadAiTodaySuggestionIfNeeded() {
        guard todaySuggestionState == .idle else { return }
        Task { await loadAiTodaySuggestion() }
    }

    @MainActor
    func loadAiTodaySuggestion() async {
        todaySuggestionState = .loading
        do {
            let dto = try await aiService.fetchAiTodaySuggestion()
            todaySuggestion = dto.toViewData()
            todaySuggestionState = .loaded
        } catch {
            todaySuggestionState = .error("We couldn’t generate a suggestion right now.")
        }
    }

    @MainActor
    func loadWeeklyInsightIfNeeded() {
        guard weeklyInsightState == .idle else { return }
        Task { await loadWeeklyInsight() }
    }

    @MainActor
    func loadWeeklyInsight() async {
        weeklyInsightState = .loading
        do {
            let dto = try await aiService.fetchAiWeeklyInsight(from: nil, to: nil)
            weeklyInsight = dto.toViewData()
            weeklyInsightState = .loaded
        } catch {
            weeklyInsightState = .error("We couldn’t load this week’s insight.")
        }
    }
    
    @MainActor
    func applyTodaySuggestionToSession() {
        guard let suggestion = todaySuggestion else { return }
        
        // 1. Select pattern
        if let patternId = suggestion.suggestedPatternId,
           let patternType = BreathworkPatternType(rawValue: patternId) {
            selectedPatternType = patternType
        }
        
        // 2. Signal rounds override
        suggestedRoundsOverride = suggestion.suggestedRounds
    }
    
    // MARK: - Computed Props
    
    /// The currently selected pattern for a quick session.
    /// Matches Requirement: "activeSessionPattern always refers to one of the defined programs"
    var activeSessionPattern: BreathworkPattern? {
        patterns.first { $0.type == selectedPatternType } ?? patterns.first
    }
    
    var availablePrograms: [BreathworkPattern] {
        patterns
    }
    
    /// Returns the 5 most recent sessions, sorted by date descending.
    var recentSessions: [BreathworkSessionLog] {
        sessionLogs.sorted(by: { $0.date > $1.date }).prefix(5).map { $0 }
    }
    
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
    
    // MARK: - Backend Integration
    
    /// Loads breathing patterns from the backend.
    /// Falls back to local defaults if backend is unavailable.
    @MainActor
    func loadPatternsFromBackend() async {
        guard !isLoadingPatterns else { return }
        isLoadingPatterns = true
        lastError = nil
        
        do {
            let backendPatterns = try await BackendClient.shared.fetchBreathworkPatterns()
            
            // Convert DTOs to local models
            patterns = backendPatterns.map { dto in
                BreathworkPattern(
                    id: UUID(),
                    type: BreathworkPatternType(rawValue: dto.type) ?? .box,
                    displayName: dto.displayName,
                    description: dto.description,
                    targetEffect: dto.targetEffect,
                    defaultRounds: dto.defaultRounds,
                    phases: dto.phases.map { phaseDTO in
                        BreathPhase(
                            type: BreathPhaseType(rawValue: phaseDTO.type) ?? .inhale,
                            durationSeconds: phaseDTO.durationSeconds,
                            instruction: phaseDTO.instruction
                        )
                    }
                )
            }
            patternsLoaded = true
            #if DEBUG
            print("✅ Loaded \(patterns.count) breathwork patterns from backend")
            #endif
        } catch {
            #if DEBUG
            print("⚠️ Failed to load patterns from backend: \(error.localizedDescription)")
            print("   Falling back to local defaults")
            #endif
            // Fall back to local defaults
            if patterns.isEmpty {
                loadLocalDefaults()
            }
            lastError = "Using offline patterns"
        }
        
        isLoadingPatterns = false
    }
    
    /// Loads recent sessions from the backend.
    @MainActor
    func loadRecentSessionsFromBackend() async {
        guard !isLoadingSessions else { return }
        isLoadingSessions = true
        
        do {
            let backendSessions = try await BackendClient.shared.fetchRecentBreathworkSessions(limit: 10)
            
            // Convert DTOs to local models
            let newSessions = backendSessions.compactMap { dto -> BreathworkSessionLog? in
                guard let date = ISO8601DateFormatter().date(from: dto.createdAt) else {
                    return nil
                }
                return BreathworkSessionLog(
                    id: UUID(uuidString: dto.id) ?? UUID(),
                    date: date,
                    templateId: nil,
                    patternName: dto.patternName,
                    durationMinutes: dto.durationSeconds / 60,
                    roundsCompleted: dto.roundsCompleted,
                    longestHoldSeconds: dto.longestHoldSeconds,
                    notes: dto.notes
                )
            }
            
            // Merge with local sessions (avoid duplicates)
            let existingIds = Set(sessionLogs.map { $0.id })
            for session in newSessions where !existingIds.contains(session.id) {
                sessionLogs.append(session)
            }
            
            sessionsLoaded = true
            #if DEBUG
            print("✅ Loaded \(newSessions.count) breathwork sessions from backend")
            #endif
        } catch {
            #if DEBUG
            print("⚠️ Failed to load sessions from backend: \(error.localizedDescription)")
            #endif
            // Keep existing local sessions - don't clear them
        }
        
        isLoadingSessions = false
    }
    
    /// Logs a completed session locally and syncs to backend.
    @MainActor
    func logCompletedSession(
        pattern: BreathworkPattern,
        roundsCompleted: Int,
        durationSeconds: Int,
        longestHoldSeconds: Int = 0,
        notes: String? = nil
    ) async {
        // 1. Create local log immediately
        let log = BreathworkSessionLog(
            id: UUID(),
            date: Date(),
            templateId: nil,
            patternName: pattern.displayName,
            durationMinutes: durationSeconds / 60,
            roundsCompleted: roundsCompleted,
            longestHoldSeconds: longestHoldSeconds,
            notes: notes
        )
        sessionLogs.append(log)
        
        // 2. Try to sync to backend
        isSyncing = true
        do {
            let _ = try await BackendClient.shared.logBreathworkSession(
                patternId: pattern.type.rawValue,
                patternName: pattern.displayName,
                roundsCompleted: roundsCompleted,
                durationSeconds: durationSeconds,
                longestHoldSeconds: longestHoldSeconds,
                notes: notes
            )
            #if DEBUG
            print("✅ Synced breathwork session to backend")
            #endif
        } catch {
            #if DEBUG
            print("⚠️ Failed to sync session to backend: \(error.localizedDescription)")
            #endif
            // Mark as pending sync for retry later
            pendingSyncSessions.append(log)
        }
        isSyncing = false
    }
    
    /// Retries syncing any pending sessions.
    @MainActor
    func retryPendingSyncs() async {
        guard !pendingSyncSessions.isEmpty, !isSyncing else { return }
        isSyncing = true
        
        var stillPending: [BreathworkSessionLog] = []
        
        for session in pendingSyncSessions {
            do {
                let _ = try await BackendClient.shared.logBreathworkSession(
                    patternId: session.patternName.lowercased().replacingOccurrences(of: " ", with: "-"),
                    patternName: session.patternName,
                    roundsCompleted: session.roundsCompleted,
                    durationSeconds: session.durationMinutes * 60,
                    longestHoldSeconds: session.longestHoldSeconds,
                    notes: session.notes
                )
                #if DEBUG
                print("✅ Synced pending session: \(session.patternName)")
                #endif
            } catch {
                stillPending.append(session)
            }
        }
        
        pendingSyncSessions = stillPending
        isSyncing = false
    }
    
    // MARK: - Local Actions
    
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
    
    // MARK: - Local Defaults
    
    private func loadLocalDefaults() {
        let boxPattern = BreathworkPattern(
            id: UUID(),
            type: .box,
            displayName: "Box Breathing",
            description: "Equal duration for inhale, hold, exhale, and hold. Great for focus and stress relief.",
            targetEffect: "Focus & Calm",
            defaultRounds: 4,
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
            description: "5.5-second inhale, 5.5-second exhale. Balances the nervous system.",
            targetEffect: "Balance",
            defaultRounds: 5,
            phases: [
                BreathPhase(type: .inhale, durationSeconds: 5.5, instruction: "Inhale 5.5s"),
                BreathPhase(type: .exhale, durationSeconds: 5.5, instruction: "Exhale 5.5s")
            ]
        )
        
        patterns = [wimHofPattern, boxPattern, sleep478, coherent]
        patternsLoaded = true
    }
    
    // MARK: - Mock Data
    
    static func mock() -> BreathworkStore {
        let store = BreathworkStore()
        store.loadLocalDefaults()
        
        // Programs
        let boxPattern = store.patterns.first { $0.type == .box }!
        let coherent = store.patterns.first { $0.type == .coherent }!
        
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
