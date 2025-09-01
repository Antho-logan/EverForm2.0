import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    enum Role: String, Codable {
        case user, assistant, system
    }
    
    let id: UUID
    var role: Role
    var text: String
    var images: [ImageAsset]
    var audioURL: URL?
    var createdAt: Date
    var isStreaming: Bool
    
    init(role: Role, text: String = "", images: [ImageAsset] = [], audioURL: URL? = nil, isStreaming: Bool = false) {
        self.id = UUID()
        self.role = role
        self.text = text
        self.images = images
        self.audioURL = audioURL
        self.createdAt = Date()
        self.isStreaming = isStreaming
    }
}

struct ImageAsset: Identifiable, Codable, Equatable {
    let id: UUID
    let filename: String
    let data: Data
    
    init(filename: String, data: Data) {
        self.id = UUID()
        self.filename = filename
        self.data = data
    }
    
    static func == (lhs: ImageAsset, rhs: ImageAsset) -> Bool {
        lhs.id == rhs.id
    }
}





