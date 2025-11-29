//
//  BackendClient.swift
//  EverForm
//
//  Lightweight HTTP client for the EverForm backend
//

import Foundation

enum BackendConfig {
    // Host root; individual clients append /api/v1 paths
    static let baseURL = URL(string: "http://localhost:4000")!
}

enum BackendError: Error {
    case invalidURL
    case badResponse(Int)
    case decodingFailed
    case noData
}

/// Centralized backend client to keep URLSession usage consistent.
final class BackendClient {
    static let shared = BackendClient()
    
    /// Base URL e.g. http://localhost:4000/api/v1
    private let baseURL: URL = {
        // Keep a single source of truth for the backend root
        return BackendConfig.baseURL.appendingPathComponent("/api/v1")
    }()
    
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
    
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()
    
    private init() {}
    
    func get<T: Decodable>(_ path: String, query: [String: String] = [:]) async throws -> T {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw BackendError.invalidURL
        }
        if !query.isEmpty {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = components.url else { throw BackendError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, url: url)
        return try decode(T.self, from: data)
    }
    
    func post<T: Decodable, Body: Encodable>(_ path: String, body: Body) async throws -> T {
        return try await send(path: path, method: "POST", body: body)
    }
    
    func put<T: Decodable, Body: Encodable>(_ path: String, body: Body) async throws -> T {
        return try await send(path: path, method: "PUT", body: body)
    }
    
    // MARK: - Private helpers
    private func send<T: Decodable, Body: Encodable>(path: String, method: String, body: Body) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, url: url)
        return try decode(T.self, from: data)
    }
    
    private func validate(response: URLResponse, url: URL? = nil) throws {
        guard let http = response as? HTTPURLResponse else {
            throw BackendError.badResponse(-1)
        }
        guard 200..<300 ~= http.statusCode else {
            #if DEBUG
            print("❌ Request failed: \(url?.absoluteString ?? "unknown") with status: \(http.statusCode)")
            #endif
            throw BackendError.badResponse(http.statusCode)
        }
    }
    
    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        guard !data.isEmpty else { throw BackendError.noData }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("❌ Decoding failed for \(type): \(error)")
            throw BackendError.decodingFailed
        }
    }
}
