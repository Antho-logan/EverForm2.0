//
//  NutritionComponents.swift
//  EverForm
//
//  Created by Gemini on 18/11/2025.
//

import SwiftUI

// MARK: - Summary Card
struct NutritionSummaryCard: View {
  let profile: UserNutritionProfile
  let summary: EFNutritionDaySummary

  var progress: Double {
    min(Double(summary.caloriesConsumed) / Double(profile.dailyCalorieTarget), 1.0)
  }

  var body: some View {
    EFCard(
      style: .gradient(
        LinearGradient(
          colors: [Color.orange.opacity(0.8), Color.red.opacity(0.7)], startPoint: .topLeading,
          endPoint: .bottomTrailing))
    ) {
      VStack(spacing: 20) {
        HStack(alignment: .top) {
          VStack(alignment: .leading, spacing: 4) {
            Text("Daily Goal")
              .font(.app(.label))
              .foregroundStyle(.white.opacity(0.8))

            HStack(alignment: .firstTextBaseline, spacing: 4) {
              Text("\(summary.caloriesConsumed)")
                .font(.app(.largeTitle))
                .foregroundStyle(.white)
              Text("/ \(profile.dailyCalorieTarget) kcal")
                .font(.app(.bodySecondary))
                .foregroundStyle(.white.opacity(0.8))
            }
          }
          Spacer()
        }

        // Macros
        HStack(spacing: 16) {
          MacroPill(
            label: "Protein", value: summary.protein, target: profile.proteinTarget, color: .blue)
          MacroPill(
            label: "Carbs", value: summary.carbs, target: profile.carbsTarget, color: .green)
          MacroPill(label: "Fat", value: summary.fat, target: profile.fatTarget, color: .yellow)
        }
      }
      .foregroundStyle(.white)
    }
  }
}

struct MacroPill: View {
  let label: String
  let value: Int
  let target: Int
  let color: Color

  var progress: Double {
    min(Double(value) / Double(target), 1.0)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack {
        Text(label.prefix(1))
          .font(.app(.label))
        Spacer()
        Text("\(value)/\(target)g")
          .font(.app(.caption))
      }
      .foregroundStyle(.white.opacity(0.9))

      GeometryReader { geo in
        ZStack(alignment: .leading) {
          Capsule()
            .fill(.white.opacity(0.2))
          Capsule()
            .fill(.white)  // Use white for contrast on gradient
            .frame(width: geo.size.width * progress)
        }
      }
      .frame(height: 6)
    }
  }
}

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

// MARK: - Guidance Card
struct NutritionGuidanceCard: View {
  let profile: UserNutritionProfile
  let summary: EFNutritionDaySummary

  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      Image(systemName: "lightbulb.fill")
        .font(.app(.title))
        .foregroundStyle(.yellow)
        .frame(width: 32)

      VStack(alignment: .leading, spacing: 6) {
        Text("Today's Guidance")
          .font(.app(.heading))
          .foregroundStyle(DesignSystem.Colors.textPrimary)

        Text(NutritionGuidance.message(for: profile, summary: summary))
          .font(.app(.bodySecondary))
          .foregroundStyle(DesignSystem.Colors.textSecondary)
          .lineSpacing(4)
      }
    }
    .padding(16)
    .background(DesignSystem.Colors.cardBackground)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
  }
}

// MARK: - Add Meal Sheet
struct AddMealSheet: View {
  @Environment(\.dismiss) private var dismiss

  @State var mealType: MealType
  let onSave: (MealType, EFFoodItem) -> Void

  @State private var name = ""
  @State private var calories = ""
  @State private var protein = ""
  @State private var carbs = ""
  @State private var fat = ""
  @State private var isCheat = false

  init(initialMealType: MealType, onSave: @escaping (MealType, EFFoodItem) -> Void) {
    _mealType = State(initialValue: initialMealType)
    self.onSave = onSave
  }

  var body: some View {
    NavigationStack {
      Form {
        Section("Meal Details") {
          Picker("Meal Type", selection: $mealType) {
            ForEach(MealType.allCases) { type in
              Text(type.rawValue).tag(type)
            }
          }

          TextField("Food Name (e.g. Chicken Salad)", text: $name)

          TextField("Calories (kcal)", text: $calories)
            .keyboardType(.numberPad)
        }

        Section("Macros (Optional)") {
          HStack {
            Text("Protein (g)")
            Spacer()
            TextField("0", text: $protein)
              .multilineTextAlignment(.trailing)
              .keyboardType(.numberPad)
          }
          HStack {
            Text("Carbs (g)")
            Spacer()
            TextField("0", text: $carbs)
              .multilineTextAlignment(.trailing)
              .keyboardType(.numberPad)
          }
          HStack {
            Text("Fat (g)")
            Spacer()
            TextField("0", text: $fat)
              .multilineTextAlignment(.trailing)
              .keyboardType(.numberPad)
          }
        }

        Section {
          Toggle("Mark as Cheat Meal", isOn: $isCheat)
        }

        // Placeholder for Scan
        Section {
          Button {
            // TODO: Hook up scan feature
          } label: {
            Label("Import from Scan", systemImage: "camera.viewfinder")
              .foregroundStyle(.secondary)
          }
          .disabled(true)
        } footer: {
          Text("Scanning feature coming soon")
        }
      }
      .navigationTitle("Add Meal")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            let item = EFFoodItem(
              name: name.isEmpty ? "Quick Add" : name,
              quantityDescription: "1 serving",
              calories: Int(calories) ?? 0,
              protein: Int(protein) ?? 0,
              carbs: Int(carbs) ?? 0,
              fat: Int(fat) ?? 0,
              isCheat: isCheat
            )
            onSave(mealType, item)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            dismiss()
          }
          .disabled(calories.isEmpty)
        }
      }
    }
  }
}
