//
//  QuickAction.swift
//  EverForm
//
//  Quick action model for reorderable tiles
//

import SwiftUI

struct QuickAction: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let icon: String
    let color: Color
    let actionType: ActionType
    
    enum ActionType: String, Codable, CaseIterable {
        case addWater = "addWater"
        case breathwork = "breathwork"
        case fixPain = "fixPain"
        case askCoach = "askCoach"
    }
    
    // Custom Color coding for persistence
    enum CodingKeys: String, CodingKey {
        case id, title, icon, actionType, colorHex
    }
    
    init(id: String, title: String, icon: String, color: Color, actionType: ActionType) {
        self.id = id
        self.title = title
        self.icon = icon
        self.color = color
        self.actionType = actionType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        icon = try container.decode(String.self, forKey: .icon)
        actionType = try container.decode(ActionType.self, forKey: .actionType)
        
        // Decode color from hex string
        let colorHex = try container.decode(String.self, forKey: .colorHex)
        color = Color(hex: colorHex) ?? .blue
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(icon, forKey: .icon)
        try container.encode(actionType, forKey: .actionType)
        try container.encode(color.toHex(), forKey: .colorHex)
    }
    
    static let defaultActions: [QuickAction] = [
        QuickAction(
            id: "addWater",
            title: "Add Water",
            icon: "drop.fill",
            color: .cyan,
            actionType: .addWater
        ),
        QuickAction(
            id: "breathwork",
            title: "Breathwork",
            icon: "wind",
            color: .green,
            actionType: .breathwork
        ),
        QuickAction(
            id: "fixPain",
            title: "Fix Pain",
            icon: "cross.case",
            color: .red,
            actionType: .fixPain
        ),
        QuickAction(
            id: "askCoach",
            title: "Ask Coach",
            icon: "brain.head.profile",
            color: .blue,
            actionType: .askCoach
        )
    ]
}

// MARK: - Color Extensions
// Color extensions moved to DesignSystem.swift to avoid duplicates
