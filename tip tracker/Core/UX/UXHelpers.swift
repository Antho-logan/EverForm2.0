import SwiftUI
import UIKit
import OSLog

/// Shared UX helpers for animations, haptics, and error handling
enum UX {
    
    // MARK: - Animations
    enum Anim {
        static let fast = Animation.snappy(duration: 0.25) // Natural speed for onboarding transitions
        static let medium = Animation.snappy(duration: 0.28, extraBounce: 0.02)
        static let big = Animation.bouncy(duration: 0.38, extraBounce: 0.10)
        static let snappy = Animation.spring(duration: 0.35, bounce: 0.3)
        
        static func snappy(_ duration: Double = 0.4) -> Animation {
            .snappy(duration: duration, extraBounce: 0.1)
        }
        
        static func bouncy(_ duration: Double = 0.6) -> Animation {
            .bouncy(duration: duration, extraBounce: 0.2)
        }
        
        static func adaptive(_ base: Animation, reduceMotion: Bool) -> Animation {
            reduceMotion ? .easeInOut(duration: 0.2) : base
        }
    }
    
    // MARK: - Haptics
    enum Haptic {
        @MainActor
        static func light() {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
        
        @MainActor
        static func medium() {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        
        @MainActor
        static func success() {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
        
        @MainActor
        static func warning() {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
    }
    
    // MARK: - Transitions
    enum Transition {
        static let slideTrailing = AnyTransition.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
        )
        
        static let slideLeading = AnyTransition.asymmetric(
            insertion: .move(edge: .leading),
            removal: .move(edge: .trailing)
        )
        
        static let fade = AnyTransition.opacity
    }
    
    // MARK: - Accessibility
    enum A11y {
        static func announce(_ message: String) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIAccessibility.post(notification: .announcement, argument: message)
            }
        }
        
        static func focusChanged() {
            UIAccessibility.post(notification: .layoutChanged, argument: nil)
        }
    }
}



// MARK: - Logging
extension Logger {
    static let settings = Logger(subsystem: Bundle.main.bundleIdentifier ?? "EverForm", category: "Settings")
    static let onboarding = Logger(subsystem: Bundle.main.bundleIdentifier ?? "EverForm", category: "Onboarding")
    static let coach = Logger(subsystem: Bundle.main.bundleIdentifier ?? "EverForm", category: "Coach")
}
