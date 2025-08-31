
//
// ScanViewModel.swift
// EverForm
//
// Manages state and logic for the ScanHomeView.
//

import SwiftUI
import PhotosUI
import OSLog

@Observable
final class ScanViewModel {
    var mode: ScanMode = .calorie
    var selectedPhoto: PhotosPickerItem?
    var showingPermissionAlert = false
    var scanHistory: [ScanHistoryItem] = []
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "EverForm", category: "ScanViewModel")
    
    // This would typically be injected.
    // For now, we use a shared instance pattern.
    private let router: AppRouter
    
    init(router: AppRouter) {
        self.router = router
        // In a real app, you would load history from a persistence service here.
        // loadScanHistory()
        logger.debug("ScanViewModel initialized")
    }
    
    @MainActor
    func generateMockResult() {
        logger.info("Generating mock scan result for mode: \(self.mode.rawValue)")
        // This would typically call a service, e.g., ScanService.shared.scanMock(mode: mode)
        let mockItem = ScanHistoryItem(title: "Mock Result: \(mode.rawValue.capitalized)", date: .now)
        scanHistory.insert(mockItem, at: 0)
        
        ErrorBannerManager.shared.show(message: "Mock scan result generated for \(mode.rawValue) mode")
    }
    
    @MainActor
    func handlePhotoSelection() {
        guard selectedPhoto != nil else { return }
        logger.info("Photo selected for scanning")
        // In a real implementation, this would process the photo via a service
        generateMockResult()
        selectedPhoto = nil // Reset after processing
    }
    
    func explainScanMode() {
        let prompt: String
        switch mode {
        case .calorie:
            prompt = "Explain how calorie scanning works and what information I can get from nutrition labels."
        case .ingredients:
            prompt = "Explain ingredient analysis and how to identify additives and quality markers in food."
        case .plateAI:
            prompt = "Explain how Plate AI estimates calories and macros from food photos, including its limitations."
        }
        
        logger.info("Opening coach with scan explanation for mode: \(self.mode.rawValue)")
        CoachCoordinator.shared.prefillWithCustomPrompt(
            prompt,
            feature: "scan_\(mode.rawValue)",
            autoSend: true
        )
        router.go(.coach)
    }
}
