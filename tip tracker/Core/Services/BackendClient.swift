//
//  BackendClient.swift
//  EverForm
//
//  Lightweight HTTP client for the EverForm backend.
//  All features should use this client for backend communication.
//

import Foundation
import UIKit

enum BackendConfig {
    // Host root; individual clients append /api/v1 paths
    // TODO: Replace 192.168.0.23 with your Mac's LAN IP when running on a physical device.
    #if targetEnvironment(simulator)
    static let baseURL = URL(string: "http://localhost:4000")!
    #else
    static let baseURL = URL(string: "http://192.168.0.23:4000")!
    #endif
}

enum BackendError: Error, LocalizedError {
    case invalidURL
    case badResponse(Int)
    case decodingFailed(Error)
    case noData
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .badResponse(let code):
            return "Server returned status \(code)"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .noData:
            return "No data received"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

/// Centralized backend client to keep URLSession usage consistent.
/// All features should use BackendClient.shared for backend communication.
final class BackendClient {
    static let shared = BackendClient()
    
    /// Base URL e.g. http://localhost:4000/api/v1
    private let baseURL: URL = {
        return BackendConfig.baseURL.appendingPathComponent("/api/v1")
    }()
    
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()
    
    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()
    
    private init() {}
    
    // MARK: - Generic HTTP Methods
    
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
        request.timeoutInterval = 15
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            try validate(response: response, url: url)
            return try decode(T.self, from: data)
        } catch let error as BackendError {
            throw error
        } catch {
            throw BackendError.networkError(error)
        }
    }
    
    func post<T: Decodable, Body: Encodable>(_ path: String, body: Body) async throws -> T {
        return try await send(path: path, method: "POST", body: body)
    }
    
    func put<T: Decodable, Body: Encodable>(_ path: String, body: Body) async throws -> T {
        return try await send(path: path, method: "PUT", body: body)
    }
    
    // MARK: - Private Helpers
    
    private func send<T: Decodable, Body: Encodable>(path: String, method: String, body: Body) async throws -> T {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15
        request.httpBody = try encoder.encode(body)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            try validate(response: response, url: url)
            return try decode(T.self, from: data)
        } catch let error as BackendError {
            throw error
        } catch {
            throw BackendError.networkError(error)
        }
    }
    
    private func validate(response: URLResponse, url: URL? = nil) throws {
        guard let http = response as? HTTPURLResponse else {
            throw BackendError.badResponse(-1)
        }
        guard 200..<300 ~= http.statusCode else {
            #if DEBUG
            print("❌ [BackendClient] Request failed: \(url?.absoluteString ?? "unknown") with status: \(http.statusCode)")
            #endif
            throw BackendError.badResponse(http.statusCode)
        }
    }
    
    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        guard !data.isEmpty else { throw BackendError.noData }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            #if DEBUG
            print("❌ [BackendClient] Decoding failed for \(type): \(error)")
            if let json = String(data: data, encoding: .utf8) {
                print("   Raw JSON: \(json.prefix(500))")
            }
            #endif
            throw BackendError.decodingFailed(error)
        }
    }
}

// MARK: - Profile API

extension BackendClient {
    
    struct ProfileResponse: Decodable {
        let profile: ProfileDTO?
        let onboardingAnswers: [OnboardingAnswerDTO]?
        let status: String?
    }
    
    struct ProfileDTO: Decodable {
        let id: String?
        let userId: String?
        let fullName: String?
        let email: String?
        let dateOfBirth: String?
        let gender: String?
        let heightCm: Int?
        let weightKg: Double?
        let activityLevel: String?
        let primaryGoal: String?
        let goalType: String?
        let bodyFat: Double?
        let createdAt: String?
    }
    
    struct OnboardingAnswerDTO: Decodable {
        let id: String?
        let questionKey: String?
        let answerText: String?
        let answerNumeric: Double?
    }
    
    struct UpdateProfileRequest: Encodable {
        let fullName: String?
        let email: String?
        let dateOfBirth: String?
        let gender: String?
        let heightCm: Int?
        let weightKg: Double?
        let activityLevel: String?
        let primaryGoal: String?
    }
    
    /// Fetches the user profile.
    func fetchProfile() async throws -> ProfileResponse {
        return try await get("profile")
    }
    
    /// Updates the user profile.
    func updateProfile(_ profile: UpdateProfileRequest) async throws -> ProfileResponse {
        return try await put("profile", body: profile)
    }
}

// MARK: - Nutrition API

extension BackendClient {
    
    struct NutritionSummaryResponse: Decodable {
        let date: String
        let totals: NutritionTotalsDTO
        let meals: [MealDTO]
        let mealsLoggedToday: Int?
        let status: String?
    }
    
    struct NutritionTotalsDTO: Decodable {
        let kcal: Int
        let protein: Double
        let carbs: Double
        let fat: Double
    }
    
