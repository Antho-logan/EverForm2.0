//
//  NutritionLogService.swift
//  EverForm
//
//  UserDefaults-backed nutrition entry logging
//  Assumptions: Last 20 entries, simple persistence
//

import Foundation
import SwiftUI

struct QuickNutritionEntry: Codable, Identifiable, Hashable {
    var id = UUID()
    let date: Date
    let name: String?
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    
    init(name: String? = nil, calories: Int, protein: Double, carbs: Double, fat: Double) {
        self.id = UUID()
        self.date = Date()
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
    }
}

@Observable
final class NutritionLogService {
    private let key = "everform.nutrition.log.v1"
    private let maxEntries = 20
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    var entries: [QuickNutritionEntry] = []
    
    init() {
        load()
        DebugLog.info("NutritionLogService initialized with \(entries.count) entries")
    }
    
    func add(entry: QuickNutritionEntry) {
        DebugLog.info("Adding nutrition entry: \(entry.name ?? "Unnamed") - \(entry.calories)kcal")
        
        entries.insert(entry, at: 0)
        
        // Keep only the last maxEntries
        if entries.count > maxEntries {
            entries = Array(entries.prefix(maxEntries))
        }
        
        save()
        TelemetryService.shared.track("nutrition_entry_added", properties: ["calories": "\(entry.calories)"])
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { 
            entries = []
            return 
        }
        
        entries = (try? decoder.decode([QuickNutritionEntry].self, from: data)) ?? []
    }
    
    private func save() {
        if let data = try? encoder.encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func clear() {
        DebugLog.info("Clearing nutrition log")
        entries = []
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    // Computed properties for dashboard display
    var todayCalories: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return entries
            .filter { Calendar.current.startOfDay(for: $0.date) == today }
            .reduce(0) { $0 + $1.calories }
    }
    
    var todayProtein: Double {
        let today = Calendar.current.startOfDay(for: Date())
        return entries
            .filter { Calendar.current.startOfDay(for: $0.date) == today }
            .reduce(0) { $0 + $1.protein }
    }
}
