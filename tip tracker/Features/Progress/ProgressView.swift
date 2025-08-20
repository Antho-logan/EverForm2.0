import SwiftUI

struct ProgressViewScreen: View {
	var body: some View {
		Text("Progress")
			.font(.title)
			.onAppear { DebugLog.info("ProgressView onAppear") }
	}
}

