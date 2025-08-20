import SwiftUI

struct EFTile: View {
	let systemImage: String
	let title: String
	var onTap: () -> Void

	var body: some View {
		Button(action: {
			DebugLog.info("Tile tap title=\(title)")
			onTap()
		}) {
			HStack(spacing: Theme.Spacing.md) {
				Image(systemName: systemImage).frame(width: 24)
				Text(title).font(Theme.Typography.body).foregroundColor(Theme.text)
				Spacer()
				Image(systemName: "chevron.right").foregroundColor(Theme.textSecondary)
			}
			.frame(minHeight: 56)
			.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
		.padding(.horizontal, Theme.Spacing.lg)
		.overlay(Divider().background(Theme.border), alignment: .bottom)
	}
}







