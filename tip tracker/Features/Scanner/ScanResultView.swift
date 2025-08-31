//
// ScanResultView.swift
// EverForm Scanner V2
//
// Enhanced result display with canonical scan models and simulator-safe mocks
// Assumptions: Real-time portion calculations, traffic-light ingredient scoring
//

import SwiftUI

struct ScanResultView: View {
    let result: ScanResult
    @Environment(NutritionStore.self) private var nutritionStore
    @Environment(ProfileStore.self) private var profileStore
    @State private var savedToast = false
    private var titleText: String { result.productName ?? "Scan Result" }
    private var macro: NutritionMacro? { result.macro }
    private var ingredients: [IngredientAssessment]? { result.ingredients }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                if let macro { macroCard(macro) }
                if let ingredients { ingredientsCard(ingredients) }
                if case let .plateAI(estimate) = result { plateCard(estimate) }
                saveSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .navigationTitle(titleText)
        .toolbarTitleDisplayMode(.inline)
        .toast(isPresented: $savedToast, message: "Saved to log")
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(titleText)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                switch result {
                case .calorie:
                    Text("Calorie & macros").font(.system(size: 14, weight: .regular, design: .rounded)).foregroundStyle(.secondary)
                case .ingredients:
                    Text("Ingredients assessment").font(.system(size: 14, weight: .regular, design: .rounded)).foregroundStyle(.secondary)
                case .plateAI:
                    Text("Plate estimate (beta)").font(.system(size: 14, weight: .regular, design: .rounded)).foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }

