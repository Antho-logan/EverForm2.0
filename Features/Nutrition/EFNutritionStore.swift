//
//  EFNutritionStore.swift
//  EverForm
//
//  Created by Gemini on 18/11/2025.
//
//  IMPLEMENTATION NOTE:
//  This store currently uses in-memory data.
//  To connect to a real backend or database:
//  1. Replace `mock()` and `mockToday()` initializers with async fetch methods.
//  2. In `addFood` and `deleteFood`, call your API/DB service to persist changes.
//  3. Use SwiftData or CoreData for local persistence if offline support is needed.
//

import Foundation
import SwiftUI

@Observable
class EFNutritionStore {
    var profile: UserNutritionProfile
    var todaySummary: EFNutritionDaySummary

    init(profile: UserNutritionProfile = .mock(), todaySummary: EFNutritionDaySummary = .mockToday()) {
        self.profile = profile
        self.todaySummary = todaySummary
        
        // Ensure all meal types exist in the summary
        for type in MealType.allCases {
            if !self.todaySummary.meals.contains(where: { $0.type == type }) {
                self.todaySummary.meals.append(EFMeal(type: type))
            }
        }
        // Sort meals by standard order
        let order = MealType.allCases.map { $0 }
        self.todaySummary.meals.sort { m1, m2 in
            (order.firstIndex(of: m1.type) ?? 0) < (order.firstIndex(of: m2.type) ?? 0)
        }
    }

    func addFood(_ item: EFFoodItem, to mealType: MealType) {
        if let index = todaySummary.meals.firstIndex(where: { $0.type == mealType }) {
            todaySummary.meals[index].items.append(item)
        } else {
            todaySummary.meals.append(EFMeal(type: mealType, items: [item]))
        }
    }
    
    func deleteFood(_ item: EFFoodItem, from mealType: MealType) {
        guard let mealIndex = todaySummary.meals.firstIndex(where: { $0.type == mealType }),
              let itemIndex = todaySummary.meals[mealIndex].items.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        todaySummary.meals[mealIndex].items.remove(at: itemIndex)
    }

    func markAsCheat(_ meal: EFMeal) {
        // Placeholder: Logic to mark items as cheat or the whole meal
    }
}
