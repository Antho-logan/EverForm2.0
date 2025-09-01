//
//  QuickActionCoordinator.swift
//  EverForm
//
//  Coordinates Quick Action sheet presentation and routing
//  Assumptions: Single active sheet, environment-based tab switching
//

import Foundation
import SwiftUI

// CoachTopic enum moved to Models/CoachModels.swift to avoid duplicates

enum ActiveSheet: String, Identifiable {
    case startWorkout = "start_workout"
    case quickMeal = "quick_meal"
    case breathwork = "breathwork"
    case mobility = "mobility"
    case fixPain = "fix_pain"
    case mealChoice = "meal_choice"
    case waterQuickAdd = "water_quick_add"
    
    var id: String { rawValue }
}

@Observable
final class QuickActionCoordinator {
    var activeSheet: ActiveSheet?
    var showToast = false
    var toastMessage = ""
    
    // Services
    let nutritionService: NutritionLogService
    let hydrationService: HydrationService
    let trainingService: TrainingService
    
    // Callbacks for external navigation
    var openScanCalories: (() -> Void)?
    var routeToCoach: ((String, CoachTopic) -> Void)?
    
    init(
        nutritionService: NutritionLogService = NutritionLogService(),
        hydrationService: HydrationService = HydrationService(),
        trainingService: TrainingService = TrainingService()
    ) {
        self.nutritionService = nutritionService
        self.hydrationService = hydrationService
        self.trainingService = trainingService
        
        DebugLog.info("QuickActionCoordinator initialized")
    }
    
    // MARK: - Quick Action Methods
    
    func startWorkout() {
        DebugLog.info("Quick Action: Start Workout")
        TelemetryService.shared.track("qa_tap", properties: ["action": "start_workout"])
        activeSheet = .startWorkout
    }
    
    func logMeal() {
        DebugLog.info("Quick Action: Log Meal")
        TelemetryService.shared.track("qa_tap", properties: ["action": "log_meal"])
        activeSheet = .mealChoice
    }
    
    func startBreathwork() {
        DebugLog.info("Quick Action: Breathwork")
        TelemetryService.shared.track("qa_tap", properties: ["action": "breathwork"])
        activeSheet = .breathwork
    }
    
    func startMobility() {
        DebugLog.info("Quick Action: Mobility")
        TelemetryService.shared.track("qa_tap", properties: ["action": "mobility"])
        activeSheet = .mobility
    }
    
    func openPhysio() {
        DebugLog.info("Quick Action: Fix Pain")
        TelemetryService.shared.track("qa_tap", properties: ["action": "fix_pain"])
        activeSheet = .fixPain
    }
    
    func logWater() {
        DebugLog.info("Quick Action: Log Water")
        hydrationService.addWater(ml: 250)
        let glasses = hydrationService.todayMl / 250
        showToast(message: "Logged water • \(glasses) glasses today")
    }
    
    func showWaterSheet() {
        DebugLog.info("Quick Action: Show Water Sheet")
        TelemetryService.shared.track("qa_tap", properties: ["action": "show_water_sheet"])
        activeSheet = .waterQuickAdd
    }
    
    // MARK: - Meal Choice Actions
    
    func chooseScanCalories() {
        DebugLog.info("Meal choice: Scan calories")
        activeSheet = nil
        openScanCalories?()
    }
    
    func chooseQuickAdd() {
        DebugLog.info("Meal choice: Quick add")
        activeSheet = .quickMeal
    }
    
    // MARK: - Fix Pain Routing
    
    func routeToCoachForPain(region: String) {
        DebugLog.info("Routing to Coach for pain: \(region)")
        activeSheet = nil
        
        let message = "I have persistent \(region.lowercased()) discomfort after training. Suggest natural mobility/strength fixes and a 7-day plan. Cite sources."
        
        routeToCoach?(message, .general)
        TelemetryService.shared.track("fix_pain_route_coach", properties: ["region": region])
    }
    
    // MARK: - Toast Management
    
    func showToast(message: String) {
        toastMessage = message
        showToast = true
        
        // Auto-hide after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showToast = false
        }
    }
    
    // MARK: - Completion Handlers
    
    func handleWorkoutComplete() {
        showToast(message: "Workout saved to training log")
        TelemetryService.shared.track("qa_complete", properties: ["action": "workout"])
    }
    
    func handleMealAdded() {
        showToast(message: "Added to nutrition log")
        TelemetryService.shared.track("qa_complete", properties: ["action": "quick_meal"])
    }
    
    func handleBreathworkComplete() {
        showToast(message: "Nice – breathwork logged")
        TelemetryService.shared.track("qa_complete", properties: ["action": "breathwork"])
    }
    
    func handleMobilityComplete() {
        showToast(message: "Mobility complete")
        TelemetryService.shared.track("qa_complete", properties: ["action": "mobility"])
    }
}
