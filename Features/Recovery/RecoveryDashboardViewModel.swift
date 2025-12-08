//
//  RecoveryDashboardViewModel.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

import Foundation
import SwiftUI

struct RecoveryPlanStepUI: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let relativeMinutes: Int?
    var isCompleted: Bool = false
}

struct WeeklyRecoveryFocusArea: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let actions: [String]
}

@MainActor
class RecoveryDashboardViewModel: ObservableObject {

  // MARK: - State
  @Published var selectedRange: RecoveryTimeRange = .today
  @Published var logs: [DailyRecoveryLog] = []
    
    // MARK: - AI State
    enum LoadState<Value> {
        case idle
        case loading
        case loaded(Value)
        case failed(Error)
    }
    
    enum RecoveryPlanState {
        case idle
        case loading
        case loaded(RecoveryDayPlan)
        case error(String)
    }
    
    @Published var todayInsightsState: LoadState<RecoveryDailyInsights> = .idle
    @Published var weeklyInsightsState: LoadState<RecoveryDailyInsights> = .idle
    @Published var planState: RecoveryPlanState = .idle
    
    // UI State for Sheets
    @Published var isShowingPlanSheet: Bool = false
    @Published var isShowingWeeklyPlanSheet: Bool = false
    @Published var isShowingInsightDetail: Bool = false
    
    // Local View Models
    @Published var smartPlanSteps: [RecoveryPlanStepUI] = []
    @Published var weeklyFocusAreas: [WeeklyRecoveryFocusArea] = []
    
    private let service: RecoveryServiceProtocol
    
    // MARK: - Computed
    
    var todayLog: DailyRecoveryLog {
        // Return today's log or a default empty one if missing
        let today = Calendar.current.startOfDay(for: Date())
        return logs.first { Calendar.current.isDate($0.date, inSameDayAs: today) } 
            ?? DailyRecoveryLog(
                date: Date(),
                totalSleepMinutes: 0,
                sleepScore: 0,
                efficiencyPercent: 0,
                sleepStages: SleepStageBreakdown(deepMinutes: 0, remMinutes: 0, lightMinutes: 0, awakeMinutes: 0),
                completedActions: [],
                coachInsight: "No data for today."
            )
    }
    
    var weekLogs: [DailyRecoveryLog] {
        // Return last 7 days
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekAgo = calendar.date(byAdding: .day, value: -6, to: today)!
        
        return logs.filter { $0.date >= weekAgo && $0.date <= Date() }
            .sorted { $0.date < $1.date }
    }
    
    var weeklyInsight: String {
        let avgScore = weekLogs.reduce(0) { $0 + $1.sleepScore } / max(weekLogs.count, 1)
        if avgScore >= 80 {
            return "Excellent week! Your consistency is paying off. You're primed for higher volume next week."
        } else if avgScore >= 60 {
            return "Solid week. A few nights were lower, but overall your trend is stable. Focus on consistency."
    } else {
            return "Tough week for recovery. Try to prioritize sleep hygiene and reduce late-night stress."
    }
  }

  // MARK: - Init
  init(service: RecoveryServiceProtocol = RecoveryService.shared) {
    self.service = service
    generateMockData()
  }

  // MARK: - Methods

    @MainActor
    func loadTodayInsights() async {
        // Always reload if idle or failed, but prevent duplicate loading if already loading
        if case .loading = todayInsightsState { return }
        
        todayInsightsState = .loading
        do {
            let insights = try await service.fetchTodayInsights()
            todayInsightsState = .loaded(insights)
            
            // Also generate weekly insights when today's data is fetched (simulated for now)
            generateWeeklyInsights()
        } catch {
            print("Failed to load recovery insights: \(error)")
            todayInsightsState = .failed(error)
        }
    }
    
    @MainActor
    func reloadTodayInsights() async {
        if case .loading = todayInsightsState { return }
        todayInsightsState = .loading
        do {
            let insights = try await service.fetchTodayInsights()
            todayInsightsState = .loaded(insights)
            generateWeeklyInsights()
        } catch {
            todayInsightsState = .failed(error)
        }
    }
    
    /// Loads the nightly smart plan once per presentation, unless forced.
    func loadDayPlan(for date: Date? = Date(), force: Bool = false) {
        if !force {
            if case .loading = planState { return }
            if case .loaded = planState { return }
        }
        
        let targetDate = date ?? Date()
        print("📄 [RecoveryPlan] requesting plan for \(targetDate)")
        planState = .loading
        
        let service = service
        Task.detached(priority: .userInitiated) { [weak self] in
            do {
                let plan = try await service.fetchDayPlan(for: targetDate)
                let steps = plan.steps.map { step in
                    RecoveryPlanStepUI(
                        title: step.title,
                        description: step.description,
                        relativeMinutes: step.relativeMinutes,
                        isCompleted: false
                    )
                }
                
                await MainActor.run {
                    guard let self else { return }
                    self.planState = .loaded(plan)
                    self.smartPlanSteps = steps
                    print("✅ [RecoveryPlan] loaded \(steps.count) steps")
                }
            } catch {
                await MainActor.run {
                    guard let self else { return }
                    self.planState = .error("We couldn't generate a plan right now. Please try again.")
                    print("❌ [RecoveryPlan] failed: \(error)")
                }
            }
        }
    }
    
