import SwiftUI

// If your global route enum exists, extend it. This small file is safe to add even if unused.
enum EFProgressRoute {
    static let notification = Notification.Name("efRouteProgress")
}

// Helper to open programmatically from anywhere (mirrors your EFRouter style without touching it)
struct ProgressRouter {
    static func open() {
        NotificationCenter.default.post(name: EFProgressRoute.notification, object: nil)
    }
}
