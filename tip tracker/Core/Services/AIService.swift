import Foundation

final class AIService {
    static let shared = AIService()

    // MARK: - Request Types
    
    /// Legacy single-message request (authenticated endpoint)
    struct CoachRequest: Encodable {
        let message: String
        let context: [String: String]?
    }

    /// Chat message for conversation history
    struct ChatMessage: Codable {
        let role: String  // "user" | "assistant" | "system"
        let content: String
        
        static func user(_ content: String) -> ChatMessage {
            ChatMessage(role: "user", content: content)
        }
        
        static func assistant(_ content: String) -> ChatMessage {
            ChatMessage(role: "assistant", content: content)
        }
        
        static func system(_ content: String) -> ChatMessage {
            ChatMessage(role: "system", content: content)
        }
    }
    
    /// Multi-message chat request (public endpoint)
    struct ChatRequest: Encodable {
        let messages: [ChatMessage]
    }
    
    // MARK: - Response Types
    
    struct ChatResponse: Decodable {
        let reply: String
        let usage: TokenUsage?
    }
    
    struct TokenUsage: Decodable {
        let prompt_tokens: Int
        let completion_tokens: Int
        let total_tokens: Int
    }
    
    // MARK: - Public API
    
    /// Send a single message (legacy, uses authenticated endpoint)
    func sendMessage(
        message: String,
        context: [String: String]? = nil
    ) async throws -> BackendCoachResponse {
        return try await BackendClient.shared.post("coach/message", body: CoachRequest(message: message, context: context))
    }
    
    /// Send full conversation history (uses public endpoint for context-aware replies)
    func sendChat(messages: [ChatMessage]) async throws -> ChatResponse {
        let request = ChatRequest(messages: messages)
        return try await postToPublicCoach(body: request)
    }
    
    // MARK: - Private Helpers
    
    /// Post to the public coach endpoint (no auth required)
    private func postToPublicCoach<T: Encodable>(body: T) async throws -> ChatResponse {
        #if targetEnvironment(simulator)
        let baseURL = URL(string: "http://localhost:4000")!
        #else
        // Use your Mac's local IP for device testing
        let baseURL = URL(string: "http://192.168.1.100:4000")!
        #endif
        
        let url = baseURL.appendingPathComponent("api/coach/chat")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = 30
        
        #if DEBUG
        print("📤 [AIService] Sending chat to \(url.absoluteString)")
        #endif
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }
        
        #if DEBUG
        print("📥 [AIService] Response status: \(httpResponse.statusCode)")
        #endif
        
        guard httpResponse.statusCode == 200 else {
            throw AIServiceError.serverError(statusCode: httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(ChatResponse.self, from: data)
        } catch {
            #if DEBUG
            if let rawString = String(data: data, encoding: .utf8) {
                print("❌ [AIService] Failed to decode: \(rawString.prefix(500))")
            }
            #endif
            throw AIServiceError.decodingError(underlying: error)
        }
    }
}

// MARK: - Errors

enum AIServiceError: Error, LocalizedError {
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError(underlying: Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let code):
            return "Server error (status \(code))"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}
