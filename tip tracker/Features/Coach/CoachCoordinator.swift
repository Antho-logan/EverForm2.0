import SwiftUI
import Foundation

final class CoachCoordinator: ObservableObject {
    static let shared = CoachCoordinator()
    
    @Published var pendingPrefill: [ChatMessage] = []
    
    private init() {}
    
    func prefill(_ topic: CoachTopic) {
        // Handle prefilling coach with topic
        print("Coach prefilled with: \(topic)")
        // Create a simple message for the topic
        let message = ChatMessage(
            role: .user,
            text: "Tell me about \(topic.displayName.lowercased())"
        )
        pendingPrefill = [message]
    }
    
    func prefillWithCustomPrompt(_ prompt: String, feature: String, autoSend: Bool = true) {
        // Handle prefilling coach with custom prompt
        print("Coach prefilled with custom prompt for \(feature): \(prompt)")
        let message = ChatMessage(
            role: .user,
            text: prompt
        )
        pendingPrefill = [message]
        self.autoSend = autoSend
        print("coach_deeplink(\(feature))")
    }
    
    var autoSend = false
    
    func setPrefill(_ messages: [ChatMessage]) {
        pendingPrefill = messages
    }
    
    func clearPrefill() {
        pendingPrefill.removeAll()
    }
    
    var hasPrefill: Bool {
        !pendingPrefill.isEmpty
    }
}