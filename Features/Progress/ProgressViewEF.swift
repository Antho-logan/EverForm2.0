import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct ProgressViewEF: View {
    @Environment(\.colorScheme) private var scheme
    @State private var range: RangeOpt = .d7

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Progress")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(EFTheme.text(scheme))
                    .frame(maxWidth: .infinity, alignment: .leading)

                RangePicker(selection: $range)

                // Summary cards
                LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    Summary("Training",  "51.0 min", .green,  "dumbbell.fill")
                    Summary("Nutrition", "2.1k kcal", .orange, "fork.knife")
                    Summary("Mobility",  "14.4 min", .purple, "figure.run")
                    Summary("Recovery",  "6.7 hrs", .blue,   "moon.fill")
                    Summary("Hydration", "1.7k ml",  .cyan,   "drop.fill")
                }

                ChartCard(title: "Training", tint: .green,  range: range)
                ChartCard(title: "Nutrition", tint: .orange, range: range)
                ChartCard(title: "Mobility", tint: .purple,  range: range)
                ChartCard(title: "Recovery", tint: .blue,    range: range)
                ChartCard(title: "Hydration", tint: .cyan,   range: range)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .background(EFTheme.background(scheme).ignoresSafeArea())
    }
}

private enum RangeOpt: String, CaseIterable { case d1="1D", d7="7D", m1="1M", m3="3M" }

private struct RangePicker: View {
    @Environment(\.colorScheme) private var scheme
    @Binding var selection: RangeOpt
    var body: some View {
        HStack(spacing: 8) {
            ForEach(RangeOpt.allCases, id: \.rawValue) { r in
                Text(r.rawValue)
                    .font(.subheadline.weight(selection == r ? .bold : .regular))
                    .foregroundStyle(selection == r ? EFTheme.text(scheme) : EFTheme.muted(scheme))
                    .padding(.vertical, 8).padding(.horizontal, 12)
                    .background(EFTheme.surface(scheme).opacity(selection == r ? 1 : 0.8))
                    .clipShape(Capsule())
                    .onTapGesture { selection = r }
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct Summary: View {
    @Environment(\.colorScheme) private var scheme
    let title: String, value: String, tint: Color, icon: String
    init(_ t: String, _ v: String, _ tint: Color, _ icon: String) {
        self.title = t; self.value = v; self.tint = tint; self.icon = icon
    }
    var body: some View {
        EFCard {
            HStack(spacing: 12) {
                Image(systemName: icon).foregroundStyle(tint).font(.system(size: 18, weight: .bold))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline).foregroundStyle(EFTheme.text(scheme))
                    Text(value).font(.subheadline).foregroundStyle(EFTheme.muted(scheme))
                }
                Spacer()
            }
        }
    }
}

private struct ChartCard: View {
    @Environment(\.colorScheme) private var scheme
    let title: String, tint: Color
    let range: RangeOpt
    
    // Animation state
    @State private var progress: CGFloat = 0
    @State private var drawingKey = UUID()

    var data: [Double] {
        switch range {
        case .d1: return [44, 52, 48, 50, 49, 55, 53]
        case .d7: return [38, 44, 41, 47, 43, 39, 51]
        case .m1: return (0..<30).map { _ in Double(Int.random(in: 20...60)) }
        case .m3: return (0..<90).map { _ in Double(Int.random(in: 20...60)) }
        }
    }

    var body: some View {
        EFCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(EFTheme.text(scheme))
                    Spacer()
                    if progress < 1 {
                        ProgressView()
                            .controlSize(.mini)
                            .tint(tint)
                    }
                }
                
                #if canImport(Charts)
                Chart {
                    ForEach(data.indices, id: \.self) { i in
                        // Area gradient for "authentic" professional look
                        AreaMark(
                            x: .value("x", i),
                            y: .value("y", data[i])
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [tint.opacity(0.2), tint.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        // Main line
                        LineMark(
                            x: .value("x", i),
                            y: .value("y", data[i])
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(tint)
                        .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                    }
                }
                .chartPlotStyle { plotContent in
                    plotContent
                        .mask(
                            GeometryReader { proxy in
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: proxy.size.width * progress)
                            }
                        )
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisGridLine().foregroundStyle(Color.secondary.opacity(0.1))
                        AxisTick().foregroundStyle(Color.secondary.opacity(0.2))
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine().foregroundStyle(Color.secondary.opacity(0.1))
                        AxisValueLabel()
                    }
                }
                .frame(height: 220)
                .id(drawingKey) // Force redraw on range change
                #else
                Text("Charts unavailable on this SDK").foregroundStyle(EFTheme.muted(scheme)).frame(height: 120)
                #endif
            }
        }
        .onChange(of: range) { _, _ in animateGraph() }
        .onAppear { animateGraph() }
    }
    
    private func animateGraph() {
        // Reset
        drawingKey = UUID()
        progress = 0
        
        // Animate
        withAnimation(.easeInOut(duration: 1.2)) {
            progress = 1.0
        }
    }
}
