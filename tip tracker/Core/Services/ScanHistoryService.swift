import Foundation

struct SavedScan: Codable, Identifiable, Hashable {
    var id = UUID()
    var date: Date
    var mode: String
    var title: String
    var calories: Int?
}

protocol ScanHistoryServiceProtocol {
    func load() -> [SavedScan]
    func save(_ item: SavedScan)
    func clear()
}

final class ScanHistoryService: ScanHistoryServiceProtocol {
    private let filename = "scan_history.json"
    private let maxItems = 200

    func load() -> [SavedScan] {
        return SafeFileIO.load([SavedScan].self, from: filename) ?? []
    }
    
    func save(_ item: SavedScan) {
        var items = load()
        items.insert(item, at: 0)
        
        // Cap history to maxItems
        items = SafeFileIO.capHistory(items, maxCount: maxItems)
        
        do {
            try SafeFileIO.save(items, to: filename)
        } catch {
            Task { @MainActor in
                UX.Banner.show(message: "Failed to save scan history")
            }
        }
    }
    
    func clear() {
        do {
            try SafeFileIO.deleteFile(filename)
        } catch {
            Task { @MainActor in
                UX.Banner.show(message: "Failed to clear scan history")
            }
        }
    }
}

