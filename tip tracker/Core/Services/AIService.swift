//
// AIService.swift
// EverForm
//
// Simplified AI service placeholder
//

import SwiftUI
import Foundation

@Observable
final class AIService {
    var messages: [String] = []
    var isProcessing: Bool = false
    
    // MARK: - Popular Questions
    static let popularQuestions = [
        "Summarize my day",
        "Explain training",
        "Adjust macros",
        "Fix pain",
        "Better sleep",
        "Is this safe?"
    ]
    
    // MARK: - Send Message
    @MainActor
    func send(_ text: String, topic: String? = nil, profileContext: String? = nil) async {
        guard !text.isEmpty else { return }
        
        isProcessing = true
        
        // Add user message
        messages.append("User: \(text)")
        
        // Simulate processing delay
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Add mock response
        let response = generateMockResponse(for: text)
        messages.append("Coach: \(response)")
        
        isProcessing = false
    }
    
    // MARK: - Clear Messages
    func clearMessages() {
        messages.removeAll()
    }
    
    // MARK: - Private Helpers
    private func generateMockResponse(for text: String) -> String {
        let responses = [
            "That's a great question! Based on your data, I'd recommend focusing on consistency.",
            "I understand your concern. Let me help you with that based on current best practices.",
            "Thanks for asking! Here's what I'd suggest based on your profile and goals.",
            "Good point! Research shows that this approach can be very effective.",
            "I'm here to help! Based on what you've shared, here's my recommendation."
        ]
        
        return responses.randomElement() ?? "Thanks for your question! I'm here to help."
    }
}