import Charts
import SwiftUI

struct ProgressViewScreen: View {
  @State private var range: RangeOption = .d7
  private let now = Date()

  @Environment(ThemeManager.self) private var themeManager

  var body: some View {
    EFScreenContainer {
      ScrollView {
        VStack(alignment: .leading, spacing: 16) {
          EFHeader(title: "Progress")

          VStack(alignment: .leading, spacing: 16) {
            // Range selector
            HStack(spacing: 10) {
              ForEach(RangeOption.allCases, id: \.self) { opt in
                Button {
                  range = opt
                } label: {
                  Text(opt.label)
                    .font(.callout.weight(.semibold))
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(
                      range == opt
                        ? DesignSystem.Colors.accent.opacity(0.2)
                        : DesignSystem.Colors.cardBackgroundSecondary
                    )
                    .foregroundStyle(range == opt ? DesignSystem.Colors.accent : .primary)
                    .clipShape(Capsule())
                }
              }
            }

            summaryRow

            MetricChart(
              title: "Training", icon: "dumbbell.fill", tint: EFColor.green,
              data: makeData(days: range.days, max: 60))
            MetricChart(
              title: "Nutrition", icon: "fork.knife", tint: EFColor.orange,
              data: makeData(days: range.days, max: 3000))
            MetricChart(
              title: "Mobility", icon: "figure.run", tint: EFColor.purple,
              data: makeData(days: range.days, max: 30))
            MetricChart(
              title: "Recovery", icon: "moon.fill", tint: EFColor.blue,
              data: makeData(days: range.days, max: 10))
            MetricChart(
              title: "Hydration", icon: "drop.fill", tint: EFColor.blue,
              data: makeData(days: range.days, max: 3000))
          }
          .padding(.horizontal, 16)
        }
        .padding(.bottom, 32)  // Standard padding, tab bar inset handles the rest
      }
    }
    // Background is handled by EFScreenContainer, but we ensure it matches the theme
    .background(themeManager.beigeBackground.ignoresSafeArea())
  }

  private var summaryRow: some View {
    // 2×2 grid for Training, Nutrition, Mobility, Recovery
    LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 12), count: 2), spacing: 12) {
      ProgressSummaryCard(icon: "dumbbell.fill", title: "Training", value: "51.0 min", tint: .green)
      ProgressSummaryCard(icon: "fork.knife", title: "Nutrition", value: "2.5k kcal", tint: .orange)
      ProgressSummaryCard(icon: "figure.run", title: "Mobility", value: "20.6 min", tint: .purple)
      ProgressSummaryCard(icon: "moon.fill", title: "Recovery", value: "7.6 hrs", tint: .blue)
    }
  }

  private func makeData(days: Int, max: Double) -> [MetricPoint] {
    (0..<days).map { i in
      let d = Calendar.current.date(byAdding: .day, value: -i, to: now)!
      return MetricPoint(date: d, value: Double.random(in: max * 0.2...max))
    }.reversed()
  }
}

private enum RangeOption: CaseIterable {
  case d1, d7, m1, m3
  var label: String {
    switch self {
    case .d1: return "1D"
    case .d7: return "7D"
    case .m1: return "1M"
    case .m3: return "3M"
    }
  }
  var days: Int {
    switch self {
    case .d1: return 1
    case .d7: return 7
    case .m1: return 30
    case .m3: return 90
    }
  }
}
private struct MetricPoint: Identifiable {
  let id = UUID()
  let date: Date
  let value: Double
}

private struct ProgressSummaryCard: View {
  let icon: String, title: String, value: String, tint: Color
  var body: some View {
    EFCard {
      HStack {
        Image(systemName: icon).foregroundStyle(tint)
        Text(title).font(.headline)
        Spacer()
        Text(value).foregroundStyle(.secondary)
      }
    }
  }
}

private struct MetricChart: View {
  let title: String, icon: String, tint: Color, data: [MetricPoint]
  var body: some View {
    EFCard {
      HStack(spacing: 8) {
        Image(systemName: icon).foregroundStyle(tint)
        Text(title).font(.headline).foregroundStyle(tint)
        Spacer()
        Text("\(data.count >= 60 ? "3M" : data.count >= 30 ? "1M" : data.count >= 7 ? "7D" : "1D")")
          .foregroundStyle(.secondary)
      }
      .padding(.bottom, 8)
      Chart(data) {
        LineMark(
          x: .value("Date", $0.date),
          y: .value("Value", $0.value)
        )
        .foregroundStyle(tint)
        .lineStyle(.init(lineWidth: 2))
        AreaMark(
          x: .value("Date", $0.date),
          y: .value("Value", $0.value)
        )
        .foregroundStyle(tint.opacity(0.18))
      }
      .frame(height: 200)
    }
  }
}
