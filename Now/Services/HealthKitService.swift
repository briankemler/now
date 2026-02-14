import HealthKit
import Foundation

@Observable
final class HealthKitService {
    private let healthStore = HKHealthStore()
    private(set) var isAuthorized = false

    private var mindfulType: HKCategoryType {
        HKCategoryType(.mindfulSession)
    }

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async throws {
        guard isAvailable else { return }
        let typesToShare: Set<HKSampleType> = [mindfulType]
        let typesToRead: Set<HKObjectType> = [mindfulType]
        try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
        await MainActor.run {
            self.isAuthorized = true
        }
    }

    func checkAuthorizationStatus() {
        guard isAvailable else { return }
        let status = healthStore.authorizationStatus(for: mindfulType)
        isAuthorized = status == .sharingAuthorized
    }

    func saveMindfulSession(start: Date, end: Date) async throws {
        guard isAuthorized else { return }
        let sample = HKCategorySample(
            type: mindfulType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: start,
            end: end
        )
        try await healthStore.save(sample)
    }

    func fetchTodayMindfulMinutes() async throws -> Double {
        guard isAuthorized else { return 0 }
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: Date(),
            options: .strictStartDate
        )
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: mindfulType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let totalMinutes = (samples ?? []).reduce(0.0) { total, sample in
                    total + sample.endDate.timeIntervalSince(sample.startDate) / 60.0
                }
                continuation.resume(returning: totalMinutes)
            }
            self.healthStore.execute(query)
        }
    }

    func fetchMindfulMinutes(for date: Date) async throws -> Double {
        guard isAuthorized else { return 0 }
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: mindfulType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                let totalMinutes = (samples ?? []).reduce(0.0) { total, sample in
                    total + sample.endDate.timeIntervalSince(sample.startDate) / 60.0
                }
                continuation.resume(returning: totalMinutes)
            }
            self.healthStore.execute(query)
        }
    }
}
