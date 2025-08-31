//
//  ProfileNotesStore.swift
//  EverForm
//
//  Created by Anthony Logan on 23/08/2025.
//

import Foundation
import Observation

/// Manages free-form profile notes for RAG context building
@Observable
final class ProfileNotesStore {
    private let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("EverForm", isDirectory: true)
    private var notesURL: URL { dir.appendingPathComponent("ProfileNotes.md") }

    var notes: String = "" {
        didSet {
            if notes != oldValue {
                persist()
            }
        }
    }

    init() {
        load()
    }
    
    /// Manually persist notes (usually automatic via didSet)
    func save() {
        persist()
    }

    private func persist() {
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            try notes.data(using: .utf8)?.write(to: notesURL, options: .atomic)
            print("📝 ProfileNotesStore: Saved notes (\(notes.count) chars)")
        } catch {
            print("⚠️ ProfileNotesStore: Failed to save - \(error)")
        }
    }
    
    private func load() {
        do {
            notes = try String(contentsOf: notesURL, encoding: .utf8)
            print("📖 ProfileNotesStore: Loaded notes (\(notes.count) chars)")
        } catch {
            // File doesn't exist - start with empty notes
            notes = ""
        }
    }
}

