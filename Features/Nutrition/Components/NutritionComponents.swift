//
//  NutritionComponents.swift
//  EverForm
//
//  Created by Gemini on 18/11/2025.
//

import SwiftUI

// MARK: - Meal Card
struct MealCardView: View {
  let meal: EFMeal
  let onAdd: () -> Void

  @State private var isExpanded = false

  var body: some View {
    EFCard {
      VStack(spacing: 0) {
        // Header
        HStack {
          Image(systemName: meal.type.icon)
            .foregroundStyle(DesignSystem.Colors.accent)
            .frame(width: 24)

          VStack(alignment: .leading, spacing: 2) {
            Text(meal.type.rawValue)
              .font(.app(.heading))
              .foregroundStyle(DesignSystem.Colors.textPrimary)

            Text("\(meal.totalCalories) kcal • \(meal.summaryText)")
              .font(.app(.caption))
              .foregroundStyle(DesignSystem.Colors.textSecondary)
          }

          Spacer()

          Button {
            onAdd()
          } label: {
            Image(systemName: "plus.circle.fill")
              .font(.title2)
              .foregroundStyle(DesignSystem.Colors.accent.opacity(0.1))
              .background(
                Circle()
                  .fill(DesignSystem.Colors.accent.opacity(0.1))
                  .frame(width: 32, height: 32)
              )
              .foregroundStyle(DesignSystem.Colors.accent)
          }
        }
        .padding(.bottom, isExpanded ? 12 : 0)
        .contentShape(Rectangle())
        .onTapGesture {
          withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isExpanded.toggle()
          }
        }

        // Expanded Items
        if isExpanded {
          if meal.items.isEmpty {
            Text("No items yet")
              .font(.app(.caption).italic())
              .foregroundStyle(DesignSystem.Colors.textSecondary)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.top, 8)
              .padding(.leading, 32)
          } else {
            VStack(spacing: 12) {
              Divider()
              ForEach(meal.items) { item in
                HStack {
                  VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                      .font(.app(.bodySecondary))
                      .foregroundStyle(DesignSystem.Colors.textPrimary)
                    Text(item.quantityDescription)
                      .font(.app(.caption))
                      .foregroundStyle(DesignSystem.Colors.textSecondary)
                  }
                  Spacer()
                  Text("\(item.calories)")
                    .font(.app(.bodySecondary))
                    .foregroundStyle(DesignSystem.Colors.textPrimary)
                }
              }
            }
          }
        }
      }
    }
  }
}
