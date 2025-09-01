//
//  JournalStore.swift
//  EverForm
//
//  Demo storage for journal entries
//

import Foundation
import SwiftUI

@MainActor
final class JournalStore: ObservableObject {
    @Published var trainings: [JournalTrainingEntry] = []
    @Published var meals: [JournalMealEntry] = []
    @Published var recoveries: [JournalRecoveryEntry] = []
    @Published var mobilities: [JournalMobilityEntry] = []
    
    private let trainingsKey = "journal_trainings"
    private let mealsKey = "journal_meals"
    private let recoveriesKey = "journal_recoveries"
    private let mobilitiesKey = "journal_mobilities"
    
    init() {
        loadData()
    }
    
    // MARK: - Training Methods

    func addTraining(_ entry: JournalTrainingEntry) {
        trainings.append(entry)
        saveTrainings()

        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }

    func removeTraining(_ entry: JournalTrainingEntry) {
        trainings.removeAll { $0.id == entry.id }
        saveTrainings()
    }

    // MARK: - Nutrition Methods

    func addMeal(_ entry: JournalMealEntry) {
        meals.append(entry)
        saveMeals()

        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }

    func removeMeal(_ entry: JournalMealEntry) {
        meals.removeAll { $0.id == entry.id }
        saveMeals()
    }

    // MARK: - Recovery Methods

    func addRecovery(_ entry: JournalRecoveryEntry) {
        recoveries.append(entry)
        saveRecoveries()

        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }

    func removeRecovery(_ entry: JournalRecoveryEntry) {
        recoveries.removeAll { $0.id == entry.id }
        saveRecoveries()
    }

    // MARK: - Mobility Methods

    func addMobility(_ entry: JournalMobilityEntry) {
        mobilities.append(entry)
        saveMobilities()

        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }

    func removeMobility(_ entry: JournalMobilityEntry) {
        mobilities.removeAll { $0.id == entry.id }
        saveMobilities()
    }
    
    // MARK: - Persistence
    
    private func loadData() {
        loadTrainings()
        loadMeals()
        loadRecoveries()
        loadMobilities()
    }
    
    private func loadTrainings() {
        if let data = UserDefaults.standard.data(forKey: trainingsKey),
           let decoded = try? JSONDecoder().decode([JournalTrainingEntry].self, from: data) {
            trainings = decoded
        }
    }

    private func saveTrainings() {
        if let encoded = try? JSONEncoder().encode(trainings) {
            UserDefaults.standard.set(encoded, forKey: trainingsKey)
        }
    }

    private func loadMeals() {
        if let data = UserDefaults.standard.data(forKey: mealsKey),
           let decoded = try? JSONDecoder().decode([JournalMealEntry].self, from: data) {
            meals = decoded
        }
    }

    private func saveMeals() {
        if let encoded = try? JSONEncoder().encode(meals) {
            UserDefaults.standard.set(encoded, forKey: mealsKey)
        }
    }

    private func loadRecoveries() {
        if let data = UserDefaults.standard.data(forKey: recoveriesKey),
           let decoded = try? JSONDecoder().decode([JournalRecoveryEntry].self, from: data) {
            recoveries = decoded
        }
    }

    private func saveRecoveries() {
        if let encoded = try? JSONEncoder().encode(recoveries) {
            UserDefaults.standard.set(encoded, forKey: recoveriesKey)
        }
    }

    private func loadMobilities() {
        if let data = UserDefaults.standard.data(forKey: mobilitiesKey),
           let decoded = try? JSONDecoder().decode([JournalMobilityEntry].self, from: data) {
            mobilities = decoded
        }
    }

    private func saveMobilities() {
        if let encoded = try? JSONEncoder().encode(mobilities) {
            UserDefaults.standard.set(encoded, forKey: mobilitiesKey)
        }
    }
    
    // MARK: - Computed Properties

    var todaysTrainings: [JournalTrainingEntry] {
        let today = Calendar.current.startOfDay(for: Date())
        return trainings.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    var todaysMeals: [JournalMealEntry] {
        let today = Calendar.current.startOfDay(for: Date())
        return meals.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    var todaysRecoveries: [JournalRecoveryEntry] {
        let today = Calendar.current.startOfDay(for: Date())
        return recoveries.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    var todaysMobilities: [JournalMobilityEntry] {
        let today = Calendar.current.startOfDay(for: Date())
        return mobilities.filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    var todaysTotalCalories: Int {
        todaysMeals.reduce(0) { $0 + $1.totalCalories }
    }
}
