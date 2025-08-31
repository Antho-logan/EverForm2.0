//
//  WeekNutritionSummary.swift
//  EverForm
//
//  Weekly nutrition summary for trends and analytics
//  Applied: P-ARCH, C-SIMPLE, R-LOGS
//

import Foundation

struct WeekNutritionSummary: Identifiable, Codable {
    let id: UUID
    let weekStart: Date  // Monday of the week
    let days: [DayNutrition]  // 7 days starting from weekStart
    
    init(id: UUID = UUID(), weekStart: Date, days: [DayNutrition]) {
        self.id = id
        self.weekStart = weekStart
        self.days = days
    }
    
    /// Total nutrition for the entire week
    var weeklyTotals: NutritionValues {
        return days.reduce(.zero) { result, day in
            return result + day.totals
        }
    }
    
    /// Average daily nutrition for the week
    var dailyAverages: NutritionValues {
        let totals = weeklyTotals
        let dayCount = max(1, days.count)
        
        return NutritionValues(
            kcal: totals.kcal / dayCount,
            protein: totals.protein / Double(dayCount),
            carbs: totals.carbs / Double(dayCount),
            fat: totals.fat / Double(dayCount)
        )
    }
    
    /// Days with logged entries
    var daysWithEntries: [DayNutrition] {
        return days.filter { !$0.entries.isEmpty }
    }
    
    /// Number of days with logged entries
    var activeDays: Int {
        return daysWithEntries.count
    }
    
    /// Formatted week range for display (e.g., "Dec 16 - 22")
    var formattedWeekRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let startString = formatter.string(from: weekStart)
        
        let weekEnd = Calendar.current.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
        let endString = formatter.string(from: weekEnd)
        
        return "\(startString) - \(endString)"
    }
    
    /// Chart data for calories by day
    var dailyCaloriesData: [(day: String, calories: Int)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"  // Mon, Tue, etc.
        
        return days.map { day in
            let dayName = formatter.string(from: day.date)
            return (day: dayName, calories: day.totals.kcal)
        }
    }
    
    /// Chart data for macros by day (stacked)
    var dailyMacrosData: [(day: String, protein: Double, carbs: Double, fat: Double)] {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        
        return days.map { day in
            let dayName = formatter.string(from: day.date)
            return (
                day: dayName,
                protein: day.totals.protein,
                carbs: day.totals.carbs,
                fat: day.totals.fat
            )
        }
    }
}

// MARK: - Factory Methods

extension WeekNutritionSummary {
    /// Create a summary for the current week
    static func currentWeek(from days: [DayNutrition]) -> WeekNutritionSummary {
        let today = Date()
        let calendar = Calendar.current
        
        // Find Monday of current week
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7  // Convert Sunday=1 to Monday=0
        let mondayDate = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
        let weekStart = calendar.startOfDay(for: mondayDate)
        
        // Filter days for this week
        let weekDays: [DayNutrition] = (0..<7).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else {
                return nil
            }
            
            // Find existing day or create empty one
            if let existingDay = days.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                return existingDay
            } else {
                return DayNutrition(date: date)
            }
        }
        
        return WeekNutritionSummary(weekStart: weekStart, days: weekDays)
    }
}
