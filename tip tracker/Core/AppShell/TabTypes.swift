//
// TabTypes.swift
// EverForm
//
// Tab enum and environment setter for programmatic tab switching
// Assumptions: Three tabs - overview, coach, scan
//

import SwiftUI

// MARK: - Tab Enum
enum Tab: String, CaseIterable, Hashable {
    case overview = "overview"
    case coach = "coach"
    case scan = "scan"
    
    var displayName: String {
        switch self {
        case .overview: return "Overview"
        case .coach: return "Coach"
        case .scan: return "Scan"
        }
    }
    
    var icon: String {
        switch self {
        case .overview: return "house.fill"
        case .coach: return "brain.head.profile"
        case .scan: return "camera.viewfinder"
        }
    }
    
    var accessibilityLabel: String {
        switch self {
        case .overview: return "Overview"
        case .coach: return "Coach"
        case .scan: return "Scan"
        }
    }
}

// MARK: - Tab Selection Environment
struct TabSelectionEnvironmentKey: EnvironmentKey {
    static let defaultValue: (Tab) -> Void = { _ in }
}

extension EnvironmentValues {
    var setSelectedTab: (Tab) -> Void {
        get { self[TabSelectionEnvironmentKey.self] }
        set { self[TabSelectionEnvironmentKey.self] = newValue }
    }
}