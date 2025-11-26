//
//  UserProfile.swift
//  EverForm
//
//  Created by Anthony Logan on 23/08/2025.
//

import Foundation

/// Core user profile model for onboarding and personalization
struct UserProfile: Codable, Equatable {
    enum Sex: String, Codable, CaseIterable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
    }
    
    enum Goal: String, Codable, CaseIterable {
        case fatLoss = "Fat Loss"
        case recomposition = "Recomposition"
        case muscleGain = "Muscle Gain"
        case maintainWeight = "Maintain Weight"
        case performance = "Performance"
        case longevity = "Longevity"
    }
    
    enum Activity: String, Codable, CaseIterable {
        case sedentary = "Sedentary"
        case light = "Light"
        case moderate = "Moderate"
        case high = "High"
        case athlete = "Athlete"
    }
    
    enum Diet: String, Codable, CaseIterable {
        case none = "None"
        case balanced = "Balanced"
        case mediterranean = "Mediterranean"
        case paleo = "Paleo"
        case plantBased = "Plant-Based"
        case omnivore = "Omnivore"
        case lowCarb = "Low Carb"
        case highProtein = "High Protein"
    }

    enum UnitSystem: String, Codable, CaseIterable {
        case metric = "Metric"
        case imperial = "Imperial"
    }
    
    // Basic info
    var name: String
    var email: String
    var phone: String
    var sex: Sex
    var birthdate: Date
    var heightCm: Double
    var weightKg: Double
    var unitSystem: UnitSystem
    
    // Lifestyle
    var goal: Goal
    var diet: Diet
    var activity: Activity
    
    // Health considerations
    var allergies: [String]
    var injuries: [String]
    var equipment: [String]
    
    // Sleep (optional)
    var usualBedtime: Date?
    var usualWake: Date?
    
    init(
        name: String = "",
        email: String = "",
        phone: String = "",
        sex: Sex = .male,
        birthdate: Date = Calendar.current.date(byAdding: .year, value: -28, to: Date()) ?? Date(),
        heightCm: Double = 178,
        weightKg: Double = 78,
        unitSystem: UnitSystem = .metric,
        goal: Goal = .recomposition,
        diet: Diet = .omnivore,
        activity: Activity = .moderate,
        allergies: [String] = [],
        injuries: [String] = [],
        equipment: [String] = [],
        usualBedtime: Date? = nil,
        usualWake: Date? = nil
    ) {
        self.name = name
        self.email = email
        self.phone = phone
        self.sex = sex
        self.birthdate = birthdate
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.unitSystem = unitSystem
        self.goal = goal
        self.diet = diet
        self.activity = activity
        self.allergies = allergies
        self.injuries = injuries
        self.equipment = equipment
        self.usualBedtime = usualBedtime
        self.usualWake = usualWake
    }
}

/// Calculated nutrition and lifestyle targets
struct UserTargets: Codable, Equatable {
    var targetCalories: Int
    var proteinG: Int
    var carbsG: Int
    var fatG: Int
    var hydrationMl: Int
    var sleepHours: Double
    var steps: Int
    var restingHeartRate: Int?
    var maxHeartRate: Int?
    
    static let `default` = UserTargets(
        targetCalories: 2200,
        proteinG: 165,
        carbsG: 220,
        fatG: 80,
        hydrationMl: 2500,
        sleepHours: 8.0,
        steps: 10000
    )
}

