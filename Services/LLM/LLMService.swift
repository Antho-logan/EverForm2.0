import Foundation

protocol LLMService {
    func streamReply(for message: ChatMessage) -> AsyncStream<String>
}

class MockLLMService: LLMService {
    func streamReply(for message: ChatMessage) -> AsyncStream<String> {
        AsyncStream { continuation in
            Task {
                let response = "Thanks for your message: \"\(message.text)\". This is a mock response that demonstrates streaming. I can help you with fitness, nutrition, and wellness questions!"
                let words = response.split(separator: " ")
                
                for word in words {
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second delay
                    continuation.yield(String(word) + " ")
                }
                
                continuation.finish()
            }
        }
    }
}