    struct MealDTO: Decodable, Identifiable {
        let id: String
        let mealType: String?
        let title: String?
        let kcal: Int?
        let proteinG: Double?
        let carbsG: Double?
        let fatG: Double?
        let loggedAt: String?
        let source: String?
    }
    
    struct MealsResponse: Decodable {
        let meals: [MealDTO]
        let status: String?
    }
    
    struct CreateMealRequest: Encodable {
        let mealType: String
        let title: String
        let kcal: Int?
        let proteinG: Double?
        let carbsG: Double?
        let fatG: Double?
        let loggedAt: String
        let source: String?
    }
    
    struct CreateMealResponse: Decodable {
        let meal: MealDTO
        let status: String?
    }
    
    /// Fetches nutrition summary for a given date.
    func fetchNutritionSummary(for date: Date = Date()) async throws -> NutritionSummaryResponse {
        let dateString = ISO8601DateFormatter().string(from: date).prefix(10)
        return try await get("nutrition/summary", query: ["date": String(dateString)])
    }
    
    /// Fetches meals for a given date.
    func fetchMeals(for date: Date = Date()) async throws -> MealsResponse {
        let dateString = ISO8601DateFormatter().string(from: date).prefix(10)
        return try await get("nutrition/meals", query: ["date": String(dateString)])
    }
    
    /// Logs a new meal.
    func logMeal(_ meal: CreateMealRequest) async throws -> CreateMealResponse {
        return try await post("nutrition/meals", body: meal)
    }
}

// MARK: - Training API

extension BackendClient {
    
    struct TrainingSessionsResponse: Decodable {
        let sessions: [TrainingSessionDTO]
        let status: String?
    }
    
    struct TrainingSessionDTO: Decodable, Identifiable {
        let id: String
        let title: String?
        let status: String?
        let durationMinutes: Int?
        let performedAt: String?
        let notes: String?
    }
    
    struct TrainingPlanResponse: Decodable {
        let plan: TrainingPlanDTO?
        let status: String?
    }
    
    struct TrainingPlanDTO: Decodable {
        let id: String?
        let name: String?
        // planJson omitted - use a separate endpoint if needed
    }
    
    struct CreateTrainingSessionRequest: Encodable {
        let title: String
        let status: String
        let durationMinutes: Int?
        let performedAt: String?
        let notes: String?
    }
    
    struct CreateTrainingSessionResponse: Decodable {
        let session: TrainingSessionDTO
        let status: String?
    }
    
    /// Fetches training sessions.
    func fetchTrainingSessions(from: Date? = nil, to: Date? = nil) async throws -> TrainingSessionsResponse {
        var query: [String: String] = [:]
        if let from = from {
            query["from"] = ISO8601DateFormatter().string(from: from)
        }
        if let to = to {
            query["to"] = ISO8601DateFormatter().string(from: to)
        }
        return try await get("training/sessions", query: query)
    }
    
    /// Fetches the current training plan.
    func fetchTrainingPlan() async throws -> TrainingPlanResponse {
        return try await get("training/plan")
    }
    
    /// Logs a training session.
    func logTrainingSession(_ session: CreateTrainingSessionRequest) async throws -> CreateTrainingSessionResponse {
        return try await post("training/sessions", body: session)
    }
}

// MARK: - Recovery API

extension BackendClient {
    
    struct RecoveryRecentResponse: Decodable {
        let recoveryLog: RecoveryLogDTO?
        let recentPainCheck: PainCheckDTO?
        let status: String?
    }
    
    struct RecoveryLogDTO: Decodable {
        let id: String?
        let sleepHours: Double?
        let sleepScore: Int?
        let stressLevel: Int?
        let notes: String?
        let loggedAt: String?
    }
    
    struct PainCheckDTO: Decodable, Identifiable {
        let id: String?
        let area: String?
        let severity: Int?
        let description: String?
        let createdAt: String?
    }
    
    struct CreateRecoveryLogRequest: Encodable {
        let sleepHours: Double?
        let sleepScore: Int?
        let stressLevel: Int?
        let notes: String?
        let loggedAt: String
    }
    
    struct CreateRecoveryLogResponse: Decodable {
        let recoveryLog: RecoveryLogDTO
        let status: String?
    }
    
    /// Fetches recent recovery data.
    func fetchRecoveryRecent() async throws -> RecoveryRecentResponse {
        return try await get("recovery/recent")
    }
    
    /// Logs recovery data.
    func logRecovery(_ log: CreateRecoveryLogRequest) async throws -> CreateRecoveryLogResponse {
        return try await post("recovery/log", body: log)
    }
}

// MARK: - Mobility API

extension BackendClient {
    
    struct MobilitySessionsResponse: Decodable {
        let mobilitySessions: [MobilitySessionDTO]
        let status: String?
    }
    
