//
//  Calculators.swift
//  EverForm
//
//  Created by Anthony Logan on 23/08/2025.
//

import Foundation

/// Nutrition and fitness calculation utilities
enum Calculators {
    
    /// Compute personalized targets from user profile
    static func computeTargets(for profile: UserProfile) -> UserTargets {
        let age = Calendar.current.dateComponents([.year], from: profile.birthdate, to: Date()).year ?? 30
        let heightCm = profile.heightCm
        let weightKg = profile.weightKg
        let sex = profile.sex
        let activity = profile.activity
        let goal = profile.goal
        
        // Calculate BMR using Mifflin-St Jeor equation
        let bmr: Double
        switch sex {
        case .male:
            bmr = 10 * weightKg + 6.25 * heightCm - 5 * Double(age) + 5
        case .female:
            bmr = 10 * weightKg + 6.25 * heightCm - 5 * Double(age) - 161
        case .other:
            bmr = 10 * weightKg + 6.25 * heightCm - 5 * Double(age) - 78  // Average
        }
        
        // Activity multiplier
        let activityMultiplier: Double
        switch activity {
        case .sedentary: activityMultiplier = 1.2
        case .light: activityMultiplier = 1.375
        case .moderate: activityMultiplier = 1.55
        case .high: activityMultiplier = 1.725
        case .athlete: activityMultiplier = 1.9
        }
        
        let tdee = bmr * activityMultiplier
        
        // Goal adjustment
        let targetCalories: Int
        switch goal {
        case .fatLoss:
            targetCalories = Int(tdee * 0.8)  // 20% deficit
        case .recomposition:
            targetCalories = Int(tdee * 0.95)  // Small deficit
        case .muscleGain:
            targetCalories = Int(tdee * 1.1)   // 10% surplus
        case .maintainWeight:
            targetCalories = Int(tdee)  // Maintenance
        case .performance:
            targetCalories = Int(tdee * 1.05)  // Small surplus
        case .longevity:
            targetCalories = Int(tdee * 0.9)   // Mild restriction
        }
        
        // Macronutrient distribution
        let proteinG: Int
        switch goal {
        case .fatLoss, .recomposition:
            proteinG = Int(weightKg * 2.2)  // Higher protein for muscle preservation
        case .muscleGain, .performance:
            proteinG = Int(weightKg * 2.0)  // High protein for growth
        case .maintainWeight:
            proteinG = Int(weightKg * 1.8)  // Balanced protein for maintenance
        case .longevity:
            proteinG = Int(weightKg * 1.6)  // Moderate protein
        }
        
        let proteinCals = proteinG * 4
        let fatG = Int(Double(targetCalories) * 0.25 / 9)  // 25% from fat
        let fatCals = fatG * 9
        let carbsG = (targetCalories - proteinCals - fatCals) / 4
        
        // Hydration based on weight and activity
        let baseHydration = Int(weightKg * 35)  // 35ml per kg
        let activityBonus: Int
        switch activity {
        case .sedentary: activityBonus = 0
        case .light: activityBonus = 250
        case .moderate: activityBonus = 500
        case .high: activityBonus = 750
        case .athlete: activityBonus = 1000
        }
        let hydrationMl = baseHydration + activityBonus
        
        // Sleep recommendation
        let sleepHours: Double
        if age < 18 {
            sleepHours = 9.0
        } else if age < 65 {
            sleepHours = 8.0
        } else {
            sleepHours = 7.5
        }
        
        // Heart rate estimates
        let maxHR = 220 - age
        let restingHR = sex == .female ? 78 : 72  // Average estimates
        
        return UserTargets(
            targetCalories: targetCalories,
            proteinG: proteinG,
            carbsG: carbsG,
            fatG: fatG,
            hydrationMl: hydrationMl,
            sleepHours: sleepHours,
            restingHeartRate: restingHR,
            maxHeartRate: maxHR
        )
    }
    
    /// Calculate BMI from height and weight
    static func calculateBMI(heightCm: Double, weightKg: Double) -> Double {
        let heightM = heightCm / 100.0
        return weightKg / (heightM * heightM)
    }
    
    /// Get BMI category
    static func bmiCategory(bmi: Double) -> String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }
}

