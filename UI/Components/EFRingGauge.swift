import SwiftUI

public struct EFRingGauge: View {
    @Environment(\.colorScheme) private var scheme
    
    public var progress: Double   // 0.0 ... 1.0 (e.g., 0.74)
    public var score: Int
    public var rhr: Int?
    public var hrv: Int?
    public var title: String

    @State private var animated: CGFloat = 0

    public init(progress: Double,
                score: Int,
                rhr: Int? = nil,
                hrv: Int? = nil,
                title: String = "Readiness") {
        self.progress = progress
        self.score = score
        self.rhr = rhr
        self.hrv = hrv
        self.title = title
    }

    public var body: some View {
        let p = Theme.palette(scheme)
        
        ZStack {
            // Track
            Circle()
                .stroke(p.stroke,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .opacity(1)

            // Progress
            Circle()
                .trim(from: 0, to: animated)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            p.accent,
                            p.accent.opacity(0.85),
                            p.accent
                        ]),
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.snappy(duration: 0.7), value: animated)

            VStack(spacing: 2) {
                Text("\(score)")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(p.textPrimary)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                Text(title)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(p.textSecondary)
                    .lineLimit(1)
            }
        }
        .onAppear {
            animated = 0
            withAnimation(.snappy(duration: 0.7)) {
                animated = CGFloat(max(0, min(1, progress)))
            }
        }
        .onChange(of: progress) { _, newVal in
            withAnimation(.snappy(duration: 0.7)) {
                animated = CGFloat(max(0, min(1, newVal)))
            }
        }
        .accessibilityLabel(Text("\(title) \(score) percent. \(rhrAX). \(hrvAX)."))
    }

    private var rhrAX: String {
        if let r = rhr, r > 0 { return "RHR \(r)" }
        return ""
    }
    private var hrvAX: String {
        if let h = hrv, h > 0 { return "HRV \(h)" }
        return ""
    }

    struct StatPill: View {
        let label: String
        let value: String
        let scheme: ColorScheme
        
        var body: some View {
            let p = Theme.palette(scheme)
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(label)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(p.textSecondary)
                    .lineLimit(1)
                Text(value)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(p.textPrimary)
                    .lineLimit(1)
            }
        }
    }
}