import SwiftUI

struct SleepHistoryView: View {
	@State var model: SleepHistoryViewModel
	var body: some View {
		List {
			Section("Wind-Down") { ForEach(model.winddowns, id: \.self) { d in Text(d.formatted(date: .abbreviated, time: .shortened)) } }
			Section("Morning Light") { ForEach(model.mornings, id: \.self) { d in Text(d.formatted(date: .abbreviated, time: .shortened)) } }
			Section("Readiness Entries") {
				ForEach(model.readiness, id: \.id) { r in
					HStack { Text(r.date.formatted(date: .abbreviated, time: .omitted)); Spacer(); Text("RHR \(r.rhr) HRV \(r.hrv) Sleep \(r.sleepHours, specifier: "%.1f")h") }
				}
			}
		}
		.onAppear { model.load() }
	}
}







