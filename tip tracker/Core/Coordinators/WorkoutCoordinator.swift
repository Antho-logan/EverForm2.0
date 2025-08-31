//
//  WorkoutCoordinator.swift
//  EverForm
//
//  Central router for workout presentation to fix sheet dismissal UX bug
//  Applied: P-ARCH, S-OBS1, C-SIMPLE, R-LOGS
//

import Foundation
import SwiftUI

enum WorkoutSheetStage: Identifiable, Equatable {
    case plan
    case session
    case finish
    
    var id: String { String(describing: self) }
}

/// Central router for workout presentation.
@Observable
final class WorkoutCoordinator {
    var stage: WorkoutSheetStage? = nil
    var currentPlan: Workout? = nil         // using existing Workout model
    var activeSession: WorkoutSession? = nil    // using existing WorkoutSession model
    var workoutSummary: WorkoutHistorySummary? = nil   // For finish view

    init() {
        DebugLog.info("WorkoutCoordinator initialized")
    }

    func openPlan(_ plan: Workout) {
        DebugLog.info("Opening workout plan: \(plan.title)")
        currentPlan = plan
        stage = .plan
    }

    func startWorkout(using workoutStore: WorkoutStore) async {
        guard let plan = currentPlan else { 
            DebugLog.info("No current plan to start workout")
            return 
        }
        
        DebugLog.info("Starting workout session for: \(plan.title)")
        
        // Start workout in the store
        await workoutStore.startPlannedWorkout(title: plan.title)
        
        stage = .session           // switch stage IN THE SAME SHEET
        
        TelemetryService.shared.track("workout_started_coordinator", properties: [
            "workout_id": plan.id.uuidString,
            "workout_title": plan.title
        ])
    }

    func resumeWorkout() {
        DebugLog.info("Resuming workout session")
        stage = .session
        
        TelemetryService.shared.track("workout_resumed_coordinator")
    }

    func closeAll() {
        DebugLog.info("Closing all workout sheets")
        stage = nil
    }

    func finishWorkout(with summary: WorkoutHistorySummary? = nil) {
        DebugLog.info("Finishing workout session")
        
        if let summary = summary {
            workoutSummary = summary
            stage = .finish // New stage for finish view
        } else {
            // Direct close without finish view
            workoutSummary = nil
            activeSession = nil
            stage = nil
        }
        
        TelemetryService.shared.track("workout_finished_coordinator")
    }
    
    func completeWorkout() {
        DebugLog.info("Completing workout flow")
        workoutSummary = nil
        activeSession = nil
        stage = nil
    }
}
