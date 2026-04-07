//
//  HealthKitManager.swift
//  MoodUp
//

import Foundation
import HealthKit

enum SleepImportResult {
    case actual(duration: TimeInterval)
    case estimatedInBed(duration: TimeInterval)
}

final class HealthKitManager {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()

    private init() {}

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            DispatchQueue.main.async {
                completion(false, nil)
            }
            return
        }

        healthStore.requestAuthorization(toShare: [], read: [sleepType]) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }

    func fetchLastNightSleepDuration(completion: @escaping (SleepImportResult?) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }

        let end = Date()
        guard let start = Calendar.current.date(byAdding: .hour, value: -36, to: end) else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: start,
            end: end,
            options: []
        )

        let sortDescriptors = [
            NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        ]

        let query = HKSampleQuery(
            sampleType: sleepType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: sortDescriptors
        ) { _, samples, error in
            if let error {
                print("HealthKit sleep query error:", error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            guard let samples = samples as? [HKCategorySample], !samples.isEmpty else {
                print("HealthKit: no sleep samples returned")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            print("HealthKit sleep samples count:", samples.count)
            for sample in samples.prefix(10) {
                print("value:", sample.value, "start:", sample.startDate, "end:", sample.endDate)
            }

            let inBedValue = HKCategoryValueSleepAnalysis.inBed.rawValue

            let asleepSamples = samples.filter { $0.value != inBedValue }
            let totalSleep = asleepSamples.reduce(0.0) { partialResult, sample in
                partialResult + sample.endDate.timeIntervalSince(sample.startDate)
            }

            if totalSleep > 0 {
                DispatchQueue.main.async {
                    completion(.actual(duration: totalSleep))
                }
                return
            }

            let inBedSamples = samples
                .filter { $0.value == inBedValue }
                .sorted { $0.endDate > $1.endDate }

            if let latestInBed = inBedSamples.first {
                let estimatedDuration = latestInBed.endDate.timeIntervalSince(latestInBed.startDate)
                DispatchQueue.main.async {
                    completion(estimatedDuration > 0 ? .estimatedInBed(duration: estimatedDuration) : nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }

        healthStore.execute(query)
    }
}
