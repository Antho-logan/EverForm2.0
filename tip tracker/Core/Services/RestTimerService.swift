//
//  RestTimerService.swift
//  EverForm
//
//  Rest timer service for workout sessions with countdown and haptics
//  Applied: S-OBS1, P-ARCH, C-SIMPLE, R-LOGS
//

import Foundation
import SwiftUI

@Observable
final class RestTimerService {
    private(set) var remaining: Int = 0
    private(set) var isActive: Bool = false
    private var timer: Timer?
    
    init() {
        DebugLog.info("RestTimerService initialized")
    }
    
    deinit {
        cancel()
    }
    
    /// Start rest timer for specified duration
    func start(seconds: Int) {
        DebugLog.info("Starting rest timer: \(seconds)s")
        
        cancel() // Cancel any existing timer
        remaining = seconds
        isActive = true
        
        // Haptic feedback on start
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.remaining > 0 {
                self.remaining -= 1
            } else {
                // Timer finished
                self.timerCompleted()
            }
        }
    }
    
    /// Cancel active timer
    func cancel() {
        DebugLog.info("Cancelling rest timer")
        timer?.invalidate()
        timer = nil
        remaining = 0
        isActive = false
    }
    
    /// Add time to current timer
    func addTime(seconds: Int) {
        guard isActive else { return }
        remaining += seconds
        DebugLog.info("Added \(seconds)s to rest timer, remaining: \(remaining)s")
        
        // Light haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
    
    /// Skip remaining time
    func skip() {
        DebugLog.info("Skipping rest timer")
        remaining = 0
        timerCompleted()
    }
    
    private func timerCompleted() {
        DebugLog.info("Rest timer completed")
        
        timer?.invalidate()
        timer = nil
        isActive = false
        remaining = 0
        
        // Success haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
    }
    
    /// Formatted time display (mm:ss)
    var formattedTime: String {
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}


