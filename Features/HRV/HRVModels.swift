//
//  HRVModels.swift
//  EverForm
//
//  Created by Assistant on 24/11/2025.
//

import Foundation
import SwiftUI

// MARK: - Enums

enum HRVTimeRange: String, CaseIterable, Identifiable {
  case week = "1W"
  case twoWeeks = "2W"
  case month = "1M"
  case year = "1Y"

  var id: String { rawValue }
}

enum HRVMetricType: String, CaseIterable, Identifiable {
  case heartRate = "Heart Rate"
  case rmssd = "rMSSD"
  case lnRmssd = "ln(rMSSD)"
  case sdnn = "SDNN"
  case pnn50 = "PNN50"
  case totalPower = "Total Power"
  case lf = "LF"
  case hf = "HF"
  case lfHf = "LF/HF"

  var id: String { rawValue }

  var unit: String {
    switch self {
    case .heartRate: return "bpm"
    case .rmssd, .sdnn: return "ms"
    case .lnRmssd: return ""
    case .pnn50: return "%"
    case .totalPower, .lf, .hf: return "ms²"
    case .lfHf: return "ratio"
    }
  }
}

enum SubjectiveMetricType: String, CaseIterable {
  case sleep = "Sleep"
  case energy = "Energy"
  case stress = "Stress"
  case soreness = "Soreness"
  case mood = "Mood"
}

// MARK: - Data Models

struct HRVDataPoint: Identifiable {
  let id = UUID()
  let date: Date
  let value: Double
}

struct SubjectiveLog: Identifiable {
  let id = UUID()
  let type: SubjectiveMetricType
  let value: String  // e.g., "Good", "High", "7.5h"
  let trend: TrendDirection  // Simple trend for UI
}

enum TrendDirection {
  case up, down, stable
}

struct BreathingProtocol: Identifiable {
  let id = UUID()
  let name: String
  let description: String
  let durationMinutes: Int
  let targetTag: String
  let color: Color
}

struct HRVQuickAction: Identifiable {
  let id = UUID()
  let title: String
  let icon: String
}
