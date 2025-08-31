//
//  ChatTypes.swift
//  EverForm
//
//  Shared types for chat functionality
//

import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    enum Role: String, Codable { case user, assistant, system }
    let id: UUID
    var role: Role
    var text: String
    var images: [ImageAsset]    // local images
    var audioURL: URL?          // recorded clip
    var createdAt: Date
    var isStreaming: Bool

    init(id: UUID = UUID(), role: Role, text: String, images: [ImageAsset] = [], audioURL: URL? = nil, createdAt: Date = Date(), isStreaming: Bool = false) {
        self.id = id
        self.role = role
        self.text = text
        self.images = images
        self.audioURL = audioURL
        self.createdAt = createdAt
        self.isStreaming = isStreaming
    }
}

struct ImageAsset: Identifiable, Codable, Equatable {
    let id: UUID
    let filename: String
    let data: Data   // PNG/JPEG

    init(id: UUID = UUID(), filename: String, data: Data) {
        self.id = id
        self.filename = filename
        self.data = data
    }
}


