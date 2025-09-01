// Add a Notification.Name and observer that switches to the Coach tab
import SwiftUI
import Combine

extension Notification.Name {
    static let switchToCoachTab = Notification.Name("SwitchToCoachTab")
}

struct RootTabView: View {
    @State private var selection: Int = 0 // 0:Overview, 1:Coach, 2:Scan, 3:More
    var body: some View {
        TabView(selection: $selection) {
            OverviewView().tag(0)
            CoachView().tag(1)
            ScanView().tag(2)
            MoreView().tag(3)
        }
        .onReceive(NotificationCenter.default.publisher(for: .switchToCoachTab)) { _ in
            selection = 1
        }
    }
}
