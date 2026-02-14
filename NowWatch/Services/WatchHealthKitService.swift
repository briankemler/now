import HealthKit

final class WatchHealthKitService {
    private let healthStore = HKHealthStore()

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
    }

    func saveMindfulSession(start: Date, end: Date) async throws {
        let sample = HKCategorySample(
            type: mindfulType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: start,
            end: end
        )
        try await healthStore.save(sample)
    }
}
