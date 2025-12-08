import Foundation
import SwiftUI

/// Shared view model for the Scan feature.
/// Stores the current image and results for all three modes (Calorie, Ingredients, Plate AI).
/// Allows users to import a photo once and view different analyses without re-importing.
@MainActor
final class ScanViewModel: ObservableObject {
    
    // MARK: - Published State
    
    /// The current image data (base64-ready)
    @Published var currentImageData: Data? = nil
    
    /// Results for each mode (nil = not yet analyzed)
    @Published var calorieResult: BackendScanResponse? = nil
    @Published var ingredientsResult: BackendScanResponse? = nil
    @Published var plateResult: BackendScanResponse? = nil
    
    /// Loading state per mode
    @Published var isLoadingCalorie: Bool = false
    @Published var isLoadingIngredients: Bool = false
    @Published var isLoadingPlate: Bool = false
    
    /// Error messages per mode
    @Published var calorieError: String? = nil
    @Published var ingredientsError: String? = nil
    @Published var plateError: String? = nil
    
    // MARK: - Computed Properties
    
    /// Returns true if any mode is currently loading
    var isLoading: Bool {
        isLoadingCalorie || isLoadingIngredients || isLoadingPlate
    }
    
    /// Returns true if we have an image to analyze
    var hasImage: Bool {
        currentImageData != nil
    }
    
    // MARK: - Public Methods
    
    /// Sets a new image and clears all previous results.
    /// Automatically starts analysis for the specified initial mode.
    func setImage(_ data: Data, initialMode: ScanMode) {
        // Clear all previous state
        currentImageData = data
        calorieResult = nil
        ingredientsResult = nil
        plateResult = nil
        calorieError = nil
        ingredientsError = nil
        plateError = nil
        
        #if DEBUG
        print("📷 [ScanViewModel] New image set (\(data.count / 1024)KB), starting \(initialMode) analysis")
        #endif
        
        // Start analysis for the initial mode
        Task {
            await requestAnalysis(for: initialMode)
        }
    }
    
    /// Clears all state (image and results)
    func clearAll() {
        currentImageData = nil
        calorieResult = nil
        ingredientsResult = nil
        plateResult = nil
        calorieError = nil
        ingredientsError = nil
        plateError = nil
    }
    
    /// Ensures analysis exists for the given mode.
    /// If the mode doesn't have a result yet and we have an image, starts the analysis.
    func ensureAnalysis(for mode: ScanMode) {
        guard hasImage else { return }
        
        switch mode {
        case .calorie:
            if calorieResult == nil && !isLoadingCalorie {
                Task { await requestAnalysis(for: .calorie) }
            }
        case .ingredients:
            if ingredientsResult == nil && !isLoadingIngredients {
                Task { await requestAnalysis(for: .ingredients) }
            }
        case .plateAI:
            if plateResult == nil && !isLoadingPlate {
                Task { await requestAnalysis(for: .plateAI) }
            }
        }
    }
    
    /// Requests analysis for the specified mode using the current image.
    func requestAnalysis(for mode: ScanMode) async {
        guard let imageData = currentImageData else {
            #if DEBUG
            print("⚠️ [ScanViewModel] No image data for \(mode) analysis")
            #endif
            return
        }
        
        // Set loading state
        setLoading(true, for: mode)
        setError(nil, for: mode)
        
        #if DEBUG
        print("🔄 [ScanViewModel] Starting \(mode) analysis...")
        #endif
        
        do {
            let result = try await ScanService.shared.analyze(imageData: imageData, mode: mode)
            
            // Store the result
            setResult(result, for: mode)
            
            #if DEBUG
            print("✅ [ScanViewModel] \(mode) analysis complete: source=\(result.source ?? "unknown")")
            #endif
            
        } catch {
            #if DEBUG
            print("❌ [ScanViewModel] \(mode) analysis failed: \(error)")
            #endif
            
            setError(error.localizedDescription, for: mode)
        }
        
        setLoading(false, for: mode)
    }
    
    /// Sets a mock result for the specified mode (for demo purposes).
    /// Optionally clears the current image.
    func setMockResult(for mode: ScanMode, clearImage: Bool = false) {
        if clearImage {
            currentImageData = nil
        }
        
        switch mode {
        case .calorie:
            calorieResult = BackendScanResponse(
                meal: nil,
                analysis: .init(
                    mode: "calories",
                    calories: 550,
                    protein: 32,
                    carbs: 45,
                    fat: 20,
                    confidence: 0.89
                ),
                status: "ok",
                success: true,
                source: "mock",
                summary: "Mock calorie analysis"
            )
            calorieError = nil
            
        case .ingredients:
            ingredientsResult = BackendScanResponse(
                meal: nil,
                analysis: .init(
                    mode: "ingredients",
                    ingredients: [
                        .init(name: "Grilled Chicken", confidence: 0.95),
                        .init(name: "Quinoa", confidence: 0.90),
                        .init(name: "Broccoli", confidence: 0.85)
                    ],
                    notes: "Looks like a healthy balanced meal."
                ),
                status: "ok",
                success: true,
                source: "mock",
                summary: "Mock ingredients analysis"
            )
            ingredientsError = nil
            
        case .plateAI:
            plateResult = BackendScanResponse(
                meal: nil,
                analysis: .init(
                    mode: "plate",
                    protein: 40,
                    carbs: 55,
                    fat: 18,
                    description: "Grilled chicken with rice and salad.",
                    mealType: "Lunch",
                    caloriesEstimate: 620,
                    dishName: "Grilled Chicken Plate",
                    shortDescription: "A balanced meal with protein, carbs, and vegetables.",
                    fiber: 7,
                    healthGrade: "B",
                    warnings: ["Sodium may be high if seasoned heavily"],
                    suggestions: ["Add more leafy greens to boost volume and micronutrients"]
                ),
                status: "ok",
                success: true,
                source: "mock",
                summary: "Mock plate analysis"
            )
            plateError = nil
        }
    }
    
    // MARK: - Result Accessors
    
    /// Returns the result for the specified mode
    func result(for mode: ScanMode) -> BackendScanResponse? {
        switch mode {
        case .calorie: return calorieResult
        case .ingredients: return ingredientsResult
        case .plateAI: return plateResult
        }
    }
    
    /// Returns the error for the specified mode
    func error(for mode: ScanMode) -> String? {
        switch mode {
        case .calorie: return calorieError
        case .ingredients: return ingredientsError
        case .plateAI: return plateError
        }
    }
    
    /// Returns the loading state for the specified mode
    func isLoading(for mode: ScanMode) -> Bool {
        switch mode {
        case .calorie: return isLoadingCalorie
        case .ingredients: return isLoadingIngredients
        case .plateAI: return isLoadingPlate
        }
    }
    
    // MARK: - Private Helpers
    
    private func setLoading(_ loading: Bool, for mode: ScanMode) {
        switch mode {
        case .calorie: isLoadingCalorie = loading
        case .ingredients: isLoadingIngredients = loading
        case .plateAI: isLoadingPlate = loading
        }
    }
    
    private func setResult(_ result: BackendScanResponse, for mode: ScanMode) {
        switch mode {
        case .calorie: calorieResult = result
        case .ingredients: ingredientsResult = result
        case .plateAI: plateResult = result
        }
    }
    
    private func setError(_ error: String?, for mode: ScanMode) {
        switch mode {
        case .calorie: calorieError = error
        case .ingredients: ingredientsError = error
        case .plateAI: plateError = error
        }
    }
}

