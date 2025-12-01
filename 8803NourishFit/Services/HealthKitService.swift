import Foundation
import HealthKit
import Combine

class HealthKitService: ObservableObject {
    static let shared = HealthKitService()
    
    let healthStore = HKHealthStore()
    
    @Published var activeEnergyBurned: Double = 0
    @Published var isAuthorized = false
    
    private init() {}
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit not available on this device")
            return
        }
        
        let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let typesToRead: Set = [activeEnergyType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                self.isAuthorized = success
                if success {
                    self.fetchActiveEnergyBurnedToday()
                } else {
                    print("HealthKit authorization failed: \(String(describing: error))")
                }
            }
        }
    }
    
    func fetchActiveEnergyBurnedToday() {
        guard let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else { return }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: activeEnergyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Failed to fetch active energy: \(String(describing: error))")
                return
            }
            
            let calories = sum.doubleValue(for: HKUnit.kilocalorie())
            DispatchQueue.main.async {
                print("HealthKit: Fetched \(calories) kcal")
                self.activeEnergyBurned = calories
            }
        }
        
        healthStore.execute(query)
        
        // Enable background delivery
        let query2 = HKObserverQuery(sampleType: activeEnergyType, predicate: nil) { query, completionHandler, error in
            if error != nil {
                // Perform Proper Error Handling Here...
                print("*** An error occured while setting up the observerQuery: \(String(describing: error)) ***")
                return
            }
             
            // Re-fetch the data when an update occurs
            self.fetchActiveEnergyBurnedToday()
            completionHandler()
        }
        healthStore.execute(query2)
        
        healthStore.enableBackgroundDelivery(for: activeEnergyType, frequency: .immediate) { (success, error) in
            if success {
                print("HealthKit: Background delivery enabled")
            } else {
                print("HealthKit: Failed to enable background delivery: \(String(describing: error))")
            }
        }
    }
}

