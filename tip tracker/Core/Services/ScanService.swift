import Foundation

final class ScanService {
    static let shared = ScanService()

    struct ScanRequest: Encodable {
        let mode: String
        let imageBase64: String
    }

    func analyze(imageData: Data, mode: ScanMode) async throws -> BackendScanResponse {
        let base64 = imageData.base64EncodedString()
        
        // Map ScanMode to backend expected strings
        let backendMode: String
        switch mode {
        case .calorie: backendMode = "calories"
        case .ingredients: backendMode = "ingredients"
        case .plateAI: backendMode = "plate"
        }
        
        let body = ScanRequest(mode: backendMode, imageBase64: base64)
        return try await BackendClient.shared.post("scan/meal", body: body)
    }
}
