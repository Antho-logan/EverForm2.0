import Foundation

public enum BloodType: String, Codable, CaseIterable, Sendable {
    case unknown
    case Opos, Oneg, Apos, Aneg, Bpos, Bneg, ABpos, ABneg
}

public enum Chronotype: String, Codable, CaseIterable, Sendable {
    case unknown, lark, neutral, owl, shiftWorker
}

public struct ProfileAdvanced: Codable, Equatable, Sendable {
    public var bloodType: BloodType = .unknown
    public var chronotype: Chronotype = .unknown
    public var isPregnantOrPostpartum: Bool? = nil

    public var knownConditions: [String] = []
    public var injuries: [String] = []
    public var supplements: [String] = []
    public var foodDislikes: [String] = []
    public var budgetNotes: String? = nil
    
    /// Ensures all optional/array fields have safe defaults
    public func withDefaultsApplied() -> ProfileAdvanced {
        var p = self
        // Arrays are already initialized with defaults, but ensure they're not nil if somehow corrupted
        if p.knownConditions.isEmpty { p.knownConditions = [] }
        if p.injuries.isEmpty { p.injuries = [] }
        if p.supplements.isEmpty { p.supplements = [] }
        if p.foodDislikes.isEmpty { p.foodDislikes = [] }
        return p
    }
}