    struct MobilitySessionDTO: Decodable, Identifiable {
        let id: String
        let routineId: String?
        let status: String?
        let performedAt: String?
    }
    
    struct MobilityPlanResponse: Decodable {
        let plan: MobilityPlanDTO?
        let status: String?
    }
    
    struct MobilityPlanDTO: Decodable {
        let id: String?
        let name: String?
    }
    
    struct CreateMobilitySessionRequest: Encodable {
        let routineId: String
        let status: String
        let performedAt: String?
    }
    
    struct CreateMobilitySessionResponse: Decodable {
        let mobilitySession: MobilitySessionDTO
        let status: String?
    }
    
    /// Fetches recent mobility sessions.
    func fetchMobilitySessions() async throws -> MobilitySessionsResponse {
        return try await get("mobility/sessions")
    }
    
    /// Fetches the mobility plan.
    func fetchMobilityPlan() async throws -> MobilityPlanResponse {
        return try await get("mobility/plan")
    }
    
    /// Logs a mobility session.
    func logMobilitySession(_ session: CreateMobilitySessionRequest) async throws -> CreateMobilitySessionResponse {
        return try await post("mobility/sessions", body: session)
    }
}

// MARK: - Fix Pain API

extension BackendClient {
    
    struct PainChecksResponse: Decodable {
        let painChecks: [PainCheckDTO]
        let status: String?
    }
    
    struct CreatePainCheckRequest: Encodable {
        let area: String
        let severity: Int
        let description: String?
    }
    
    struct CreatePainCheckResponse: Decodable {
        let painCheck: PainCheckDTO
        let status: String?
    }
    
    /// Fetches recent pain checks.
    func fetchPainChecks() async throws -> PainChecksResponse {
        return try await get("fix-pain/recent")
    }
    
    /// Logs a pain check.
    func logPainCheck(_ check: CreatePainCheckRequest) async throws -> CreatePainCheckResponse {
        return try await post("fix-pain/assess", body: check)
    }
}

// MARK: - Coach API

extension BackendClient {
    
    struct CoachMessageRequest: Encodable {
        let message: String
        let context: [String: String]?
    }
    
    struct CoachMessageResponse: Decodable {
        let reply: String
        let status: String?
    }
    
    /// Sends a message to the AI coach.
    func sendCoachMessage(_ message: String, context: [String: String]? = nil) async throws -> CoachMessageResponse {
        let request = CoachMessageRequest(message: message, context: context)
        return try await post("coach/message", body: request)
    }
}

// MARK: - Scan API

extension BackendClient {
    
    struct ScanAnalyzeRequest: Encodable {
        let mode: String
        let imageBase64: String
    }
    
    struct ScanAnalyzeResponse: Decodable {
        let mode: String?
        let calories: Int?
        let protein: Double?
        let carbs: Double?
        let fat: Double?
        let confidence: Double?
        let ingredients: [IngredientDTO]?
        let notes: String?
        let description: String?
        let mealType: String?
        let caloriesEstimate: Int?
        let status: String?
    }
    
    struct IngredientDTO: Decodable {
        let name: String
        let confidence: Double?
    }
    
    struct ScanMealResponse: Decodable {
        let meal: MealDTO?
        let analysis: ScanAnalyzeResponse?
        let status: String?
    }
    
    /// Analyzes a food image.
    func scanAnalyze(mode: String, imageBase64: String) async throws -> ScanAnalyzeResponse {
        let request = ScanAnalyzeRequest(mode: mode, imageBase64: imageBase64)
        return try await post("scan/analyze", body: request)
    }
    
    /// Scans and logs a meal.
    func scanMeal(mode: String, imageBase64: String) async throws -> ScanMealResponse {
        let request = ScanAnalyzeRequest(mode: mode, imageBase64: imageBase64)
        return try await post("scan/meal", body: request)
    }
}

// MARK: - Plate AI API

extension BackendClient {
    
    /// Response from the Plate AI analysis endpoint.
    struct PlateAnalysisResponse: Decodable {
        let success: Bool
        let source: String?
        let summary: String?
        let qualityLabel: String?
        let calories: PlateCaloriesInfo?
        let macros: PlateMacrosInfo?
        let warnings: [String]?
        let suggestions: [String]?
        let error: String?
        let debugId: String?
    }
    
    struct PlateCaloriesInfo: Decodable {
        let estimatedKcal: Double
        let confidence: Double
    }
    
    struct PlateMacroRating: Decodable {
        let grams: Double
        let rating: String
    }
    
    struct PlateMacrosInfo: Decodable {
        let protein: PlateMacroRating
        let carbs: PlateMacroRating
        let fat: PlateMacroRating
        let fiber: PlateMacroRating
    }
    
