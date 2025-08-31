//
//  CoachContextBuilder.swift
//  EverForm
//
//  Created by Anthony Logan on 23/08/2025.
//

import Foundation

/// Builds personalized context for AI coach interactions
enum CoachContextBuilder {
    
    /// Build comprehensive user context for RAG system prompts
    static func build(
        profile: UserProfile?,
        targets: UserTargets?,
        advanced: ProfileAdvanced?,
        notes: String?
    ) -> String {
        var lines: [String] = []
        
        // Basic profile information
        if let p = profile {
            let age = Calendar.current.dateComponents([.year], from: p.birthdate, to: Date()).year ?? 30
            let bmi = Calculators.calculateBMI(heightCm: p.heightCm, weightKg: p.weightKg)
            let bmiCategory = Calculators.bmiCategory(bmi: bmi)
            
            lines += [
                "User: \(p.name.isEmpty ? "Athlete" : p.name)",
                "Sex: \(p.sex.rawValue) • Age: \(age) • H: \(Int(p.heightCm))cm • W: \(Int(p.weightKg))kg • BMI: \(String(format: "%.1f", bmi)) (\(bmiCategory))",
                "Goal: \(p.goal.rawValue) • Diet: \(p.diet.rawValue) • Activity: \(p.activity.rawValue)"
            ]
            
            if !p.allergies.isEmpty {
                lines.append("Allergies: \(p.allergies.joined(separator: ", "))")
            }
            
            if !p.injuries.isEmpty {
                lines.append("Injuries: \(p.injuries.joined(separator: ", "))")
            }
            
            if !p.equipment.isEmpty {
                lines.append("Equipment: \(p.equipment.joined(separator: ", "))")
            }
        }
        
        // Advanced profile data
        if let a = advanced {
            var advancedInfo: [String] = []
            
            if a.chronotype != .unknown {
                advancedInfo.append("Chronotype: \(a.chronotype.rawValue)")
            }
            
            if a.bloodType != .unknown {
                advancedInfo.append("BloodType: \(a.bloodType.rawValue)")
            }
            
            if let isPregnant = a.isPregnantOrPostpartum, isPregnant {
                advancedInfo.append("Pregnant/Postpartum: Yes")
            }
            
            if !advancedInfo.isEmpty {
                lines.append(advancedInfo.joined(separator: " • "))
            }
            
            if !a.knownConditions.isEmpty {
                lines.append("Conditions: \(a.knownConditions.joined(separator: ", "))")
            }
            
            if !a.supplements.isEmpty {
                lines.append("Supplements: \(a.supplements.joined(separator: ", "))")
            }
            
            if !a.foodDislikes.isEmpty {
                lines.append("FoodDislikes: \(a.foodDislikes.joined(separator: ", "))")
            }
            
            if let budget = a.budgetNotes, !budget.isEmpty {
                lines.append("Budget: \(budget)")
            }
        }
        
        // Nutrition targets
        if let t = targets {
            lines.append("Targets: \(t.targetCalories) kcal • P\(t.proteinG)g C\(t.carbsG)g F\(t.fatG)g • Hydration \(t.hydrationMl)ml • Sleep \(String(format: "%.1f", t.sleepHours))h")
            
            if let rhr = t.restingHeartRate, let maxHR = t.maxHeartRate {
                lines.append("HeartRate: RHR \(rhr) bpm • Max \(maxHR) bpm")
            }
        }
        
        // User notes for additional context
        if let n = notes, !n.isEmpty {
            let trimmedNotes = String(n.prefix(2000))  // Limit to prevent token overflow
            lines.append("Notes: \(trimmedNotes)")
        }
        
        // Safety guardrails
        lines += [
            "",
            "Guardrails: Natural-first guidance; no diagnosis; cite evidence; respect allergies/diet; avoid blood-type claims unless user insists; consider pregnancy/postpartum status; adjust for chronotype and activity level."
        ]
        
        return lines.joined(separator: "\n")
    }
    
    /// Build a shorter context summary for quick interactions
    static func buildSummary(
        profile: UserProfile?,
        targets: UserTargets?
    ) -> String {
        guard let profile = profile else { return "New user - no profile data available." }
        
        let age = Calendar.current.dateComponents([.year], from: profile.birthdate, to: Date()).year ?? 30
        var summary = "\(profile.name.isEmpty ? "User" : profile.name): \(age)y \(profile.sex.rawValue), \(profile.goal.rawValue), \(profile.activity.rawValue)"
        
        if !profile.allergies.isEmpty {
            summary += " • Allergies: \(profile.allergies.joined(separator: ", "))"
        }
        
        if let targets = targets {
            summary += " • Target: \(targets.targetCalories) kcal"
        }
        
        return summary
    }
}

