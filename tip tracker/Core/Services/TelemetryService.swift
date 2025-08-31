//
//  TelemetryService.swift
//  EverForm
//
//  Telemetry service for tracking user events
//  Assumption: Simple stub for now, can integrate with TelemetryDeck later
//

import Foundation

final class TelemetryService {
    static let shared = TelemetryService()
    
    private init() {}
    
    func track(_ event: String, properties: [String: Any] = [:]) {
        DebugLog.d("Telemetry: \(event) \(properties)")
        // TODO: Integrate with TelemetryDeck or analytics service
    }
}