    /// Analyzes a plate image using the Plate AI endpoint.
    /// - Parameter image: The UIImage to analyze
    /// - Returns: PlateAnalysisResponse with nutrition analysis
    func analyzePlateImage(_ image: UIImage) async throws -> PlateAnalysisResponse {
        // Convert UIImage to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw BackendError.noData
        }
        
        let url = baseURL.appendingPathComponent("scan/plate-image")
        
        // Create multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60 // Vision models can be slow
        
        var body = Data()
        
        // Add image field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"plate.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        #if DEBUG
        print("📤 [BackendClient] Uploading plate image (\(imageData.count / 1024) KB)")
        #endif
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // For plate-image, we accept both 200 (success) and 500 (error with JSON body)
            guard let http = response as? HTTPURLResponse else {
                throw BackendError.badResponse(-1)
            }
            
            #if DEBUG
            print("📥 [BackendClient] Plate analysis response: \(http.statusCode)")
            if let json = String(data: data, encoding: .utf8) {
                print("   Raw: \(json.prefix(300))")
            }
            #endif
            
            // Always try to decode the response - both success and error have JSON
            let decoded = try decoder.decode(PlateAnalysisResponse.self, from: data)
            
            // If HTTP 500 but we decoded successfully, return the error response
            if http.statusCode >= 500 && !decoded.success {
                return decoded // Contains error info
            }
            
            // For other error codes without proper JSON, throw
            guard 200..<300 ~= http.statusCode || decoded.success else {
                throw BackendError.badResponse(http.statusCode)
            }
            
            return decoded
            
        } catch let error as BackendError {
            throw error
        } catch let decodingError as DecodingError {
            #if DEBUG
            print("❌ [BackendClient] Plate decoding failed: \(decodingError)")
            #endif
            throw BackendError.decodingFailed(decodingError)
        } catch {
            #if DEBUG
            print("❌ [BackendClient] Plate network error: \(error)")
            #endif
            throw BackendError.networkError(error)
        }
    }
}

// MARK: - Breathwork API

extension BackendClient {
    
    struct BreathworkPatternsResponse: Decodable {
        let patterns: [BreathworkPatternDTO]
        let status: String?
    }
    
    struct BreathworkPatternDTO: Decodable, Identifiable {
        let id: String
        let type: String
        let displayName: String
        let description: String
        let targetEffect: String
        let defaultRounds: Int
        let phases: [BreathPhaseDTO]
    }
    
    struct BreathPhaseDTO: Decodable {
        let type: String
        let durationSeconds: Double
        let instruction: String?
    }
    
    struct BreathworkSessionsResponse: Decodable {
        let sessions: [BreathworkSessionDTO]
        let status: String?
    }
    
    struct BreathworkSessionDTO: Decodable, Identifiable {
        let id: String
        let patternId: String
        let patternName: String
        let durationSeconds: Int
        let roundsCompleted: Int
        let longestHoldSeconds: Int
        let notes: String?
        let createdAt: String
    }
    
    struct CreateBreathworkSessionRequest: Encodable {
        let patternId: String
        let patternName: String
        let roundsCompleted: Int
        let durationSeconds: Int
        let longestHoldSeconds: Int
        let notes: String?
    }
    
    struct CreateBreathworkSessionResponse: Decodable {
        let session: BreathworkSessionDTO
        let status: String?
    }
    
    /// Fetches available breathing patterns.
    func fetchBreathworkPatterns() async throws -> [BreathworkPatternDTO] {
        let response: BreathworkPatternsResponse = try await get("breathwork/patterns")
        return response.patterns
    }
    
    /// Fetches recent breathwork sessions.
    func fetchRecentBreathworkSessions(limit: Int = 10) async throws -> [BreathworkSessionDTO] {
        let response: BreathworkSessionsResponse = try await get(
            "breathwork/sessions/recent",
            query: ["limit": String(limit)]
        )
        return response.sessions
    }
    
    /// Logs a breathwork session.
    func logBreathworkSession(
        patternId: String,
        patternName: String,
        roundsCompleted: Int,
        durationSeconds: Int,
        longestHoldSeconds: Int = 0,
        notes: String? = nil
    ) async throws -> BreathworkSessionDTO {
        let request = CreateBreathworkSessionRequest(
            patternId: patternId,
            patternName: patternName,
            roundsCompleted: roundsCompleted,
            durationSeconds: durationSeconds,
            longestHoldSeconds: longestHoldSeconds,
            notes: notes
        )
        let response: CreateBreathworkSessionResponse = try await post("breathwork/sessions", body: request)
        return response.session
    }
}

// MARK: - Health Check

extension BackendClient {
    
    struct HealthResponse: Decodable {
        let status: String
        let timestamp: String?
        let version: String?
    }
    
    /// Checks if the backend is reachable.
    func healthCheck() async throws -> HealthResponse {
        return try await get("health")
    }
}
