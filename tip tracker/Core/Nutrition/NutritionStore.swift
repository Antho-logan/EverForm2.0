//
//  NutritionStore.swift
//  EverForm
//
//  Central nutrition store with persistence and computed properties
//  Applied: S-OBS1, P-ARCH, C-SIMPLE, R-LOGS
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class NutritionStore {
    // MARK: - State
    private(set) var today: DayNutrition
    private(set) var week: [DayNutrition] = []
    var defaultGoal: NutritionGoal = .default {
        didSet {
            // Update today's goal when default changes
            today.updateGoal(defaultGoal)
            Task { await save() }
        }
    }
    

    
    init() {
        // Initialize today with default goal
        self.today = DayNutrition(date: Date(), goal: .default)
        
        DebugLog.info("NutritionStore initialized")
        
        // Load data
        Task {
            await load()
        }
    }
    
    // MARK: - Computed Properties
    
    /// Today's total calories
    var todayCalories: Int {
        today.totals.kcal
    }
    
    /// Today's calorie progress (0.0 to 1.0+)
    var todayCalorieProgress: Double {
        today.calorieProgress
    }
    
    /// Today's remaining calories
    var todayRemainingCalories: Int {
        today.remainingCalories
    }
    
    /// Weekly summary
    var weekSummary: WeekNutritionSummary {
        WeekNutritionSummary.currentWeek(from: week)
    }
    
    // MARK: - Entry Management
    
    /// Add a meal entry
    func addEntry(_ entry: MealEntry) {
        // Ensure entry is for today
        let entryDate = Calendar.current.startOfDay(for: entry.date)
        let todayDate = Calendar.current.startOfDay(for: Date())
        
        if Calendar.current.isDate(entryDate, inSameDayAs: todayDate) {
            today.addEntry(entry)
        } else {
            // Handle entries for other days
            if let dayIndex = week.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: entryDate) }) {
                week[dayIndex].addEntry(entry)
            } else {
                // Create new day if needed
                var newDay = DayNutrition(date: entryDate, goal: defaultGoal)
                newDay.addEntry(entry)
                week.append(newDay)
            }
        }
        
        Task { await save() }
        
        TelemetryService.shared.track("nutrition_entry_added", properties: [
            "source": entry.source.rawValue,
            "kcal": entry.kcal,
            "protein": entry.protein
        ])
        
        DebugLog.info("Added nutrition entry: \(entry.displayName) - \(entry.kcal) kcal")
    }
    
    /// Delete a meal entry by ID
    func deleteEntry(id: UUID) {
        // Try to find and remove from today first
        if today.entries.contains(where: { $0.id == id }) {
            today.removeEntry(id: id)
        } else {
            // Search in week days
            for index in week.indices {
                if week[index].entries.contains(where: { $0.id == id }) {
                    week[index].removeEntry(id: id)
                    break
                }
            }
        }
        
        Task { await save() }
        
        TelemetryService.shared.track("nutrition_entry_deleted")
        DebugLog.info("Deleted nutrition entry: \(id)")
    }
    
    /// Quick add with custom macros
    func quickAdd(kcal: Int, protein: Double? = nil, carbs: Double? = nil, fat: Double? = nil) {
        let entry = MealEntry.quickAdd(
            kcal: kcal,
            protein: protein,
            carbs: carbs,
            fat: fat,
            time: Date()
        )
        
        addEntry(entry)
        
        TelemetryService.shared.track("nutrition_quick_add", properties: [
            "kcal": kcal,
            "protein": protein ?? 0,
            "carbs": carbs ?? 0,
            "fat": fat ?? 0
        ])
    }
    
    /// Create entry from scan result
    func fromScanResult(_ foodItem: FoodItem, portionMultiplier: Double) -> MealEntry {
        let entry = MealEntry.fromScanResult(
            foodItem: foodItem,
            portionMultiplier: portionMultiplier,
            time: Date()
        )
        
        DebugLog.info("Created entry from scan: \(entry.displayName)")
        return entry
    }
    
    /// Get totals for a specific date
    func totals(for date: Date) -> NutritionValues {
        let targetDate = Calendar.current.startOfDay(for: date)
        
        if Calendar.current.isDate(today.date, inSameDayAs: targetDate) {
            return today.totals
        }
        
        if let day = week.first(where: { Calendar.current.isDate($0.date, inSameDayAs: targetDate) }) {
            return day.totals
        }
        
        return .zero
    }
    
    /// Update nutrition goal
    func updateGoal(_ newGoal: NutritionGoal) {
        defaultGoal = newGoal
        today.updateGoal(newGoal)
        
        Task { await save() }
        
        TelemetryService.shared.track("nutrition_goal_updated", properties: [
            "kcal": newGoal.kcal,
            "protein": newGoal.protein,
            "carbs": newGoal.carbs,
            "fat": newGoal.fat
        ])
        
        DebugLog.info("Updated nutrition goal: \(newGoal.displayString)")
    }
    
    // MARK: - Persistence
    
    /// Load nutrition data
    func load() async {
        // Ensure directory exists
        await ensureDirectoryExists()
        
        // Load today's data
        _ = await loadDay(Date())
        
        // Load last 7 days
        let calendar = Calendar.current
        var loadedDays: [DayNutrition] = []
        
        for dayOffset in -6...0 {  // Last 6 days + today
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: Date()) {
                if let day = await loadDay(date) {
                    loadedDays.append(day)
                } else {
                    // Create empty day if no data exists
                    loadedDays.append(DayNutrition(date: date, goal: defaultGoal))
                }
            }
        }
        
        // Update state on main actor since this class is already @MainActor
        self.week = loadedDays
        if let todayData = loadedDays.last {
            self.today = todayData
        }
        
        DebugLog.info("Loaded nutrition data: today \(today.entries.count) entries, week \(week.count) days")
    }
    
    /// Save nutrition data
    func save() async {
        await ensureDirectoryExists()
        
        // Save today
        await saveDay(today)
        
        // Save other days in week
        for day in week {
            if !day.entries.isEmpty || !Calendar.current.isDateInToday(day.date) {
                await saveDay(day)
            }
        }
        
        DebugLog.info("Saved nutrition data")
    }
    
    // MARK: - Private Persistence Methods
    
    private func ensureDirectoryExists() async {
        // SafeFileIO handles directory creation automatically
    }
    
    private func loadDay(_ date: Date) async -> DayNutrition? {
        let filename = filenameForDay(date)
        return SafeFileIO.load(DayNutrition.self, from: "nutrition/\(filename)")
    }
    
    private func saveDay(_ day: DayNutrition) async {
        let filename = filenameForDay(day.date)
        
        do {
            try SafeFileIO.save(day, to: "nutrition/\(filename)")
        } catch {
            DebugLog.info("Failed to save day \(day.formattedDate): \(error)")
            await MainActor.run {
                UX.Banner.show(message: "Failed to save nutrition data")
            }
        }
    }
    
    private func filenameForDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date) + ".json"
    }
}
