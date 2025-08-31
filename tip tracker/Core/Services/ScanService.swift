import Foundation

protocol ScanServiceProtocol {
    func scanMock(mode: ScanMode) async -> ScanResult
}

/// Simulator-safe mock. Replace later with real camera/OCR/LLM.
final class ScanService: ScanServiceProtocol {
    func scanMock(mode: ScanMode) async -> ScanResult {
        switch mode {
        case .calorie:
            return .calorie(
                product: ProductInfo(productName: "Greek Yogurt", brand: "EverForm", barcode: "123456"),
                macro: NutritionMacro(calories: 150, protein: 15, carbs: 10, fat: 4)
            )
        case .ingredients:
            return .ingredients(
                product: ProductInfo(productName: "Protein Bar", brand: "EverForm", barcode: "789012"),
                items: [
                    IngredientAssessment(name: "Whey protein", verdict: .good, reasons: ["Complete amino acid profile"]),
                    IngredientAssessment(name: "Glucose syrup", verdict: .caution, reasons: ["High glycemic impact"]),
                    IngredientAssessment(name: "Hydrogenated oil", verdict: .avoid, reasons: ["Trans fats"])
                ]
            )
        case .plateAI:
            let items: [PlateFood] = [
                .init(name: "Chicken breast", grams: 150, macro: .init(calories: 248, protein: 46, carbs: 0, fat: 6)),
                .init(name: "Rice (cooked)", grams: 200, macro: .init(calories: 260, protein: 5, carbs: 56, fat: 1)),
                .init(name: "Broccoli", grams: 100, macro: .init(calories: 35, protein: 3, carbs: 7, fat: 0))
            ]
            let total = items.reduce(NutritionMacro(calories: 0, protein: 0, carbs: 0, fat: 0)) { acc, f in
                .init(calories: acc.calories + f.macro.calories,
                      protein: acc.protein + f.macro.protein,
                      carbs: acc.carbs + f.macro.carbs,
                      fat: acc.fat + f.macro.fat)
            }
            return .plateAI(estimate: PlateEstimate(items: items, total: total))
        }
    }
}

