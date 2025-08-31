import SwiftUI

struct TrendMiniDial: View {
    let icon: String
    let value: String
    let trendProgress: Double // 0.0 to 1.0 representing 7-day trend
    @Environment(\.colorScheme) private var colorScheme
    @State private var animatedProgress: Double = 0

    var body: some View {
        let palette = Theme.palette(colorScheme)

        VStack(spacing: 4) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(palette.stroke, lineWidth: 2)
                    .frame(width: 56, height: 56)

                // Trend arc (7-day progress)
                Circle()
                    .trim(from: 0, to: animatedProgress)
                    .stroke(
                        palette.accent.opacity(0.4),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .frame(width: 56, height: 56)
                    .rotationEffect(.degrees(-90))

                // Current progress arc (brighter)
                Circle()
                    .trim(from: max(0, animatedProgress - 0.15), to: animatedProgress)
                    .stroke(
                        palette.accent,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .frame(width: 56, height: 56)
                    .rotationEffect(.degrees(-90))

                // Center icon
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(palette.textPrimary)
            }
            .onAppear {
                withAnimation(.snappy(duration: 0.6)) {
                    animatedProgress = trendProgress
                }
            }

            // Value caption
            Text(value)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(palette.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("7-day trend for \(icon)")
        .accessibilityValue("\(value), \(Int(trendProgress * 100)) percent")
    }
}

#Preview {
    let palette = Theme.palette(.light)
    VStack(spacing: 20) {
        HStack(spacing: 12) {
            TrendMiniDial(icon: "figure.walk", value: "8.4K", trendProgress: 0.75)
            TrendMiniDial(icon: "flame.fill", value: "1.9K", trendProgress: 0.60)
            TrendMiniDial(icon: "bed.double.fill", value: "7h 30m", trendProgress: 0.85)
            TrendMiniDial(icon: "drop.fill", value: "0 ml", trendProgress: 0.40)
        }

        Text("Mini Trend Dials")
            .font(.caption)
            .foregroundStyle(palette.textSecondary)
    }
    .padding()
    .background(palette.background)
}
