import Foundation

final class AIService {
    static let shared = AIService()

    struct CoachRequest: Encodable {
        let message: String
        let context: [String: String]?
    }

    func sendMessage(
        message: String,
        context: [String: String]? = nil
    ) async throws -> BackendCoachResponse {
        return try await BackendClient.shared.post("coach/message", body: CoachRequest(message: message, context: context))
    }
}
