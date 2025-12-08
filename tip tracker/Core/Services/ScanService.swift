import Foundation
import UIKit

// MARK: - Scan Errors

/// Errors that can occur during food scanning
enum ScanError: Error, LocalizedError {
    case networkError(underlying: Error)
    case decodingError(underlying: Error)
    case serverError(message: String)
    case imageProcessingError
    case noImageData
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .imageProcessingError:
            return "Could not process the image"
        case .noImageData:
            return "No image data available"
        }
    }
}

// MARK: - Scan Service

final class ScanService {
    static let shared = ScanService()
    
    /// Base URL for the public scan API (no auth required)
    private var publicBaseURL: URL {
        return BackendConfig.baseURL.appendingPathComponent("/api/scan")
    }
    
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()
    
    private init() {}
    
    // MARK: - Request Types
    
    struct ScanRequest: Encodable {
        let mode: String
        let imageBase64: String
    }
    
    // MARK: - Public Methods
    
    /// Analyzes an image for calorie/ingredients/plate modes using the public scan endpoint.
    /// This method NEVER crashes - it returns a fallback response on any error.
    func analyze(imageData: Data, mode: ScanMode) async throws -> BackendScanResponse {
        let base64 = imageData.base64EncodedString()
        
        // Map ScanMode to backend expected strings
        let backendMode: String
        switch mode {
        case .calorie: backendMode = "calories"
        case .ingredients: backendMode = "ingredients"
        case .plateAI: backendMode = "plate"
        }
        
        #if DEBUG
        print("📤 [ScanService] Starting \(backendMode) analysis, image size: \(imageData.count / 1024)KB")
        #endif
        
        let body = ScanRequest(mode: backendMode, imageBase64: base64)
        
        do {
            let response = try await postToPublicScan(body: body)
            
            #if DEBUG
            print("📥 [ScanService] Analysis complete: mode=\(response.analysis.mode) - calories: \(response.analysis.calories ?? 0)")
            #endif
            
            return response
        } catch {
            #if DEBUG
            print("❌ [ScanService] Analysis failed: \(error)")
            #endif
            
            // Return a fallback response instead of throwing
            return createFallbackResponse(mode: backendMode, error: error)
        }
    }
    
    /// Analyzes a plate image using the new Plate AI endpoint (multipart upload).
    /// This endpoint accepts multipart file upload and returns detailed nutrition analysis.
    func analyzePlate(image: UIImage) async throws -> BackendClient.PlateAnalysisResponse {
        return try await BackendClient.shared.analyzePlateImage(image)
    }
    
    // MARK: - Private Methods
    
    /// Posts to the public /api/scan/food endpoint (no auth required)
    private func postToPublicScan(body: ScanRequest) async throws -> BackendScanResponse {
        let url = publicBaseURL.appendingPathComponent("food")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)
        
