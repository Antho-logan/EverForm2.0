//
//  RecoveryDashboardViewModel.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

import Foundation
import SwiftUI

@MainActor
class RecoveryDashboardViewModel: ObservableObject {

  // MARK: - State
  @Published var selectedRange: RecoveryTimeRange = .today
    @Published var logs: [DailyRecoveryLog] = []

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
  init() {
    generateMockData()
  }

  // MARK: - Methods

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
