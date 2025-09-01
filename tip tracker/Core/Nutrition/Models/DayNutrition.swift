//
//  DayNutrition.swift
//  EverForm
//
//  Daily nutrition tracking with entries and goals
//  Applied: P-ARCH, C-SIMPLE, R-LOGS
//

import Foundation

struct DayNutrition: Identifiable, Codable {
    let id: UUID
    let date: Date  // Day precision (start of day)
    var entries: [MealEntry]
    var goal: NutritionGoal
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        entries: [MealEntry] = [],
        goal: NutritionGoal = .default
    ) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.entries = entries
        self.goal = goal
    }
    
    /// Total nutrition values for the day
    var totals: NutritionValues {
        return entries.reduce(.zero) { result, entry in
            return result + entry.nutritionValues
        }
    }
    
    /// Entries sorted by time (newest first for display)
    var entriesByTime: [MealEntry] {
        return entries.sorted { $0.time > $1.time }
    }
    
    /// Progress towards goals (0.0 to 1.0+)
    var calorieProgress: Double {
        guard goal.kcal > 0 else { return 0.0 }
        return Double(totals.kcal) / Double(goal.kcal)
    }
    
    var proteinProgress: Double {
        guard goal.protein > 0 else { return 0.0 }
        return totals.protein / Double(goal.protein)
    }
    
    var carbsProgress: Double {
        guard goal.carbs > 0 else { return 0.0 }
        return totals.carbs / Double(goal.carbs)
    }
    
    var fatProgress: Double {
        guard goal.fat > 0 else { return 0.0 }
        return totals.fat / Double(goal.fat)
    }
    
    /// Remaining calories to goal
    var remainingCalories: Int {
        return max(0, goal.kcal - totals.kcal)
    }
    
    /// Formatted date for display
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    /// Short formatted date for display
    var shortFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    /// Whether this is today
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    /// Add a meal entry
    mutating func addEntry(_ entry: MealEntry) {
        entries.append(entry)
        DebugLog.info("Added meal entry: \(entry.displayName) - \(entry.kcal) kcal")
    }
    
    /// Remove a meal entry by ID
    mutating func removeEntry(id: UUID) {
        if let index = entries.firstIndex(where: { $0.id == id }) {
            let entry = entries[index]
            entries.remove(at: index)
            DebugLog.info("Removed meal entry: \(entry.displayName)")
        }
    }
    
    /// Update nutrition goal
    mutating func updateGoal(_ newGoal: NutritionGoal) {
        goal = newGoal
        DebugLog.info("Updated nutrition goal: \(newGoal.kcal) kcal")
    }
}

// MARK: - Nutrition Goal

struct NutritionGoal: Codable, Equatable {
    let kcal: Int
    let protein: Int  // grams
    let carbs: Int    // grams
    let fat: Int      // grams
    
    init(kcal: Int, protein: Int, carbs: Int, fat: Int) {
        self.kcal = kcal
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
    }
    
    /// Default nutrition goal (moderate activity adult)
    static let `default` = NutritionGoal(
        kcal: 2000,
        protein: 150,  // 30% of calories
        carbs: 250,    // 50% of calories
        fat: 67        // 20% of calories
    )
    
    /// Formatted display string
    var displayString: String {
        return "\(kcal) kcal • P: \(protein)g • C: \(carbs)g • F: \(fat)g"
    }
}