        #if DEBUG
        print("🌐 [ScanService] POST \(url.absoluteString)")
        #endif
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let http = response as? HTTPURLResponse else {
                throw ScanError.networkError(underlying: NSError(domain: "ScanService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"]))
            }
            
            #if DEBUG
            print("🌐 [ScanService] Response status: \(http.statusCode)")
            if let json = String(data: data, encoding: .utf8) {
                print("   Raw: \(json.prefix(300))")
            }
            #endif
            
            // The backend always returns 200 with a valid response
            // Even errors come back as 200 with success: false
            guard http.statusCode == 200 else {
                throw ScanError.serverError(message: "Server returned status \(http.statusCode)")
            }
            
            // Decode the response
            do {
                // First try to decode as the full response
                let decoded = try decoder.decode(BackendScanResponse.self, from: data)
                return decoded
            } catch {
                // If that fails, try to decode as a simpler response and convert
                #if DEBUG
                print("⚠️ [ScanService] Standard decode failed, trying alternative...")
                #endif
                
                // Try alternative decoding
                if let simpleResponse = try? decoder.decode(SimpleScanResponse.self, from: data) {
                    return convertSimpleResponse(simpleResponse, mode: body.mode)
                }
                
                throw ScanError.decodingError(underlying: error)
            }
            
        } catch let error as ScanError {
            throw error
        } catch {
            throw ScanError.networkError(underlying: error)
        }
    }
    
    /// Creates a fallback response when the backend fails
    private func createFallbackResponse(mode: String, error: Error) -> BackendScanResponse {
        let analysis: BackendScanAnalysis
        
        switch mode {
        case "calories":
            analysis = BackendScanAnalysis(
                mode: mode,
                calories: 500,
                protein: 30,
                carbs: 45,
                fat: 20,
                confidence: 0.5,
                ingredients: nil,
                notes: "Could not connect to server. Showing estimated values.",
                description: nil,
                mealType: nil,
                caloriesEstimate: nil
            )
        case "ingredients":
            analysis = BackendScanAnalysis(
                mode: mode,
                calories: nil,
                protein: nil,
                carbs: nil,
                fat: nil,
                confidence: nil,
                ingredients: [
                    BackendScanIngredient(name: "Unknown ingredient 1", confidence: 0.5),
                    BackendScanIngredient(name: "Unknown ingredient 2", confidence: 0.5),
                ],
                notes: "Could not connect to server. Showing placeholder data.",
                description: nil,
                mealType: nil,
                caloriesEstimate: nil
            )
        case "plate":
            analysis = BackendScanAnalysis(
                mode: mode,
                calories: nil,
                protein: nil,
                carbs: nil,
                fat: nil,
                confidence: nil,
                ingredients: nil,
                notes: nil,
                description: "Could not analyze plate. Please try again.",
                mealType: "Unknown",
                caloriesEstimate: 500
            )
        default:
            analysis = BackendScanAnalysis(
                mode: mode,
                calories: 500,
                protein: 30,
                carbs: 45,
                fat: 20,
                confidence: 0.5,
                ingredients: nil,
                notes: "Showing estimated values.",
                description: nil,
                mealType: nil,
                caloriesEstimate: nil
            )
        }
        
        // Fallback responses are always mock data
        return BackendScanResponse(
            meal: nil,
            analysis: analysis,
            status: "fallback",
            success: false,
            source: "mock",
            summary: "Analysis failed: \(error.localizedDescription)"
        )
    }
    
    /// Converts a simple response to the full BackendScanResponse format
    private func convertSimpleResponse(_ simple: SimpleScanResponse, mode: String) -> BackendScanResponse {
        let analysis = BackendScanAnalysis(
            mode: mode,
            calories: simple.analysis.calories,
            protein: simple.analysis.protein,
            carbs: simple.analysis.carbs,
            fat: simple.analysis.fat,
            confidence: simple.analysis.confidence,
            ingredients: simple.analysis.ingredients?.map { BackendScanIngredient(name: $0.name, confidence: $0.confidence) },
            notes: simple.analysis.notes,
            description: simple.analysis.description,
            mealType: simple.analysis.mealType,
            caloriesEstimate: simple.analysis.caloriesEstimate,
            dishName: simple.analysis.dishName,
            shortDescription: simple.analysis.shortDescription,
            fiber: simple.analysis.fiber,
            healthGrade: simple.analysis.healthGrade,
            warnings: simple.analysis.warnings,
            suggestions: simple.analysis.suggestions
        )
        
        // Pass through source from backend response
        return BackendScanResponse(
            meal: simple.meal,
            analysis: analysis,
            status: simple.status,
            success: simple.success,
            source: simple.source,
            summary: simple.summary
        )
    }
}

// MARK: - Alternative Response Types

/// Simplified response structure for flexible decoding
private struct SimpleScanResponse: Decodable {
    let meal: BackendMeal?
    let analysis: SimpleScanAnalysis
    let status: String?
    let success: Bool?
    let source: String?   // "ai" | "mock"
    let summary: String?
}

private struct SimpleScanAnalysis: Decodable {
    let mode: String
    let calories: Int?
    let protein: Int?
    let carbs: Int?
    let fat: Int?
    let confidence: Double?
    let ingredients: [SimpleScanIngredient]?
    let notes: String?
    let description: String?
    let mealType: String?
    let caloriesEstimate: Int?
    // Extended Plate AI fields
    let dishName: String?
    let shortDescription: String?
    let fiber: Int?
    let healthGrade: String?
    let warnings: [String]?
    let suggestions: [String]?
}

private struct SimpleScanIngredient: Decodable {
    let name: String
    let confidence: Double
}
