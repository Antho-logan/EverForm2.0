//
//  HRVDashboardViewModel.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

// TODO: Candidate for removal – appears unused in current EverForm flow.
import Foundation
import SwiftUI

@MainActor
class HRVDashboardViewModel: ObservableObject {

  // MARK: - State
  @Published var selectedTimeRange: HRVTimeRange = .week
  @Published var selectedMetric: HRVMetricType = .rmssd
  @Published var isSessionCompletedToday: Bool = false
  @Published var showingEducation: Bool = false

  // MARK: - Data
  @Published var trendData: [Double] = []
  @Published var subjectiveLogs: [SubjectiveLog] = []

  // MARK: - Computed
  var currentMetricValue: String {
    guard let last = trendData.last else { return "--" }
    return String(format: "%.0f", last)
  }

  var currentMetricUnit: String {
    selectedMetric.unit
  }

  var trendDescription: String {
    // Simple mock logic
    guard trendData.count >= 2 else { return "Stable" }
    let last = trendData.last!
    let prev = trendData[trendData.count - 2]
    if last > prev { return "Trending Up" }
    if last < prev { return "Trending Down" }
    return "Stable"
  }

  var trendIcon: String {
    guard trendData.count >= 2 else { return "minus" }
    let last = trendData.last!
    let prev = trendData[trendData.count - 2]
    if last > prev { return "arrow.up.right" }
    if last < prev { return "arrow.down.right" }
    return "minus"
  }

  var trendColor: Color {
    guard trendData.count >= 2 else { return .gray }
    let last = trendData.last!
    let prev = trendData[trendData.count - 2]

    // Context dependent: Higher HR is usually "bad" (red), Higher HRV is "good" (green)
    let isHigherBetter = selectedMetric != .heartRate

    if last > prev { return isHigherBetter ? .green : .red }
    if last < prev { return isHigherBetter ? .red : .green }
    return .gray
  }

  // MARK: - Protocols
  let protocols: [BreathingProtocol] = [
    BreathingProtocol(
      name: "Resonance", description: "6 breaths per minute to maximize HRV.", durationMinutes: 10,
      targetTag: "Balance ANS", color: .purple),
    BreathingProtocol(
      name: "Deep Calm", description: "Slow exhalations to activate parasympathetic response.",
      durationMinutes: 15, targetTag: "Reduce Stress", color: .blue),
    BreathingProtocol(
      name: "Focus", description: "Box breathing for mental clarity.", durationMinutes: 5,
      targetTag: "Alertness", color: .orange),
    BreathingProtocol(
      name: "Awaken", description: "Faster rhythm to boost energy.", durationMinutes: 3,
      targetTag: "Energy", color: .yellow),
    BreathingProtocol(
      name: "Post-Workout", description: "Shift from sympathetic to recovery state.",
      durationMinutes: 8, targetTag: "Recovery", color: .green),
  ]

  let quickActions: [HRVQuickAction] = [
    HRVQuickAction(title: "Rest Day", icon: "bed.double.fill"),
    HRVQuickAction(title: "Mobility", icon: "figure.flexibility"),
    HRVQuickAction(title: "Massage", icon: "hand.raised.fill"),
    HRVQuickAction(title: "Sauna", icon: "thermometer.sun.fill"),
    HRVQuickAction(title: "Cold Plunge", icon: "snowflake"),
    HRVQuickAction(title: "Breathwork", icon: "lungs.fill"),
  ]

  // MARK: - Init
  init() {
    generateMockData()
  }

  // MARK: - Methods

  func generateMockData() {
    // Generate 14 days of data
    var data: [Double] = []

    // Base values and ranges for different metrics
    let (base, variance): (Double, Double) = {
      switch selectedMetric {
      case .heartRate: return (65, 5)  // 60-70 bpm
      case .rmssd: return (45, 15)  // 30-60 ms
      case .lnRmssd: return (3.8, 0.3)  // 3.5-4.1
      case .sdnn: return (50, 10)  // 40-60 ms
      case .pnn50: return (20, 10)  // 10-30 %
      case .totalPower: return (1500, 500)  // 1000-2000 ms^2
      case .lf: return (800, 200)  // 600-1000 ms^2
      case .hf: return (600, 200)  // 400-800 ms^2
      case .lfHf: return (1.5, 0.5)  // 1.0-2.0 ratio
      }
    }()

    for i in 0..<14 {
      let noise = Double.random(in: -variance...variance)
      // Add some weekly seasonality or trend
      let trend = sin(Double(i) * 0.5) * (variance * 0.2)
      let value = max(0, base + noise + trend)
      data.append(value)
    }
    self.trendData = data

    // Mock Subjective Logs
    self.subjectiveLogs = [
      SubjectiveLog(type: .sleep, value: "7h 45m", trend: .up),
      SubjectiveLog(type: .energy, value: "High", trend: .stable),
      SubjectiveLog(type: .stress, value: "Low", trend: .down),
      SubjectiveLog(type: .soreness, value: "None", trend: .stable),
      SubjectiveLog(type: .mood, value: "🙂 Good", trend: .up),
    ]
  }

  func updateTimeRange(_ range: HRVTimeRange) {
    selectedTimeRange = range
    // In a real app, fetch new data. Here, just re-randomize slightly to show change.
    generateMockData()
  }

  func updateMetric(_ metric: HRVMetricType) {
    selectedMetric = metric
    generateMockData()
  }

  func startSession() {
    // Stub
    print("Starting session...")
  }

  func logAction(_ action: HRVQuickAction) {
    // Stub
    print("Logged action: \(action.title)")
  }
}
