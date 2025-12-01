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
        let exerciseTimeType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        let typesToRead: Set = [activeEnergyType, exerciseTimeType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                self.isAuthorized = success
                if success {
                    self.startObserving()
                    self.fetchActiveEnergyBurnedToday()
                } else {
                    print("HealthKit authorization failed: \(String(describing: error))")
                }
            }
        }
    }
    
    private func startObserving() {
        guard let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
              let exerciseTimeType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) else { return }
        
        // Enable background delivery for Energy
        healthStore.enableBackgroundDelivery(for: activeEnergyType, frequency: .immediate) { (success, error) in
            if success {
                print("HealthKit: Background delivery enabled for Energy")
            } else {
                print("HealthKit: Failed to enable background delivery for Energy: \(String(describing: error))")
            }
        }
        
        // Observe for changes in Energy
        let query = HKObserverQuery(sampleType: activeEnergyType, predicate: nil) { [weak self] query, completionHandler, error in
            if let error = error {
                print("*** An error occured while setting up the observerQuery: \(error.localizedDescription) ***")
                return
            }
             
            // Re-fetch the data when an update occurs
            self?.fetchActiveEnergyBurnedToday()
            completionHandler()
        }
        healthStore.execute(query)
        
        // Observe for changes in Exercise Time (optional, for completeness)
        let exerciseQuery = HKObserverQuery(sampleType: exerciseTimeType, predicate: nil) { _, completionHandler, _ in
            // We don't have a published property for today's exercise time yet, but this ensures we could update it
            completionHandler()
        }
        healthStore.execute(exerciseQuery)
    }
    
    func fetchWeeklyActiveEnergyBurned() -> AnyPublisher<[WorkoutTimeData], Error> {
        return Future<[WorkoutTimeData], Error> { promise in
            guard let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
                promise(.failure(NSError(domain: "HealthKitService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Active Energy Type unavailable"])))
                return
            }
            
            let calendar = Calendar.current
            let now = Date()
            // Get last 7 days including today
            guard let startDate = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now)) else {
                promise(.failure(NSError(domain: "HealthKitService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Date calculation failed"])))
                return
            }
            
            var interval = DateComponents()
            interval.day = 1
            
            let query = HKStatisticsCollectionQuery(
                quantityType: activeEnergyType,
                quantitySamplePredicate: nil,
                options: .cumulativeSum,
                anchorDate: startDate,
                intervalComponents: interval
            )
            
            query.initialResultsHandler = { query, results, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                var workoutData: [WorkoutTimeData] = []
                
                results?.enumerateStatistics(from: startDate, to: now) { statistics, stop in
                    let sum = statistics.sumQuantity()
                    let calories = sum?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
                    
                    // Reuse WorkoutTimeData: duration will store calories
                    workoutData.append(WorkoutTimeData(date: statistics.startDate, duration: Int(calories)))
                }
                
                promise(.success(workoutData))
            }
            
            self.healthStore.execute(query)
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
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
    }
}

