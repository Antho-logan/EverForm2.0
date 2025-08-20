import SwiftUI
import Charts

struct CalorieTrendsView: View {
	let model: CalorieTrendsViewModel
	var body: some View {
		VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
			Theme.h1("Trends")
			Chart {
				ForEach(model.last30, id: \.date) { point in
					BarMark(x: .value("Date", point.date), y: .value("kcal", point.kcal))
				}
				RuleMark(y: .value("7d", model.avg7)).foregroundStyle(.orange).lineStyle(.init(lineWidth: 2)).annotation(position: .topTrailing) { Text("7d") }
				RuleMark(y: .value("30d", model.avg30)).foregroundStyle(.green).lineStyle(.init(lineWidth: 2)).annotation(position: .topTrailing) { Text("30d") }
			}
			.frame(height: 240)
		}
		.padding(.horizontal, Theme.Spacing.lg)
		.padding(.vertical, Theme.Spacing.xl)
		.onAppear { model.onAppear() }
	}
}







