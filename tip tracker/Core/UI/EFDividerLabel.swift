import SwiftUI

struct EFDividerLabel: View {
	let text: String
	var body: some View {
		HStack(spacing: Theme.Spacing.md) {
			Rectangle().fill(Theme.border).frame(height: 1)
			Text(text).font(.footnote).foregroundColor(Theme.textSecondary)
			Rectangle().fill(Theme.border).frame(height: 1)
		}
	}
}