    func togglePlanStep(id: UUID) {
        if let index = smartPlanSteps.firstIndex(where: { $0.id == id }) {
            smartPlanSteps[index].isCompleted.toggle()
        }
    }
    
    @MainActor
    private func generateWeeklyInsights() {
        // Simulate weekly AI analysis from local logs
        weeklyInsightsState = .loading
        
        // Add a small delay to simulate "thinking" if needed, or just process immediately
        // For UX "thinking" feel, we can dispatch async after a second, but for now direct is fine.
        
        let avgScore = weekLogs.reduce(0) { $0 + $1.sleepScore } / max(weekLogs.count, 1)
        let avgSleep = weekLogs.reduce(0) { $0 + $1.totalSleepMinutes } / max(weekLogs.count, 1)
        let avgSleepHours = avgSleep / 60
        
        let headline = avgScore >= 80 ? "Excellent consistency this week" : 
                       avgScore >= 60 ? "Stable recovery baseline" : "Irregular sleep pattern detected"
        
        let summary = "Your average sleep time is \(avgSleepHours)h \(avgSleep % 60)m with a recovery score of \(avgScore). " +
                      (avgScore >= 80 ? "You are primed for higher training volume." : "Focus on consistent bedtimes to improve.")
        
        let insights = RecoveryDailyInsights(
            headline: headline,
            summary: summary,
            recoveryScore: avgScore,
            sleepConsistency: Int.random(in: 70...95), // Mock consistency
            nervousSystemLoad: avgScore > 70 ? "low" : "medium",
            keyIssues: avgScore < 70 ? ["Inconsistent bedtimes", "Late caffeine"] : ["None"],
            todayFocusTags: ["Consistency", "Sleep Duration"]
        )
        
        // Populate weekly focus areas based on insights
        self.weeklyFocusAreas = [
            WeeklyRecoveryFocusArea(
                title: "Sleep Consistency",
                description: "Your bedtime variability is higher than optimal.",
                actions: ["Set a wind-down alarm for 22:00", "Aim for bed between 22:30–23:00"]
            ),
            WeeklyRecoveryFocusArea(
                title: "Sleep Duration",
                description: "You are averaging \(avgSleepHours)h, slightly below the 8h target.",
                actions: ["Extend sleep opportunity by 30 mins", "Limit caffeine after 14:00"]
            )
        ]
        
        // Small delay to show loading state if user switches tabs quickly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.weeklyInsightsState = .loaded(insights)
        }
    }

  func generateMockData() {
    let calendar = Calendar.current
    let today = Date()

        var newLogs: [DailyRecoveryLog] = []
        
        // Generate 14 days of history
        for i in 0..<14 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            
            let totalMinutes = Int.random(in: 360...540) // 6h to 9h
            let score = Int.random(in: 50...98)
            let efficiency = Int.random(in: 80...98)
            
            // Distribute stages roughly
            let deep = Int(Double(totalMinutes) * Double.random(in: 0.15...0.25))
            let rem = Int(Double(totalMinutes) * Double.random(in: 0.20...0.30))
            let awake = Int(Double(totalMinutes) * Double.random(in: 0.05...0.15))
            let light = totalMinutes - deep - rem - awake
            
            // Random actions
            var actions: Set<RecoveryAction> = []
            if Bool.random() { actions.insert(.mobility) }
            if Bool.random() && i % 3 == 0 { actions.insert(.sauna) }
            if i % 7 == 0 { actions.insert(.restDay) }
            
            // Insight
            let insight = generateInsight(score: score, actions: actions)
            
            let log = DailyRecoveryLog(
        date: date,
                totalSleepMinutes: totalMinutes,
                sleepScore: score,
                efficiencyPercent: efficiency,
                sleepStages: SleepStageBreakdown(
                    deepMinutes: deep,
                    remMinutes: rem,
                    lightMinutes: light,
                    awakeMinutes: awake
                ),
                completedActions: actions,
                coachInsight: insight
            )
            
            newLogs.append(log)
        }
        
        self.logs = newLogs.sorted { $0.date < $1.date }
    }
    
    private func generateInsight(score: Int, actions: Set<RecoveryAction>) -> String {
        if score >= 85 {
            return "You're well recovered and ready to train hard. Keep up your routine!"
        } else if score >= 70 {
            if !actions.isEmpty {
                return "Good recovery. Your active recovery efforts are helping. Maintain a steady load."
            } else {
                return "Moderate recovery. Consider adding some mobility or breathwork to boost your readiness."
            }
        } else {
            return "Recovery is low. Prioritize rest, sleep, and gentle activities today. Avoid high intensity."
    }
  }

  func toggleAction(_ action: RecoveryAction) {
        // Toggle for TODAY only
        guard let index = logs.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: Date()) }) else {
            return
        }
        
        var log = logs[index]
        if log.completedActions.contains(action) {
            log.completedActions.remove(action)
        } else {
            log.completedActions.insert(action)
    }
        
        // Update insight based on new state
        log.coachInsight = generateInsight(score: log.sleepScore, actions: log.completedActions)
        
        logs[index] = log
  }
}
