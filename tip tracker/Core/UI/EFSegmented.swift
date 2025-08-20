import SwiftUI

struct EFSegmented<Segment: Hashable & CustomStringConvertible>: View {
	let segments: [Segment]
	@Binding var selection: Segment

	var body: some View {
		HStack(spacing: 6) {
			ForEach(segments, id: \.self) { seg in
				let isSel = seg == selection
				Text(seg.description)
					.font(.system(size: 14, weight: .semibold))
					.padding(.vertical, 8)
					.padding(.horizontal, 12)
					.background(isSel ? Theme.accent.opacity(0.15) : Theme.bgElevated)
					.foregroundColor(isSel ? Theme.accent : Theme.text)
					.cornerRadius(20)
					.onTapGesture { selection = seg }
			}
		}
		.padding(6)
		.background(Theme.bgElevated)
		.cornerRadius(22)
	}
}







