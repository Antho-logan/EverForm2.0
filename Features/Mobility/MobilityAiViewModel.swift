//
//  MobilityAiViewModel.swift
//  EverForm
//
//  Created by Assistant on 07/12/2025.
//

import Foundation
import SwiftUI

final class MobilityAiViewModel: ObservableObject {
    
    enum AssessmentState: Equatable {
        case idle
        case submitting
        case loaded(MobilityAssessmentSummaryDTO)
        case empty      // no assessments yet
        case error(String)
    }

    enum WeeklyFocusState: Equatable {
        case idle
        case loading
        case loaded(MobilityWeeklyFocusDTO)
        case error(String)
    }

    @Published var assessmentState: AssessmentState = .idle
    @Published var weeklyFocusState: WeeklyFocusState = .idle

    // Last loaded data for convenient access
    @Published var latestSummary: MobilityAssessmentSummaryDTO?
    @Published var weeklyFocus: MobilityWeeklyFocusDTO?
    
    private let service: MobilityServiceProtocol
    
    init(service: MobilityServiceProtocol = MobilityService.shared) {
        self.service = service
    }

    // MARK: - Actions

    @MainActor
    func submitAssessment(from store: MobilityStore, notes: String?) async {
        assessmentState = .submitting
        
        // Map store results to DTOs
        let resultsDTO = store.results.compactMap { result -> MobilityTestResultDTO? in
            guard let test = store.tests.first(where: { $0.id == result.testId }) else { return nil }
            
            // Map the single 'score' (1-5) to both ROM and Control if applicable, 
            // or just ROM as a simple heuristic since we don't distinguish in the UI yet.
            // Based on user choice: "Map 'score' to both (or ask for logic)"
            
            return MobilityTestResultDTO(
                testId: test.id.uuidString,
                testName: test.name,
                joint: test.bodyArea.rawValue.lowercased(), // Ensure backend enum match
                rangeOfMotionScore: result.score,
                controlScore: result.score,
                pain: false, // UI doesn't capture pain yet
                notes: nil
            )
        }
        
        do {
            let input = MobilityAssessmentInputDTO(tests: resultsDTO, notes: notes)
            let summary = try await service.submitAssessment(input)
            
            latestSummary = summary
            assessmentState = .loaded(summary)
            
            // Refresh weekly focus too as new assessment might change it
            await loadWeeklyFocus()
            
        } catch {
            assessmentState = .error(error.localizedDescription)
        }
    }

    @MainActor
    func loadLatestAssessment() async {
        // Only reset to idle if we don't have data, to avoid flickering if refreshing
        if case .idle = assessmentState {
           // assessmentState = .idle // Already idle
        }
        
        do {
            if let summary = try await service.fetchLatestAssessment() {
                latestSummary = summary
                assessmentState = .loaded(summary)
            } else {
                assessmentState = .empty
            }
        } catch {
            assessmentState = .error(error.localizedDescription)
        }
    }

    @MainActor
    func loadWeeklyFocus(forWeekContaining date: Date = Date()) async {
        weeklyFocusState = .loading
        do {
            let calendar = Calendar.current
            // Find start of week (Sunday or Monday depending on locale, usually we want fixed start)
            // Assuming ISO week (Monday start) or standard locale behavior.
            // Let's use user's locale.
            
            var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
            components.weekday = 2 // Monday
            
            let startOfWeek = calendar.date(from: components) ?? date
            let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? date

            let focus = try await service.fetchWeeklyFocus(from: startOfWeek, to: endOfWeek)
            
            weeklyFocus = focus
            weeklyFocusState = .loaded(focus)
        } catch {
            weeklyFocusState = .error(error.localizedDescription)
        }
    }
}

