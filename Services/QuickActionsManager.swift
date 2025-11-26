//
//  QuickActionsManager.swift
//  EverForm
//
//  Manager for quick actions ordering and persistence
//

import SwiftUI
import Observation

@Observable
final class QuickActionsManager {
    private let userDefaults = UserDefaults.standard
    private let orderKey = "quickActions.order"
    
    var quickActions: [AppQuickAction] = []
    var isReordering = false
    
    init() {
        loadQuickActions()
    }
    
    private func loadQuickActions() {
        // Load saved order from UserDefaults
        let savedOrder = userDefaults.stringArray(forKey: orderKey) ?? []
        
        if savedOrder.isEmpty {
            // First time - use default order
            quickActions = AppQuickAction.defaultActions
            saveOrder()
        } else {
            // Restore saved order
            var orderedActions: [AppQuickAction] = []
            let defaultActionsDict = Dictionary(uniqueKeysWithValues: AppQuickAction.defaultActions.map { ($0.id, $0) })
            
            // Add actions in saved order
            for actionId in savedOrder {
                if let action = defaultActionsDict[actionId] {
                    orderedActions.append(action)
                }
            }
            
            // Add any new actions that weren't in the saved order
            for defaultAction in AppQuickAction.defaultActions {
                if !orderedActions.contains(where: { $0.id == defaultAction.id }) {
                    orderedActions.append(defaultAction)
                }
            }
            
            quickActions = orderedActions
        }
    }
    
    private func saveOrder() {
        let order = quickActions.map { $0.id }
        userDefaults.set(order, forKey: orderKey)
    }
    
    func startReordering() {
        isReordering = true
    }
    
    func stopReordering() {
        isReordering = false
        saveOrder()
    }
    
    func moveAction(from source: IndexSet, to destination: Int) {
        quickActions.move(fromOffsets: source, toOffset: destination)
        saveOrder()
    }
    
    func executeAction(_ action: AppQuickAction, 
                      viewModel: DashboardViewModel,
                      openExplain: @escaping (String, String) -> Void,
                      showBreathworkSheet: @escaping () -> Void,
                      showPainHelperSheet: @escaping () -> Void) {
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        switch action.actionType {
        case .addWater:
            DebugLog.info("Overview: Add Water quick action tapped")
            viewModel.addWater(250)
            
        case .breathwork:
            DebugLog.info("Overview: Breathwork quick action tapped")
            showBreathworkSheet()
            
        case .fixPain:
            DebugLog.info("Overview: Fix pain quick action tapped")
            showPainHelperSheet()
            
        case .askCoach:
            DebugLog.info("Overview: Ask Coach quick action tapped")
            viewModel.openCoach()
        }
    }
}
