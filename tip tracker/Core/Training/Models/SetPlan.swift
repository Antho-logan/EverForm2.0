//
//  SetPlan.swift
//  EverForm
//
//  Planned set with target parameters
//  Applied: P-ARCH, C-SIMPLE, R-LOGS
//

import Foundation

struct SetPlan: Identifiable, Codable, Hashable {
    let id: UUID
    let targetRepsMin: Int
    let targetRepsMax: Int
    let targetWeight: Double?
    let targetRPE: Double?
    
    init(
        id: UUID = UUID(),
        targetRepsMin: Int,
        targetRepsMax: Int,
        targetWeight: Double? = nil,
        targetRPE: Double? = nil
    ) {
        self.id = id
        self.targetRepsMin = targetRepsMin
        self.targetRepsMax = targetRepsMax
        self.targetWeight = targetWeight
        self.targetRPE = targetRPE
    }
    
    /// Target rep range as ClosedRange
    var targetRepRange: ClosedRange<Int> {
        targetRepsMin...targetRepsMax
    }
    
    /// Formatted target display (e.g., "8-12 reps @ 60kg")
    var displayText: String {
        var text = "\(targetRepsMin)"
        if targetRepsMax != targetRepsMin {
            text += "-\(targetRepsMax)"
        }
        text += " reps"
        
        if let weight = targetWeight {
            text += " @ \(String(format: "%.0f", weight))kg"
        }
        
        if let rpe = targetRPE {
            text += " RPE \(String(format: "%.1f", rpe))"
        }
        
        return text
    }
}

// MARK: - Factory Methods
extension SetPlan {
    /// Create a set plan from an exercise template
    static func from(template: ExerciseTemplate, targetWeight: Double? = nil) -> SetPlan {
        SetPlan(
            targetRepsMin: template.defaultRepRange.lowerBound,
            targetRepsMax: template.defaultRepRange.upperBound,
            targetWeight: targetWeight
        )
    }
}

