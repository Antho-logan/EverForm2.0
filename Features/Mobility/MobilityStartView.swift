import SwiftUI

struct MobilityStartView: View {
    // MobilityHomeView uses the singleton MobilityStore.shared internally,
    // so we don't need to inject an environment object here.
    // This avoids the 'MobilityStore' must conform to 'Observable' error
    // because MobilityStore is an ObservableObject, not the new @Observable macro type.
    
    var body: some View {
        MobilityHomeView()
    }
}

