// TODO: Candidate for removal – appears unused in current EverForm flow.
import SwiftUI

// Charts framework is iOS 16+; we guard import for safety
#if canImport(Charts)
import Charts
#endif

struct ProgressDashboardView: View {
    @Environment(\.colorScheme) private var scheme
    @StateObject private var store = ProgressStore()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Title
                Text("Progress")
                    .font(.largeTitle.weight(.bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)

                // Range Picker
                rangePicker

                // Summary cards (latest values)
                summaryGrid

                // Charts per metric
                chartGrid
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Theme.Colors.efBackground.ignoresSafeArea())
    }

    private var rangePicker: some View {
        HStack(spacing: 10) {
            ForEach(ProgressRange.allCases) { r in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        store.setRange(r)
                    }
                } label: {
                    Text(r.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(store.range == r ? Color.accentColor.opacity(0.18) : Color.secondary.opacity(0.12))
                        .foregroundStyle(store.range == r ? Color.accentColor : .primary)
                        .clipShape(Capsule())
                }
                .accessibilityLabel("Range \(r.rawValue)")
            }
            Spacer(minLength: 0)
        }
        .padding(.top, 4)
    }

    private var summaryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(ProgressKind.allCases) { kind in
                let tuple = store.latestValue(for: kind)
                HStack(spacing: 12) {
                    Image(systemName: kind.sfSymbol)
                        .font(.title2)
                        .foregroundStyle(kind.color)
                        .frame(width: 28, height: 28)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(kind.title)
                            .font(.headline)
                        Text("\(format(tuple.value)) \(kind.unit)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 0)
                }
                .padding(14)
                .efCard()
            }
        }
    }

    @ViewBuilder
    private var chartGrid: some View {
        ForEach(ProgressKind.allCases) { kind in
            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label(kind.title, systemImage: kind.sfSymbol)
                            .font(.headline)
                            .labelStyle(.titleAndIcon)
                            .foregroundStyle(kind.color)
                        Spacer()
                        Text(store.range.rawValue)
                            .font(.caption).foregroundStyle(.secondary)
                    }

                    #if canImport(Charts)
                    if #available(iOS 16.0, *) {
                        Chart(store.series[kind] ?? []) {
                            LineMark(
                                x: .value("Date", $0.date),
                                y: .value("Value", $0.value)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(kind.color)
                            .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                            AreaMark(
                                x: .value("Date", $0.date),
                                y: .value("Value", $0.value)
                            )
                            .foregroundStyle(kind.color.opacity(0.18))
                        }
                        .chartXAxis {
                            AxisMarks(values: .automatic(desiredCount: 4))
                        }
                        .chartYAxis {
                            AxisMarks(position: .trailing)
                        }
                        .frame(height: 180)
                        .padding(.top, 6)
                    } else {
                        fallbackList(for: kind)
                    }
                    #else
                    fallbackList(for: kind)
                    #endif
                }
            }
            .groupBoxStyle(.automatic)
        }
    }

    @ViewBuilder
    private func fallbackList(for kind: ProgressKind) -> some View {
        // Fallback list
        VStack(alignment: .leading, spacing: 6) {
            ForEach(store.series[kind] ?? []) { p in
                HStack {
                    Text(p.date, style: .date)
                    Spacer()
                    Text(format(p.value) + " " + kind.unit)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Utils
    private func format(_ v: Double) -> String {
        if v >= 1000 && (v.truncatingRemainder(dividingBy: 1000) == 0) {
            return String(format: "%.0f", v)
        }
        if v >= 1000 { return String(format: "%.1f", v/1000) + "k" }
        if v.rounded() == v { return String(format: "%.0f", v) }
        return String(format: "%.1f", v)
    }
}
