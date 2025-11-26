import Foundation
import HealthKit
import SwiftUI
import Observation

@Observable
class HealthKitManager {
    static let shared = HealthKitManager()
    
    var isHealthDataAvailable: Bool = false
    var isHealthConnected: Bool {
        didSet {
            UserDefaults.standard.set(isHealthConnected, forKey: "isHealthConnected")
        }
    }
    
    private let healthStore = HKHealthStore()
    
    init() {
        self.isHealthConnected = UserDefaults.standard.bool(forKey: "isHealthConnected")
        checkAvailability()
    }
    
    private func checkAvailability() {
        isHealthDataAvailable = HKHealthStore.isHealthDataAvailable()
    }
    
    func requestAuthorization() async {
        guard isHealthDataAvailable else { return }
        
        // Define types to read
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount),
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            HKObjectType.quantityType(forIdentifier: .heartRate),
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis),
            HKObjectType.quantityType(forIdentifier: .dietaryWater)
        ].compactMap { $0 }
            .reduce(into: Set<HKObjectType>()) { $0.insert($1) }
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
            
            // Update state on main thread
            await MainActor.run {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    self.isHealthConnected = true
                }
            }
        } catch {
            print("HealthKit authorization failed: \(error.localizedDescription)")
            await MainActor.run {
                withAnimation {
                    self.isHealthConnected = false
                }
            }
        }
    }
    
    func disconnect() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isHealthConnected = false
        }
    }
}
