//
//  DashboardViewModel.swift
//  EverForm
//
//  Dashboard data model with demo seeding
//  Assumptions: Mock data for demo, HealthKit integration TODO
//  Uses Observation for SwiftUI reactivity
//

import Foundation
import SwiftUI

@Observable
final class DashboardViewModel {
    var firstName: String = "Alex"
    var readinessScore: Int = 74
    var rhr: Int = 52
    var hrv: Int = 45
    var streakDays: Int = 5
    var consistency: Double = 0.81
    
    var todaySteps: Int = 8420
    var todayCalories: Int = 1850
    var todaySleepHours: Double = 7.5
    private let hydrationService = HydrationService()
    var todayHydrationMl: Int {
        hydrationService.todayMl
    }
    var todayHydrationGlasses: Int {
        todayHydrationMl / 250 // Convert ml to glasses (250ml per glass)
    }
    var targetCalories: Int = 2700

    var recommendedBedtimeText: String {
        if let recovery = todayRecovery {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: recovery.bedStart)
        }
        return "22:30"
    }

    func addWater(_ ml: Int = 250) {
        hydrationService.addWater(ml: ml)
    }
    
    struct TrainingPlan {
        var name: String
        var durationMinutes: Int
        var mainLifts: [String]
    }
    
    struct MacroPlan {
        var calories: Int
        var protein: Int
        var carbs: Int
        var fats: Int
    }
    
    struct RecoveryPlan {
        var bedStart: Date
        var bedEnd: Date
        var notes: String
    }
    
    struct MobilityPlan {
        var focus: String
        var minutes: Int
    }
    
    var todayTraining: TrainingPlan? = .init(
        name: "Upper Power",
        durationMinutes: 75,
        mainLifts: ["Bench Press", "Pull-ups", "Overhead Press"]
    )
    
    var todayNutrition: MacroPlan? = .init(
        calories: 2400,
        protein: 150,
        carbs: 300,
        fats: 80
    )
    
    var todayRecovery: RecoveryPlan?
    var todayMobility: MobilityPlan? = .init(focus: "Hips & Shoulders", minutes: 8)
    
    struct Metrics7d {
        var dates: [Date]
        var hrv: [Double]
        var rhr: [Double]
        var steps: [Int]
        var weight: [Double]?
    }
    
    var metrics7d: Metrics7d = .init(dates: [], hrv: [], rhr: [], steps: [], weight: nil)
    var isReadinessSheetPresented = false
    
    // Loading states
    var isLoadingProgress = false
    var isLoadingMetrics = false
    
    // Sheet presentation states
    var showingScanSheet = false
    var showingCoachView = false

    // Navigation sheet states for Today's Plan
    var presentTraining: Bool = false
    var presentNutrition: Bool = false
    var presentRecovery: Bool = false
    var presentMobility: Bool = false
    
    init() {
        seedDemo()
    }
    
    func seedDemo() {
        DebugLog.d("Seeding demo data for 7 days")
        
        let calendar = Calendar.current
        let today = Date()
        
        // Generate 7 days of data
        metrics7d.dates = (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: -dayOffset, to: today)
        }.reversed()
        
        // Realistic HRV data (40-60ms range)
        metrics7d.hrv = [42.3, 45.1, 48.7, 43.2, 46.8, 44.5, 45.0]
        
        // Realistic RHR data (50-60 bpm)
        metrics7d.rhr = [54.0, 52.0, 55.0, 53.0, 52.0, 51.0, 52.0]
        
        // Steps data (6k-12k range)
        metrics7d.steps = [8420, 9850, 7200, 11400, 8900, 6750, 10200]
        
        // Optional weight data
        metrics7d.weight = [72.5, 72.3, 72.1, 72.4, 72.2, 72.0, 72.1]
        
        // Set recovery plan if missing
        if todayRecovery == nil {
            let bedStart = calendar.date(bySettingHour: 22, minute: 30, second: 0, of: today) ?? today
            let bedEnd = calendar.date(bySettingHour: 6, minute: 30, second: 0, of: calendar.date(byAdding: .day, value: 1, to: today) ?? today) ?? today
            todayRecovery = RecoveryPlan(
                bedStart: bedStart,
                bedEnd: bedEnd,
                notes: "Wind down routine"
            )
        }
        
        TelemetryService.shared.track("dashboard_data_seeded")
    }
    
    func logTap(_ event: String) {
        DebugLog.d("User tap: \(event)")
        TelemetryService.shared.track(event)
    }
    
    // MARK: - Action Methods
    func openReadinessExplainer() {
        logTap("readiness_tap")
        isReadinessSheetPresented = true
    }
    
    func openCoach() {
        logTap("coach_open")
    }
    
    // MARK: - Quick Action Methods
    func quickAddWater() {
        logTap("quick_add_water")
        addWater(250)
    }
    
    func startBreathwork() {
        logTap("start_breathwork")
        // TODO: Open breathwork sheet
    }
    
    func openFixPain() {
        logTap("open_fix_pain")
        // TODO: Open fix pain view
    }
    
    func askCoach() {
        logTap("ask_coach")
        openCoach()
        showingCoachView = true
    }

    func profileTapped() {
        logTap("profile_tap")
        // TODO: Open profile view
    }

    func moreTapped() {
        logTap("more_tap")
        // TODO: Open more options
    }

    // MARK: - Profile Menu Methods
    var profileName: String? { "Alex Chen" }
    var profileEmail: String? { "alex@example.com" }

    func openProfile() {
        logTap("profile_menu_profile")
        // TODO: Navigate to profile view
    }

    func openDisplaySettings() {
        logTap("profile_menu_display")
        // TODO: Navigate to display settings
    }

    func openSecurity() {
        logTap("profile_menu_security")
        // TODO: Navigate to security settings
    }

    func exportData() {
        logTap("profile_menu_export")
        // TODO: Export user data
    }

    func openHelp() {
        logTap("profile_menu_help")
        // TODO: Open help view
    }

    func reportBug() {
        logTap("profile_menu_bug_report")
        // TODO: Open bug report form
    }

}
