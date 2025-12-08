//
//  RecoveryLogStore.swift
//  EverForm
//
//  Created by Assistant on 01/12/2025.
//

import Foundation
import SwiftUI

enum RecoveryType: String, CaseIterable {
    case restDay = "Rest Day"
    case mobility = "Mobility"
    case massage = "Massage"
    case sauna = "Sauna"
    case coldPlunge = "Cold Plunge"
    case breathwork = "Breathwork"
}

struct RecoveryEntry: Identifiable {
    let id = UUID()
    let date: Date
    let type: RecoveryType
    let note: String?
}

class RecoveryLogStore: ObservableObject {
    @Published var entries: [RecoveryEntry] = []
    
    func log(type: RecoveryType, date: Date = .now, note: String?) {
        let newEntry = RecoveryEntry(date: date, type: type, note: note)
        entries.append(newEntry)
        // Sort entries descending by date for recent lists
        entries.sort { $0.date > $1.date }
    }
    
    // Helper to check if an activity was done today
    func isLoggedToday(type: RecoveryType) -> Bool {
        let calendar = Calendar.current
        return entries.contains { entry in
            entry.type == type && calendar.isDateInToday(entry.date)
        }
    }
}








