//
//  NutritionChartsService.swift
//  EverForm
//
//  Helper service for computing nutrition chart data and trends
//  Applied: P-ARCH, C-SIMPLE, R-LOGS
//

import Foundation

struct NutritionChartsService {
    
    /// Compute weekly calorie trend data for charts
    static func weeklyCalorieTrend(from days: [DayNutrition]) -> [(day: String, calories: Int)] {
        let sortedDays = days.sorted { $0.date < $1.date }
        let formatter = DateFormatter()
        formatter.dateFormat = "E"  // Mon, Tue, Wed, etc.
        
        return sortedDays.map { day in
            let dayName = formatter.string(from: day.date)
            return (day: dayName, calories: day.totals.kcal)
        }
    }
    
    /// Compute weekly macro trend data for stacked charts
    static func weeklyMacroTrend(from days: [DayNutrition]) -> [(day: String, protein: Double, carbs: Double, fat: Double)] {
        let sortedDays = days.sorted { $0.date < $1.date }
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        
        return sortedDays.map { day in
            let dayName = formatter.string(from: day.date)
            let totals = day.totals
            return (
                day: dayName,
                protein: totals.protein,
                carbs: totals.carbs,
                fat: totals.fat
            )
        }
    }
    
    /// Compute macro distribution for pie charts (percentages)
    static func macroDistribution(from nutrition: NutritionValues) -> (protein: Double, carbs: Double, fat: Double) {
        // Calculate calories from each macro
        let proteinKcal = nutrition.protein * 4  // 4 kcal per gram
        let carbsKcal = nutrition.carbs * 4      // 4 kcal per gram
        let fatKcal = nutrition.fat * 9          // 9 kcal per gram
        
        let totalMacroKcal = proteinKcal + carbsKcal + fatKcal
        
        guard totalMacroKcal > 0 else {
            return (protein: 0, carbs: 0, fat: 0)
        }
        
        return (
            protein: proteinKcal / totalMacroKcal,
            carbs: carbsKcal / totalMacroKcal,
            fat: fatKcal / totalMacroKcal
        )
    }
    
    /// Calculate average daily nutrition over a period
    static func averageDailyNutrition(from days: [DayNutrition]) -> NutritionValues {
        guard !days.isEmpty else { return .zero }
        
        let totalNutrition = days.reduce(.zero) { result, day in
            return result + day.totals
        }
        
        let dayCount = days.count
        return NutritionValues(
            kcal: totalNutrition.kcal / dayCount,
            protein: totalNutrition.protein / Double(dayCount),
            carbs: totalNutrition.carbs / Double(dayCount),
            fat: totalNutrition.fat / Double(dayCount)
        )
    }
    
    /// Calculate nutrition streaks (consecutive days meeting goals)
    static func calculateStreaks(from days: [DayNutrition]) -> (calorieStreak: Int, proteinStreak: Int) {
        let sortedDays = days.sorted { $0.date > $1.date } // Most recent first
        
        var calorieStreak = 0
        var proteinStreak = 0
        
        for day in sortedDays {
            // Check if calorie goal was met (within 10% tolerance)
            let calorieTarget = Double(day.goal.kcal)
            let calorieActual = Double(day.totals.kcal)
            let calorieWithinRange = calorieActual >= (calorieTarget * 0.8) && calorieActual <= (calorieTarget * 1.2)
            
            if calorieWithinRange {
                calorieStreak += 1
            } else {
                break
            }
        }
        
        for day in sortedDays {
            // Check if protein goal was met
            let proteinTarget = Double(day.goal.protein)
            let proteinActual = day.totals.protein
            let proteinMet = proteinActual >= (proteinTarget * 0.9) // 90% of goal
            
            if proteinMet {
                proteinStreak += 1
            } else {
                break
            }
        }
        
        return (calorieStreak: calorieStreak, proteinStreak: proteinStreak)
    }
    
    /// Generate chart color for macro type
    static func colorForMacro(_ macro: MacroType) -> (red: Double, green: Double, blue: Double) {
        switch macro {
        case .protein:
            return (red: 0.2, green: 0.6, blue: 0.9)  // Blue
        case .carbs:
            return (red: 0.9, green: 0.6, blue: 0.2)  // Orange
        case .fat:
            return (red: 0.9, green: 0.2, blue: 0.4)  // Red-pink
        }
    }
    
    /// Format nutrition value for display
    static func formatNutritionValue(_ value: Double, type: MacroType) -> String {
        switch type {
        case .protein, .carbs, .fat:
            return String(format: "%.1fg", value)
        }
    }
    
    /// Format calories for display
    static func formatCalories(_ calories: Int) -> String {
        if calories >= 1000 {
            let k = Double(calories) / 1000.0
            return String(format: "%.1fk", k)
        } else {
            return "\(calories)"
        }
    }
}

// MARK: - Supporting Types

enum MacroType: String, CaseIterable {
    case protein
    case carbs
    case fat
    
    var displayName: String {
        switch self {
        case .protein: return "Protein"
        case .carbs: return "Carbs"
        case .fat: return "Fat"
        }
    }
    
    var shortName: String {
        switch self {
        case .protein: return "P"
        case .carbs: return "C"
        case .fat: return "F"
        }
    }
}

// MARK: - Chart Data Types

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    let category: String?
    
    init(label: String, value: Double, category: String? = nil) {
        self.label = label
        self.value = value
        self.category = category
    }
}








