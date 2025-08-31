import Foundation
import SwiftUI

@Observable
final class HydrationService {
    private let keyPrefix = "everform.hydration.ml."
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var todayMl: Int = 0
    private var currentDateKey: String = ""
    
    init() {
        let todayKey = dateFormatter.string(from: Date())
        self.currentDateKey = todayKey
        loadTodayMl()
        DebugLog.info("HydrationService initialized - today: \(todayMl) ml")
    }
    
    func addWater(ml: Int) {
        resetIfNewDay()
        todayMl += ml
        saveTodayMl()
        
        DebugLog.info("Water logged - \(ml)ml added. Total today: \(todayMl) ml")
        TelemetryService.shared.track("qa_tap", properties: ["action": "log_water", "amount_ml": "\(ml)"])
    }
    
    func resetIfNewDay() {
        let today = Date()
        let todayKey = dateFormatter.string(from: today)
        
        if currentDateKey != todayKey {
            currentDateKey = todayKey
            loadTodayMl()
            DebugLog.info("New day detected, hydration reset")
        }
    }
    
    private func loadTodayMl() {
        let key = keyPrefix + currentDateKey
        todayMl = UserDefaults.standard.integer(forKey: key)
    }
    
    private func saveTodayMl() {
        let key = keyPrefix + currentDateKey
        UserDefaults.standard.set(todayMl, forKey: key)
    }
    
    func getMl(for date: Date) -> Int {
        let dateKey = dateFormatter.string(from: date)
        let key = keyPrefix + dateKey
        return UserDefaults.standard.integer(forKey: key)
    }
}