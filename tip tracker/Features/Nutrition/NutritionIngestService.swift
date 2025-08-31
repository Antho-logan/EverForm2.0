//
// NutritionIngestService.swift
// EverForm Scanner V2
//
// Service for ingesting nutrition data from scans and manual entry.
// Assumptions: In-memory storage for now, TODO Core Data integration.
//

import Foundation

@Observable
class NutritionIngestService {
    static let shared = NutritionIngestService()
    
    private(set) var entries: [NutritionEntry] = []
    private(set) var isLoading = false
    
    private init() {
        // Load sample data for development
        loadSampleData()
    }
    
    // MARK: - Public API
    
    func ingestFromScan(_ scanResult: ScanResult) async throws {
        DebugLog.d("Ingesting scan result: \(scanResult.productName ?? "Unknown")")
        
        isLoading = true
        defer { isLoading = false }
        
        let entry: NutritionEntry
        
        switch scanResult {
        case .calorie(let product, let macro):
            entry = NutritionEntry(
                source: "scan",
                name: product.productName,
                calories: macro.calories,
                protein: macro.protein,
                carbs: macro.carbs,
                fat: macro.fat,
                barcode: product.barcode
            )
            
        case .ingredients(let product, let items):
            // For ingredient-only scans, create minimal entry with overall grade
            let overallGrade = calculateOverallGrade(from: items)
            entry = NutritionEntry(
                source: "scan",
                name: product.productName,
                calories: 0,
                protein: 0.0,
                carbs: 0.0,
                fat: 0.0,
                barcode: product.barcode,
                ingredientScore: overallGrade
            )
            
        case .plateAI(let estimate):
            entry = NutritionEntry(
                source: "plate_ai",
                name: "Estimated Meal",
                calories: estimate.total.calories,
                protein: estimate.total.protein,
                carbs: estimate.total.carbs,
                fat: estimate.total.fat
            )
        }
        
        // Add entry to storage
        await addEntry(entry)
        
        // Track telemetry
        TelemetryService.shared.track("nutrition_ingested_\(entry.source)")
        if let score = entry.ingredientScore {
            TelemetryService.shared.track("ingredient_score_\(score)")
        }
        
        DebugLog.d("Successfully ingested nutrition entry: \(entry.name)")
    }
    
    // MARK: - Helper Methods
    
    private func calculateOverallGrade(from items: [IngredientAssessment]) -> String {
        let verdictCounts = items.reduce(into: [Verdict: Int]()) { counts, item in
            counts[item.verdict, default: 0] += 1
        }
        
        if verdictCounts[.avoid, default: 0] > 0 {
            return "C"
        } else if verdictCounts[.caution, default: 0] > verdictCounts[.good, default: 0] {
            return "B"
        } else {
            return "A"
        }
    }
    
    func addManualEntry(_ entry: NutritionEntry) async {
        DebugLog.d("Adding manual nutrition entry: \(entry.name)")
        
        isLoading = true
        defer { isLoading = false }
        
        await addEntry(entry)
        TelemetryService.shared.track("nutrition_ingested_manual")
    }
    
    func updateEntry(_ entry: NutritionEntry) async {
        DebugLog.d("Updating nutrition entry: \(entry.id)")
        
        isLoading = true
        defer { isLoading = false }
        
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            await saveToStorage()
        }
    }
    
    func deleteEntry(_ entry: NutritionEntry) async {
        DebugLog.d("Deleting nutrition entry: \(entry.id)")
        
        isLoading = true
        defer { isLoading = false }
        
        entries.removeAll { $0.id == entry.id }
        await saveToStorage()
        TelemetryService.shared.track("nutrition_entry_deleted")
    }
    
    // MARK: - Data Access
    
    func getEntries(for date: Date) -> [NutritionEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func getEntriesForDateRange(_ startDate: Date, _ endDate: Date) -> [NutritionEntry] {
        return entries.filter { entry in
            entry.date >= startDate && entry.date <= endDate
        }
    }
    
    func getTotalCalories(for date: Date) -> Int {
        return getEntries(for: date).reduce(0) { $0 + $1.calories }
    }
    
    func getTotalMacros(for date: Date) -> (protein: Double, carbs: Double, fat: Double) {
        let dayEntries = getEntries(for: date)
        let protein = dayEntries.reduce(0.0) { $0 + $1.protein }
        let carbs = dayEntries.reduce(0.0) { $0 + $1.carbs }
        let fat = dayEntries.reduce(0.0) { $0 + $1.fat }
        return (protein, carbs, fat)
    }
    
    // MARK: - Private Methods
    
    private func addEntry(_ entry: NutritionEntry) async {
        entries.append(entry)
        entries.sort { $0.date > $1.date } // Most recent first
        await saveToStorage()
    }
    
    private func saveToStorage() async {
        // TODO: Implement Core Data or other persistent storage
        // For now, entries are only stored in memory
        DebugLog.d("Saving \(entries.count) nutrition entries to storage")
    }
    
    private func loadFromStorage() async {
        // TODO: Load from persistent storage
        DebugLog.d("Loading nutrition entries from storage")
    }
    
    private func loadSampleData() {
        // Add sample entries for development
        entries = NutritionEntry.sampleEntries
        DebugLog.d("Loaded \(entries.count) sample nutrition entries")
    }
}

// MARK: - Error Types

enum NutritionIngestError: LocalizedError {
    case noNutritionData
    case parsingFailed
    case invalidData
    case storageError
    
    var errorDescription: String? {
        switch self {
        case .noNutritionData:
            return "No nutrition data found for this product"
        case .parsingFailed:
            return "Failed to parse nutrition information"
        case .invalidData:
            return "Invalid nutrition data provided"
        case .storageError:
            return "Failed to save nutrition data"
        }
    }
}

// MARK: - Extensions

extension NutritionIngestService {
    // Convenience methods for common operations
    
    func getRecentEntries(limit: Int = 10) -> [NutritionEntry] {
        return Array(entries.prefix(limit))
    }
    
    func getEntriesBySource(_ source: String) -> [NutritionEntry] {
        return entries.filter { $0.source == source }
    }
    
    func getScannedEntries() -> [NutritionEntry] {
        return entries.filter { $0.isFromScan }
    }
    
    func getAverageCalories(days: Int = 7) -> Int {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: endDate) ?? endDate
        
        let relevantEntries = getEntriesForDateRange(startDate, endDate)
        guard !relevantEntries.isEmpty else { return 0 }
        
        let totalCalories = relevantEntries.reduce(0) { $0 + $1.calories }
        return totalCalories / days
    }
}
