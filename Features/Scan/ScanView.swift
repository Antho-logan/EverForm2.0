import SwiftUI
import PhotosUI

struct ScanView: View {
    @Environment(\.colorScheme) private var scheme
    @Environment(NutritionStore.self) private var nutritionStore
    
    // Shared view model for all scan modes
    @StateObject private var viewModel = ScanViewModel()
    
    // Current tab selection
    @State private var currentMode: ScanMode = .calorie
    @State private var selectedItem: PhotosPickerItem? = nil

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

                    // Action Card
                    ActionCard(
                        currentMode: currentMode,
                        isLoading: viewModel.isLoading(for: currentMode),
                        hasImage: viewModel.hasImage,
                        selectedItem: $selectedItem,
                        onGenerateMock: { viewModel.setMockResult(for: currentMode) },
                        onPhotoSelected: { item in processPhoto(item) }
                    )
                    .padding(.horizontal, 20)

                    // Results section based on current mode
                    ResultsSection(
                        currentMode: currentMode,
                        viewModel: viewModel,
                        scheme: scheme
                    )
                    .padding(.horizontal, 20)
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .onChange(of: currentMode) { _, newMode in
            // When switching tabs, ensure we have analysis for this mode
            viewModel.ensureAnalysis(for: newMode)
        }
        .onAppear {
            // Ensure analysis for current mode on appear
            viewModel.ensureAnalysis(for: currentMode)
        }
    }
    
    private var modeDescription: String {
        switch currentMode {
        case .calorie: return "Estimate calories and macros for a single plate or item."
        case .ingredients: return "Identify key ingredients from the photo."
        case .plateAI: return "Smart analysis of the meal, portion size, and overall quality."
        }
    }
    
    private func processPhoto(_ item: PhotosPickerItem) {
        Task {
            #if DEBUG
            print("📷 [ScanView] Processing photo for mode: \(currentMode)")
            #endif
            
            do {
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    #if DEBUG
                    print("❌ [ScanView] Could not load image data")
                    #endif
                    return
                }
                
                #if DEBUG
                print("📷 [ScanView] Image loaded: \(data.count / 1024)KB")
                #endif
                
                // Set the image and start analysis for current mode
                await MainActor.run {
                    viewModel.setImage(data, initialMode: currentMode)
                }
                
            } catch {
                #if DEBUG
                print("❌ [ScanView] Photo processing error: \(error)")
                #endif
            }
        }
    }
}

// MARK: - Action Card

private struct ActionCard: View {
    let currentMode: ScanMode
    let isLoading: Bool
    let hasImage: Bool
    @Binding var selectedItem: PhotosPickerItem?
    let onGenerateMock: () -> Void
    let onPhotoSelected: (PhotosPickerItem) -> Void
    
    @Environment(\.colorScheme) private var scheme
    
    var body: some View {
                    EFCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(modeTitle).font(.headline).foregroundStyle(EFTheme.text(scheme))
                Text(currentMode == .plateAI ? "Take a photo of your plate for AI-powered nutrition analysis" : "Scan barcode or nutrition label for accurate results")
                                .font(.subheadline).foregroundStyle(EFTheme.muted(scheme))
                            
                            Button("Generate Mock Result") {
                    onGenerateMock()
                            }
                            .frame(maxWidth: .infinity).padding(.vertical, 12)
                            .background(Color.green)
                            .foregroundStyle(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            
                            PhotosPicker(selection: $selectedItem, matching: .images) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .green))
                                .scaleEffect(0.8)
                            Text("Analyzing…")
                        } else {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text(hasImage ? "Import New Photo" : "Import Photo")
                        }
                    }
                                    .frame(maxWidth: .infinity).padding(.vertical, 12)
                                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.green))
                    .foregroundStyle(isLoading ? Color.gray : Color.green)
                            }
                .disabled(isLoading)
                            .onChange(of: selectedItem) { _, newItem in
                                if let newItem {
                        onPhotoSelected(newItem)
                                }
                            }
                
                // Show indicator if we have an image
                if hasImage {
                    HStack(spacing: 6) {
                        Image(systemName: "photo.fill")
                            .foregroundStyle(.green)
                        Text("Photo loaded • Switch tabs to see different analyses")
                            .font(.caption)
                            .foregroundStyle(EFTheme.muted(scheme))
                }
                    .padding(.top, 4)
                }
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
}

// MARK: - Results Section

private struct ResultsSection: View {
    let currentMode: ScanMode
    @ObservedObject var viewModel: ScanViewModel
    let scheme: ColorScheme
    
    var body: some View {
        if viewModel.isLoading(for: currentMode) {
            LoadingView(scheme: scheme)
        } else if let result = viewModel.result(for: currentMode) {
            ResultCard(result: result, mode: currentMode)
        } else if let error = viewModel.error(for: currentMode) {
            ErrorCard(error: error, scheme: scheme, onRetry: {
                Task { await viewModel.requestAnalysis(for: currentMode) }
            })
        } else {
            EmptyStateCard(scheme: scheme, hasImage: viewModel.hasImage)
        }
    }
}

// MARK: - Loading View

private struct LoadingView: View {
    let scheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Analyzing your food…")
                .font(.subheadline)
                .foregroundStyle(EFTheme.muted(scheme))
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Error Card

private struct ErrorCard: View {
    let error: String
    let scheme: ColorScheme
    let onRetry: () -> Void
    
