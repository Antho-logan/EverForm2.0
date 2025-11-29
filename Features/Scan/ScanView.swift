import SwiftUI
import PhotosUI

struct ScanView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(NutritionStore.self) private var nutritionStore
    @State private var currentMode: ScanMode = .calorie
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var scanResult: BackendScanResponse? = nil

    var body: some View {
        EFScreenContainer {
            ScrollView {
                VStack(spacing: 20) {
                    EFHeader(title: "Scan Food")

                    SegmentedTabs(currentMode: $currentMode)
                        .padding(.horizontal, 20)
                    
                    // Mode Description
                    Text(modeDescription)
                        .font(.caption)
                        .foregroundStyle(DesignSystem.Colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)

                    EFCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(modeTitle).font(.headline).foregroundStyle(EFTheme.text(scheme))
                            Text("Scan barcode or nutrition label for accurate results")
                                .font(.subheadline).foregroundStyle(EFTheme.muted(scheme))
                            
                            Button("Generate Mock Result") {
                                generateMock()
                            }
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                            .background(Color.green)
                            .foregroundStyle(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                Text("Import Photo")
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.green))
                                    .foregroundStyle(Color.green)
                            }
                            .onChange(of: selectedItem) { _, newItem in
                                if let newItem {
                                    processPhoto(newItem)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)

                    if isLoading {
                        ProgressView("Analyzing...")
                            .padding()
                    } else if let result = scanResult {
                        ResultCard(result: result)
                            .padding(.horizontal, 20)
                    } else if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(Color.red)
                            .padding()
                    } else {
                        EFCard {
                            VStack(spacing: 12) {
                                Image(systemName: "viewfinder").font(.largeTitle).foregroundStyle(EFTheme.muted(scheme))
                                Text("Nothing scanned yet").font(.headline).foregroundStyle(EFTheme.text(scheme))
                                Text("Try a mock result to see how it works").font(.subheadline).foregroundStyle(EFTheme.muted(scheme))
                            }.frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
    }
    
    private var modeTitle: String {
        switch currentMode {
        case .calorie: return "Calorie & Macros"
        case .ingredients: return "Ingredients Scan"
        case .plateAI: return "Plate Analysis"
        }
    }
    
    private var modeDescription: String {
        switch currentMode {
        case .calorie: return "Estimate calories and macros for a single plate or item."
        case .ingredients: return "Identify key ingredients from the photo."
        case .plateAI: return "Smart analysis of the meal, portion size, and overall quality."
        }
    }
    
    private func generateMock() {
        // Mock data based on mode
        isLoading = false
        errorMessage = nil
        
        switch currentMode {
        case .calorie:
            scanResult = BackendScanResponse(
                meal: nil,
                analysis: .init(
                    mode: "calories",
                    calories: 550,
                    protein: 32,
                    carbs: 45,
                    fat: 20,
                    confidence: 0.89,
                    ingredients: nil,
                    notes: nil,
                    description: nil,
                    mealType: nil,
                    caloriesEstimate: nil
                )
            )
        case .ingredients:
            scanResult = BackendScanResponse(
                meal: nil,
                analysis: .init(
                    mode: "ingredients",
                    calories: nil,
                    protein: nil,
                    carbs: nil,
                    fat: nil,
                    confidence: nil,
                    ingredients: [
                        .init(name: "Grilled Chicken", confidence: 0.95),
                        .init(name: "Quinoa", confidence: 0.90),
                        .init(name: "Broccoli", confidence: 0.85)
                    ],
                    notes: "Looks like a healthy balanced meal.",
                    description: nil,
                    mealType: nil,
                    caloriesEstimate: nil
                )
            )
        case .plateAI:
            scanResult = BackendScanResponse(
                meal: nil,
                analysis: .init(
                    mode: "plate",
                    calories: nil,
                    protein: nil,
                    carbs: nil,
                    fat: nil,
                    confidence: nil,
                    ingredients: nil,
                    notes: nil,
                    description: "A balanced plate with lean protein and vegetables.",
                    mealType: "Lunch",
                    caloriesEstimate: 600
                )
            )
        }
    }
    
    private func processPhoto(_ item: PhotosPickerItem) {
        Task {
            isLoading = true
            errorMessage = nil
            scanResult = nil
            
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    let result = try await ScanService.shared.analyze(imageData: data, mode: currentMode)
                    await MainActor.run {
                        scanResult = result
                        isLoading = false
                        if let meal = result.meal {
                            let entry = MealEntry.quickAdd(
                                kcal: meal.kcal ?? 0,
                                protein: meal.protein_g ?? 0,
                                carbs: meal.carbs_g ?? 0,
                                fat: meal.fat_g ?? 0,
                                time: meal.logged_at
                            )
                            nutritionStore.addEntry(entry)
                        }
                    }
                } else {
                    await MainActor.run {
                        errorMessage = "Could not load image data."
                        isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Couldn't analyze this photo, please try again."
                    isLoading = false
                }
            }
        }
    }
}

private struct SegmentedTabs: View {
    @Environment(\.colorScheme) private var scheme
    @Binding var currentMode: ScanMode
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(ScanMode.allCases, id: \.self) { mode in
                Text(title(for: mode))
                    .font(.subheadline.weight(currentMode == mode ? .bold : .regular))
                    .foregroundStyle(currentMode == mode ? EFTheme.text(scheme) : EFTheme.muted(scheme))
                    .padding(.vertical, 8).padding(.horizontal, 14)
                    .background(EFTheme.surface(scheme).opacity(currentMode == mode ? 1 : 0.7))
                    .clipShape(Capsule())
                    .onTapGesture { currentMode = mode }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func title(for mode: ScanMode) -> String {
        switch mode {
        case .calorie: return "Calorie"
        case .ingredients: return "Ingredients"
        case .plateAI: return "Plate AI"
        }
    }
}

private struct ResultCard: View {
    let result: BackendScanResponse
    
    var body: some View {
        EFCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Color.blue)
                    Text("Analysis Result")
                        .font(.headline)
                    Spacer()
                    if let confidence = result.analysis.confidence {
                        Text("\(Int(confidence * 100))% confidence")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Divider()
                
                if result.analysis.mode == "calories" {
                    HStack(spacing: 20) {
                        MetricColumn(title: "Calories", value: "\(result.analysis.calories ?? 0)")
                        MetricColumn(title: "Protein", value: "\(result.analysis.protein ?? 0)g")
                        MetricColumn(title: "Carbs", value: "\(result.analysis.carbs ?? 0)g")
                        MetricColumn(title: "Fat", value: "\(result.analysis.fat ?? 0)g")
                    }
                } else if result.analysis.mode == "ingredients" {
                    if let ingredients = result.analysis.ingredients {
                        ForEach(ingredients, id: \.name) { item in
                            HStack {
                                Text(item.name)
                                Spacer()
                                Text("\(Int(item.confidence * 100))%")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    if let notes = result.analysis.notes {
                        Text(notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                } else if result.analysis.mode == "plate" {
                    if let type = result.analysis.mealType {
                        Text("Meal Type: \(type)").font(.subheadline).bold()
                    }
                    if let desc = result.analysis.description {
                        Text(desc).font(.body)
                    }
                    if let cals = result.analysis.caloriesEstimate {
                        Text("Est. Calories: \(cals)").font(.subheadline).foregroundStyle(.secondary)
                    }
                }

                if let meal = result.meal {
                    Divider()
                    Text("Meal saved").font(.subheadline.weight(.semibold))
                    Text(meal.title).font(.body)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct MetricColumn: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.headline)
                .foregroundStyle(DesignSystem.Colors.accent)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
