import SwiftUI
import SwiftData

@Observable
final class OnboardingViewModel {
    var currentPage: Int = 0
    let totalPages = 3

    var isLastPage: Bool {
        currentPage == totalPages - 1
    }

    func nextPage() {
        if currentPage < totalPages - 1 {
            currentPage += 1
        }
    }

    func completeOnboarding(
        modelContext: ModelContext,
        healthKitService: HealthKitService,
        notificationService: NotificationService,
        requestHealthKit: Bool
    ) async {
        // Set up default goal
        let goal = UserGoal(dailyGoalMinutes: 8)
        modelContext.insert(goal)

        // Request HealthKit if opted in
        if requestHealthKit {
            try? await healthKitService.requestAuthorization()
        }

        // Request notification permission
        _ = try? await notificationService.requestPermission()
        await notificationService.scheduleDailyReminder(hour: 8, minute: 0)

        // Mark onboarding complete
        let descriptor = FetchDescriptor<AppSettings>()
        let settingsArray = (try? modelContext.fetch(descriptor)) ?? []
        if let settings = settingsArray.first {
            settings.hasCompletedOnboarding = true
            settings.healthKitAuthorized = requestHealthKit && healthKitService.isAuthorized
        }
    }
}