    var body: some View {
        EFCard {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.orange)
                Text("Analysis Issue")
                    .font(.headline)
                    .foregroundStyle(EFTheme.text(scheme))
                Text(error)
                    .font(.subheadline)
                    .foregroundStyle(EFTheme.muted(scheme))
                    .multilineTextAlignment(.center)
                
                Button("Try Again") {
                    onRetry()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.blue)
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Empty State Card

private struct EmptyStateCard: View {
    let scheme: ColorScheme
    let hasImage: Bool
    
    var body: some View {
        EFCard {
            VStack(spacing: 12) {
                Image(systemName: "viewfinder").font(.largeTitle).foregroundStyle(EFTheme.muted(scheme))
                Text(hasImage ? "Analyzing..." : "Nothing scanned yet").font(.headline).foregroundStyle(EFTheme.text(scheme))
                Text(hasImage ? "Results will appear shortly" : "Import a photo or generate a mock result to see how it works")
                    .font(.subheadline).foregroundStyle(EFTheme.muted(scheme))
                    .multilineTextAlignment(.center)
            }.frame(maxWidth: .infinity)
                    }
                }
}

// MARK: - Segmented Tabs

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

// MARK: - Result Card (Unified for all modes)

private struct ResultCard: View {
    let result: BackendScanResponse
    let mode: ScanMode
    
    var body: some View {
        EFCard {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Color.blue)
                    Text(headerTitle)
                        .font(.headline)
                    Spacer()
                    
                    // Show health grade for plate mode
                    if mode == .plateAI, let grade = result.analysis.healthGrade {
                        QualityBadge(label: grade)
                    } else if let confidence = result.analysis.confidence {
                        Text("\(Int(confidence * 100))% confidence")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Show mock data banner when source is "mock"
                if result.isMockData {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.orange)
                        Text("Using estimated values (AI unavailable)")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Divider()
                
                // Mode-specific content
                switch mode {
                case .calorie:
                    CalorieContent(analysis: result.analysis)
                case .ingredients:
                    IngredientsContent(analysis: result.analysis)
                case .plateAI:
                    PlateAIContent(analysis: result.analysis)
                }

                // Meal saved indicator
                if let meal = result.meal {
                    Divider()
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text("Meal saved")
                            .font(.subheadline.weight(.semibold))
                    }
                    Text(meal.title).font(.body)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var headerTitle: String {
        switch mode {
        case .calorie: return "Calorie Analysis"
        case .ingredients: return "Ingredients Analysis"
        case .plateAI: return "Plate Analysis"
        }
    }
}

// MARK: - Calorie Content

private struct CalorieContent: View {
    let analysis: BackendScanAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 20) {
                MetricColumn(title: "Calories", value: "\(analysis.calories ?? 0)")
                MetricColumn(title: "Protein", value: "\(analysis.protein ?? 0)g")
                MetricColumn(title: "Carbs", value: "\(analysis.carbs ?? 0)g")
                MetricColumn(title: "Fat", value: "\(analysis.fat ?? 0)g")
                    }
            
            if let desc = analysis.description {
                Text(desc)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
            
            if let notes = analysis.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .padding(.top, 4)
            }
        }
    }
}

// MARK: - Ingredients Content

private struct IngredientsContent: View {
    let analysis: BackendScanAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let ingredients = analysis.ingredients {
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
            if let notes = analysis.notes {
                        Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
    }
}

// MARK: - Plate AI Content

private struct PlateAIContent: View {
    let analysis: BackendScanAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Dish name and description
            if let dishName = analysis.dishName {
                Text(dishName)
                    .font(.title3.bold())
            }
            
            if let desc = analysis.shortDescription ?? analysis.description {
                Text(desc)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
            
            // Meal type
            if let mealType = analysis.mealType {
                HStack {
                    Image(systemName: "clock")
                        .foregroundStyle(.secondary)
                    Text(mealType)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Calories estimate
            if let cals = analysis.caloriesEstimate {
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(cals)")
                            .font(.title2.bold())
                            .foregroundStyle(DesignSystem.Colors.accent)
                        Text("Estimated Calories")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
                    }
            
            // Macros
            if analysis.protein != nil || analysis.carbs != nil || analysis.fat != nil {
                VStack(spacing: 8) {
                    if let protein = analysis.protein {
                        MacroRow(name: "Protein", grams: Double(protein), rating: "medium", color: .blue)
                    }
                    if let carbs = analysis.carbs {
                        MacroRow(name: "Carbs", grams: Double(carbs), rating: "medium", color: .orange)
                    }
                    if let fat = analysis.fat {
                        MacroRow(name: "Fat", grams: Double(fat), rating: "medium", color: .yellow)
                    }
                    if let fiber = analysis.fiber {
                        MacroRow(name: "Fiber", grams: Double(fiber), rating: "medium", color: .green)
                    }
                }
            }
            
            // Warnings
            if let warnings = analysis.warnings, !warnings.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Warnings")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    ForEach(warnings, id: \.self) { warning in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                            Text(warning)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.top, 4)
                    }
            
            // Suggestions
            if let suggestions = analysis.suggestions, !suggestions.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Suggestions")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    ForEach(suggestions, id: \.self) { suggestion in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                            Text(suggestion)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
    }
}

// MARK: - Supporting Views

private struct QualityBadge: View {
    let label: String
    
    var body: some View {
        Text(label)
            .font(.headline.bold())
            .foregroundStyle(.white)
            .frame(width: 32, height: 32)
            .background(colorForLabel)
            .clipShape(Circle())
                    }
    
    private var colorForLabel: Color {
        switch label.uppercased() {
        case "A": return .green
        case "B": return .mint
        case "C": return .yellow
        case "D": return .orange
        case "E": return .red
        default: return .gray
        }
    }
}

private struct MacroRow: View {
    let name: String
    let grams: Double
    let rating: String
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(name)
                .font(.subheadline)
            Spacer()
            Text("\(Int(grams))g")
                .font(.subheadline.bold())
            Text(rating.capitalized)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.secondary.opacity(0.15))
                .clipShape(Capsule())
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
