import SwiftUI

struct SupplementsView: View {
	var body: some View {
		Text("Supplements")
			.font(.title)
			.onAppear { DebugLog.info("SupplementsView onAppear") }
	}
}

