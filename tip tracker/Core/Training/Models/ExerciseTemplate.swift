//
//  ExerciseTemplate.swift
//  EverForm
//
//  Exercise template with default parameters for workout planning
//  Applied: P-ARCH, C-SIMPLE, R-LOGS
//

import Foundation

struct ExerciseTemplate: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let defaultRepRange: ClosedRange<Int>
    let defaultRestSec: Int
    let isBodyweight: Bool
    let notes: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        defaultRepRange: ClosedRange<Int>,
        defaultRestSec: Int = 90,
        isBodyweight: Bool = false,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.defaultRepRange = defaultRepRange
        self.defaultRestSec = defaultRestSec
        self.isBodyweight = isBodyweight
        self.notes = notes
    }
}

// MARK: - Codable Support for ClosedRange
extension ExerciseTemplate {
    private enum CodingKeys: String, CodingKey {
        case id, name, defaultRestSec, isBodyweight, notes
        case defaultRepRangeLower, defaultRepRangeUpper
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        defaultRestSec = try container.decode(Int.self, forKey: .defaultRestSec)
        isBodyweight = try container.decode(Bool.self, forKey: .isBodyweight)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        
        let lower = try container.decode(Int.self, forKey: .defaultRepRangeLower)
        let upper = try container.decode(Int.self, forKey: .defaultRepRangeUpper)
        defaultRepRange = lower...upper
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(defaultRestSec, forKey: .defaultRestSec)
        try container.encode(isBodyweight, forKey: .isBodyweight)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encode(defaultRepRange.lowerBound, forKey: .defaultRepRangeLower)
        try container.encode(defaultRepRange.upperBound, forKey: .defaultRepRangeUpper)
    }
}

// MARK: - Sample Templates
extension ExerciseTemplate {
    static let benchPress = ExerciseTemplate(
        name: "Bench Press",
        defaultRepRange: 8...12,
        defaultRestSec: 120
    )
    
    static let pullUps = ExerciseTemplate(
        name: "Pull-ups",
        defaultRepRange: 6...10,
        defaultRestSec: 90,
        isBodyweight: true
    )
    
    static let overheadPress = ExerciseTemplate(
        name: "Overhead Press",
        defaultRepRange: 8...12,
        defaultRestSec: 90
    )
    
    static let rows = ExerciseTemplate(
        name: "Rows",
        defaultRepRange: 10...15,
        defaultRestSec: 90
    )
    
    static let dips = ExerciseTemplate(
        name: "Dips",
        defaultRepRange: 8...12,
        defaultRestSec: 90,
        isBodyweight: true
    )
    
    static let facePulls = ExerciseTemplate(
        name: "Face Pulls",
        defaultRepRange: 15...20,
        defaultRestSec: 60
    )
}

