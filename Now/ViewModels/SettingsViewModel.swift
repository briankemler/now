import SwiftUI
import SwiftData

@Observable
final class SettingsViewModel {
    private(set) var healthKitSyncedCount: Int = 0
    private(set) var totalSessionCount: Int = 0
    private(set) var notificationPermissionGranted = false

    func refresh(modelContext: ModelContext, notificationService: NotificationService) async {
        let descriptor = FetchDescriptor<MeditationSession>()
        let sessions = (try? modelContext.fetch(descriptor)) ?? []
        await MainActor.run {
            totalSessionCount = sessions.count
            healthKitSyncedCount = sessions.filter(\.syncedToHealthKit).count
        }

        let granted = await notificationService.isPermissionGranted()
        await MainActor.run {
            notificationPermissionGranted = granted
        }
    }

    func updateGoal(
        _ minutes: Int,
        modelContext: ModelContext
    ) {
        let descriptor = FetchDescriptor<UserGoal>()
        let goals = (try? modelContext.fetch(descriptor)) ?? []
        if let existing = goals.first {
            existing.dailyGoalMinutes = minutes
            existing.modifiedDate = Date()
        } else {
            let goal = UserGoal(dailyGoalMinutes: minutes)
            modelContext.insert(goal)
        }
    }
}
