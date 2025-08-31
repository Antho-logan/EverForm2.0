import Foundation
import OSLog

/// Safe file I/O utilities with atomic writes and directory creation
enum SafeFileIO {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "EverForm", category: "SafeFileIO")
    
    /// Ensures a directory exists, creating it if necessary
    static func ensureDirectoryExists(at url: URL) throws {
        let fileManager = FileManager.default
        
        if !fileManager.fileExists(atPath: url.path) {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
            logger.info("Created directory: \(url.path)")
        }
    }
    
    /// Atomically writes data to a file using a temporary file
    static func atomicWrite<T: Codable>(_ data: T, to url: URL) throws {
        // Ensure parent directory exists
        try ensureDirectoryExists(at: url.deletingLastPathComponent())
        
        // Create temporary file URL
        let tempURL = url.appendingPathExtension("tmp")
        
        // Encode and write to temporary file
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let jsonData = try encoder.encode(data)
        try jsonData.write(to: tempURL)
        
        // Atomically move temp file to final location
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.path) {
            _ = try fileManager.replaceItem(at: url, withItemAt: tempURL, backupItemName: nil, options: [], resultingItemURL: nil)
        } else {
            try fileManager.moveItem(at: tempURL, to: url)
        }
        
        logger.debug("Atomically wrote file: \(url.lastPathComponent)")
    }
    
    /// Safely reads and decodes a JSON file with error handling
    static func safeRead<T: Codable>(_ type: T.Type, from url: URL) -> T? {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let result = try decoder.decode(type, from: data)
            logger.debug("Successfully read file: \(url.lastPathComponent)")
            return result
            
        } catch DecodingError.dataCorrupted(let context) {
            logger.error("Data corrupted in \(url.lastPathComponent): \(context.debugDescription)")
            Task { @MainActor in
                UX.Banner.show(message: "Data file corrupted: \(url.lastPathComponent)")
            }
            return nil
            
        } catch DecodingError.keyNotFound(let key, let context) {
            logger.error("Missing key '\(key.stringValue)' in \(url.lastPathComponent): \(context.debugDescription)")
            Task { @MainActor in
                UX.Banner.show(message: "Data format outdated: \(url.lastPathComponent)")
            }
            return nil
            
        } catch DecodingError.typeMismatch(let type, let context) {
            logger.error("Type mismatch for \(type) in \(url.lastPathComponent): \(context.debugDescription)")
            Task { @MainActor in
                UX.Banner.show(message: "Data format error: \(url.lastPathComponent)")
            }
            return nil
            
        } catch DecodingError.valueNotFound(let type, let context) {
            logger.error("Missing value for \(type) in \(url.lastPathComponent): \(context.debugDescription)")
            Task { @MainActor in
                UX.Banner.show(message: "Missing data in: \(url.lastPathComponent)")
            }
            return nil
            
        } catch CocoaError.fileReadNoSuchFile {
            // File doesn't exist - this is normal for first run
            logger.debug("File does not exist: \(url.lastPathComponent)")
            return nil
            
        } catch {
            logger.error("Failed to read \(url.lastPathComponent): \(error.localizedDescription)")
            Task { @MainActor in
                UX.Banner.show(message: "Failed to load: \(url.lastPathComponent)")
            }
            return nil
        }
    }
    
    /// Caps an array to a maximum number of items, removing oldest entries
    static func capHistory<T>(_ items: [T], maxCount: Int = 200) -> [T] {
        guard items.count > maxCount else { return items }
        
        let excess = items.count - maxCount
        logger.info("Capping history: removing \(excess) old entries, keeping \(maxCount)")
        
        return Array(items.suffix(maxCount))
    }
    
    /// Gets the EverForm documents directory, creating it if needed
    static func getEverFormDirectory() throws -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let everFormURL = documentsURL.appendingPathComponent("EverForm")
        
        try ensureDirectoryExists(at: everFormURL)
        return everFormURL
    }
    
    /// Convenience method for getting a file URL in the EverForm directory
    static func fileURL(for filename: String) throws -> URL {
        let directory = try getEverFormDirectory()
        return directory.appendingPathComponent(filename)
    }
}

/// Extension for common file operations
extension SafeFileIO {
    /// Safely saves a Codable object to the EverForm directory
    static func save<T: Codable>(_ object: T, to filename: String) throws {
        let url = try fileURL(for: filename)
        try atomicWrite(object, to: url)
    }
    
    /// Safely loads a Codable object from the EverForm directory
    static func load<T: Codable>(_ type: T.Type, from filename: String) -> T? {
        do {
            let url = try fileURL(for: filename)
            return safeRead(type, from: url)
        } catch {
            logger.error("Failed to get file URL for \(filename): \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Checks if a file exists in the EverForm directory
    static func fileExists(_ filename: String) -> Bool {
        do {
            let url = try fileURL(for: filename)
            return FileManager.default.fileExists(atPath: url.path)
        } catch {
            return false
        }
    }
    
    /// Deletes a file from the EverForm directory
    static func deleteFile(_ filename: String) throws {
        let url = try fileURL(for: filename)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
            logger.info("Deleted file: \(filename)")
        }
    }
}