    private func macroCard(_ m: NutritionMacro) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nutrition")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
            HStack {
                stat("Calories", "\(m.calories)")
                stat("Protein", String(format: "%.0fg", m.protein))
                stat("Carbs",   String(format: "%.0fg", m.carbs))
                stat("Fat",     String(format: "%.0fg", m.fat))
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))
    }

    private func ingredientsCard(_ ingredients: [IngredientAssessment]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredient Assessment")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
            
            // Profile-aware warnings
            if let profile = profileStore.profile {
                let profileAwareIngredients = assessIngredientsWithProfile(ingredients, profile: profile)
                
                ForEach(profileAwareIngredients) { ingredient in
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ingredient.name)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                            
                            if !ingredient.reasons.isEmpty {
                                VStack(alignment: .leading, spacing: 2) {
                                    ForEach(ingredient.reasons, id: \.self) { reason in
                                        Text("• \(reason)")
                                            .font(.system(size: 14, weight: .regular, design: .rounded))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                        
                        verdictBadge(ingredient.verdict)
                    }
                    .padding(.vertical, 8)
                    
                    if ingredient != profileAwareIngredients.last {
                        Divider()
                    }
                }
            } else {
                // Fallback to original ingredients if no profile
                ForEach(ingredients) { ingredient in
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ingredient.name)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                            
                            if !ingredient.reasons.isEmpty {
                                VStack(alignment: .leading, spacing: 2) {
                                    ForEach(ingredient.reasons, id: \.self) { reason in
                                        Text("• \(reason)")
                                            .font(.system(size: 14, weight: .regular, design: .rounded))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                        
                        verdictBadge(ingredient.verdict)
                    }
                    .padding(.vertical, 8)
                    
                    if ingredient != ingredients.last {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))
    }

    private func plateCard(_ est: PlateEstimate) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Plate items")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
            ForEach(est.items) { item in
                HStack {
                    Text(item.name).font(.system(size: 16, weight: .semibold, design: .rounded))
                    Spacer()
                    Text("\(Int(item.grams)) g").foregroundStyle(.secondary).font(.system(size: 14, weight: .regular, design: .rounded))
                }
                HStack(spacing: 12) {
                    stat("Kcal", "\(item.macro.calories)")
                    stat("P", String(format: "%.0f", item.macro.protein))
                    stat("C", String(format: "%.0f", item.macro.carbs))
                    stat("F", String(format: "%.0f", item.macro.fat))
                }
                .padding(.bottom, 8)
                Divider()
            }
            HStack {
                Text("Total").font(.system(size: 16, weight: .bold, design: .rounded))
                Spacer()
                if let m = result.macro {
                    Text("\(m.calories) kcal • P\(Int(m.protein)) C\(Int(m.carbs)) F\(Int(m.fat))")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.secondarySystemBackground)))
    }

    private var saveSection: some View {
        VStack(spacing: 12) {
            if let macro = result.macro {
                Button {
                    saveToNutritionLog(macro: macro)
                } label: {
                    Text("Save to Nutrition Log")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Text("No macros to save for this result.")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func saveToNutritionLog(macro: NutritionMacro) {
        // Convert ScanResult to FoodItem
        let foodItem = createFoodItemFromScanResult()
        
        // Create meal entry with portion multiplier (already applied to macro)
        let entry = MealEntry.fromScanResult(
            foodItem: foodItem,
            portionMultiplier: 1.0, // Portion already applied in ScanHomeView
            time: Date()
        )
        
        // Add to nutrition store
        nutritionStore.addEntry(entry)
        
        // Auto-open the diary after saving from Scan
        NotificationCenter.default.post(name: .nutritionOpenDiary, object: nil)
        
        // Success haptic
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Show toast
        savedToast = true
        
        TelemetryService.shared.track("nutrition_scan_saved", properties: [
            "source": result.scanSource,
            "kcal": macro.calories,
            "protein": macro.protein
        ])
        
        DebugLog.info("Saved scan result to nutrition log: \(titleText) - \(macro.calories) kcal")
    }
    
    private func createFoodItemFromScanResult() -> FoodItem {
        let macro = result.macro ?? NutritionMacro(calories: 0, protein: 0, carbs: 0, fat: 0)
        
        switch result {
        case .calorie(let product, _):
            return FoodItem(
                name: product.productName,
                brand: product.brand,
                barcode: product.barcode,
                per100g: NutritionPer100g(
                    kcal: macro.calories,
                    protein: macro.protein,
                    carbs: macro.carbs,
                    fat: macro.fat
                )
            )
            
        case .plateAI(let estimate):
            return FoodItem(
                name: "Plate Estimate",
                per100g: NutritionPer100g(
                    kcal: macro.calories,
                    protein: macro.protein,
                    carbs: macro.carbs,
                    fat: macro.fat
                )
            )
            
        case .ingredients(let product, _):
            // For ingredients-only scans, create a basic food item
            return FoodItem(
                name: product.productName,
                brand: product.brand,
                barcode: product.barcode,
                per100g: NutritionPer100g(kcal: 0, protein: 0, carbs: 0, fat: 0)
            )
        }
    }

    private func stat(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value).font(.system(size: 16, weight: .bold, design: .rounded))
            Text(title).font(.system(size: 12, weight: .regular, design: .rounded)).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Assess ingredients with user profile context (allergies, diet preferences)
    private func assessIngredientsWithProfile(_ ingredients: [IngredientAssessment], profile: UserProfile) -> [IngredientAssessment] {
        return ingredients.map { ingredient in
            var updatedIngredient = ingredient
            var newReasons = ingredient.reasons
            var newVerdict = ingredient.verdict
            
            // Check for allergies
            for allergy in profile.allergies {
                if ingredient.name.lowercased().contains(allergy.lowercased()) {
                    newReasons.append("⚠️ Contains \(allergy) (allergy)")
                    newVerdict = .avoid
                }
            }
            
            // Check dietary preferences
            switch profile.diet {
            case .plantBased:
                let animalProducts = ["milk", "egg", "butter", "cream", "cheese", "whey", "casein", "gelatin", "meat", "chicken", "beef", "pork", "fish"]
                for product in animalProducts {
                    if ingredient.name.lowercased().contains(product) {
                        newReasons.append("🌱 Animal-derived (\(profile.diet.rawValue) diet)")
                        if newVerdict == .good { newVerdict = .caution }
                    }
                }
            case .lowCarb:
                let highCarbIngredients = ["sugar", "corn syrup", "wheat", "flour", "starch", "maltodextrin"]
                for carb in highCarbIngredients {
                    if ingredient.name.lowercased().contains(carb) {
                        newReasons.append("🍞 High carb (\(profile.diet.rawValue) diet)")
                        if newVerdict == .good { newVerdict = .caution }
                    }
                }
            case .highProtein:
                // Positive reinforcement for protein sources
                let proteinSources = ["protein", "amino", "whey", "casein"]
                for protein in proteinSources {
                    if ingredient.name.lowercased().contains(protein) {
                        newReasons.append("💪 Protein source (\(profile.diet.rawValue) diet)")
                    }
                }
            default:
                break
            }
            
            // Check for general health concerns based on goal
            if profile.goal == .fatLoss || profile.goal == .longevity {
                let processedIngredients = ["artificial", "preservative", "color", "flavor", "high fructose", "trans fat"]
                for processed in processedIngredients {
                    if ingredient.name.lowercased().contains(processed) {
                        newReasons.append("🎯 Processed ingredient (\(profile.goal.rawValue) goal)")
                        if newVerdict == .good { newVerdict = .caution }
                    }
                }
            }
            
            updatedIngredient.reasons = newReasons
            updatedIngredient.verdict = newVerdict
            return updatedIngredient
        }
    }
    
    private func verdictBadge(_ v: Verdict) -> some View {
        let text: String
        let color: Color
        switch v {
        case .good: text = "GOOD"; color = .green
        case .caution: text = "CAUTION"; color = .orange
        case .avoid: text = "AVOID"; color = .red
        }
        return Text(text)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.15)))
            .foregroundStyle(color)
    }
}

// Lightweight toast for simulator
private struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                Text(message)
                    .padding(12)
                    .background(.thinMaterial, in: Capsule())
                    .transition(.opacity)
                    .onAppear { 
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { 
                            withAnimation { 
                                isPresented = false 
                            } 
                        } 
                    }
                    .padding(.bottom, 40)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
    }
}

private extension View {
    func toast(isPresented: Binding<Bool>, message: String) -> some View {
        modifier(ToastModifier(isPresented: isPresented, message: message))
    }
}