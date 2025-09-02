import Foundation
import SwiftUI

// MARK: - Metric Kinds we chart
enum ProgressKind: String, CaseIterable, Identifiable {
    case training, nutrition, mobility, recovery, hydration
    var id: String { rawValue }

    var title: String {
        switch self {
        case .training:  return "Training"
        case .nutrition: return "Nutrition"
        case .mobility:  return "Mobility"
        case .recovery:  return "Recovery"
        case .hydration: return "Hydration"
        }
    }

    var unit: String {
        switch self {
        case .training:  return "min"
        case .nutrition: return "kcal"
        case .mobility:  return "min"
        case .recovery:  return "hrs"
        case .hydration: return "ml"
        }
    }

    // Tints roughly aligned with our app palette (Scan Food)
    var color: Color {
        switch self {
        case .training:  return Color.green                 // accent
        case .nutrition: return Color.orange
        case .mobility:  return Color.purple
        case .recovery:  return Color.blue
        case .hydration: return Color.cyan
        }
    }

    var sfSymbol: String {
        switch self {
        case .training:  return "dumbbell"
        case .nutrition: return "fork.knife"
        case .mobility:  return "figure.walk.motion"
        case .recovery:  return "powersleep"
        case .hydration: return "drop.fill"
        }
    }
}

// MARK: - Simple point model
struct ProgressPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

// MARK: - Range options
enum ProgressRange: String, CaseIterable, Identifiable {
    case day = "1D", week = "7D", month = "1M", quarter = "3M"
    var id: String { rawValue }
    var days: Int {
        switch self {
        case .day: return 1
        case .week: return 7
        case .month: return 30
        case .quarter: return 90
        }
    }
}

// MARK: - Store (UI-first; later wire real services)
final class ProgressStore: ObservableObject {
    @Published var range: ProgressRange = .week
    @Published var series: [ProgressKind: [ProgressPoint]] = [:]

    init(seed: Bool = true) {
        if seed { regenerate() }
    }

    func setRange(_ r: ProgressRange) {
        guard r != range else { return }
        range = r
        regenerate()
    }

    func regenerate(now: Date = Date()) {
        var out: [ProgressKind: [ProgressPoint]] = [:]
        for kind in ProgressKind.allCases {
            let n = max(range.days, 1)
            let points = (0..<n).map { i -> ProgressPoint in
                let d = Calendar.current.date(byAdding: .day, value: -((n-1) - i), to: now) ?? now
                let base: Double
                let jitter: ClosedRange<Double>
                switch kind {
                case .training:  base = 45;  jitter = -10...15      // minutes
                case .nutrition: base = 2200; jitter = -400...350   // kcal
                case .mobility:  base = 10;  jitter = -5...12       // minutes
                case .recovery:  base = 7.5; jitter = -1.2...1.2    // hours
                case .hydration: base = 1800; jitter = -500...600   // ml
                }
                return ProgressPoint(date: d, value: max(0, base + Double.random(in: jitter)))
            }
            out[kind] = points
        }
        series = out
    }

    // Helper for latest values (cards)
    func latestValue(for kind: ProgressKind) -> (value: Double, unit: String) {
        let v = series[kind]?.last?.value ?? 0
        return (v, kind.unit)
    }
}
