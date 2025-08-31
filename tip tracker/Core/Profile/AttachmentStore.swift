import Foundation
import Observation

public struct LabAttachment: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let filename: String
    public let relativePath: String
    public let addedAt: Date
    public var userNotes: String?

    public init(id: UUID = UUID(),
                filename: String,
                relativePath: String,
                addedAt: Date = Date(),
                userNotes: String? = nil) {
        self.id = id
        self.filename = filename
        self.relativePath = relativePath
        self.addedAt = addedAt
        self.userNotes = userNotes
    }
}

@Observable
public final class AttachmentStore: @unchecked Sendable {
    private let fm = FileManager.default
    private let baseFolderURL: URL
    private let indexURL: URL
    private var attachments: [LabAttachment] = []

    public init(rootFolderName: String = "EverForm") {
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.baseFolderURL = docs.appendingPathComponent(rootFolderName, isDirectory: true)
                                 .appendingPathComponent("user_docs", isDirectory: true)
        self.indexURL = baseFolderURL.appendingPathComponent("attachments_index.json")

        try? fm.createDirectory(at: baseFolderURL, withIntermediateDirectories: true)
        loadIndex()
    }

    public func getAttachments() -> [LabAttachment] {
        return attachments
    }

    @discardableResult
    public func saveFile(fileURL: URL, userNotes: String? = nil) throws -> LabAttachment {
        try? fm.createDirectory(at: baseFolderURL, withIntermediateDirectories: true)

        let uniqueURL = uniqueDestination(for: fileURL.lastPathComponent)
        try fm.copyItem(at: fileURL, to: uniqueURL)

        let filename = uniqueURL.lastPathComponent
        let rel = filename
        let att = LabAttachment(filename: filename,
                                relativePath: rel,
                                userNotes: userNotes)
        attachments.insert(att, at: 0)
        try saveIndex()
        return att
    }

    public func deleteAttachment(id: UUID) throws {
        guard let idx = attachments.firstIndex(where: { $0.id == id }) else { return }
        let rel = attachments[idx].relativePath
        let url = baseFolderURL.appendingPathComponent(rel)
        try? fm.removeItem(at: url)
        attachments.remove(at: idx)
        try saveIndex()
    }

    private func loadIndex() {
        guard fm.fileExists(atPath: indexURL.path) else {
            attachments = []
            return
        }
        do {
            let data = try Data(contentsOf: indexURL)
            let decoded = try JSONDecoder().decode([LabAttachment].self, from: data)
            attachments = decoded
        } catch {
            attachments = []
        }
    }

    private func saveIndex() throws {
        let data = try JSONEncoder().encode(attachments)
        try data.write(to: indexURL, options: .atomic)
    }

    private func uniqueDestination(for proposedName: String) -> URL {
        var dest = baseFolderURL.appendingPathComponent(proposedName)
        let ext = dest.pathExtension
        var stem = dest.deletingPathExtension().lastPathComponent
        var counter = 1
        while fm.fileExists(atPath: dest.path) {
            counter += 1
            let newName = ext.isEmpty ? "\(stem)-\(counter)" : "\(stem)-\(counter).\(ext)"
            dest = baseFolderURL.appendingPathComponent(newName)
        }
        return dest
    }
}
