import SwiftUI
import SwiftData

@Observable
final class HomeViewModel {
    private(set) var todayMinutes: Double = 0
    private(set) var dailyGoalMinutes: Int = 8
    private(set) var currentStreak: Int = 0
    private(set) var goalMet: Bool = false
    private(set) var lastSelectedDuration: Int = 480

    var progressFraction: Double {
        guard dailyGoalMinutes > 0 else { return 0 }
        return min(todayMinutes / Double(dailyGoalMinutes), 1.0)
    }

    var remainingMinutes: Double {
        max(Double(dailyGoalMinutes) - todayMinutes, 0)
    }

    func refresh(
        modelContext: ModelContext,
        streakService: StreakService,
        healthKitService: HealthKitService
    ) async {
        // Fetch goal
        let goalDescriptor = FetchDescriptor<UserGoal>()
        let goals = (try? modelContext.fetch(goalDescriptor)) ?? []
        let goal = goals.first?.dailyGoalMinutes ?? 8
        await MainActor.run { dailyGoalMinutes = goal }

        // Fetch settings
        let settingsDescriptor = FetchDescriptor<AppSettings>()
        let settingsArray = (try? modelContext.fetch(settingsDescriptor)) ?? []
        let duration = settingsArray.first?.lastSelectedDuration ?? 480
        await MainActor.run { lastSelectedDuration = duration }

        // Fetch today's sessions from local data
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = #Predicate<MeditationSession> { session in
            session.startDate >= startOfDay
        }
        let descriptor = FetchDescriptor<MeditationSession>(predicate: predicate)
        let sessions = (try? modelContext.fetch(descriptor)) ?? []
        var localMinutes = sessions.reduce(0.0) { $0 + $1.actualMinutes }

        // Fetch HealthKit minutes (may include other apps)
        if healthKitService.isAuthorized {
            if let hkMinutes = try? await healthKitService.fetchTodayMindfulMinutes() {
                localMinutes = max(localMinutes, hkMinutes)
            }
        }

        await MainActor.run {
            todayMinutes = localMinutes
            goalMet = localMinutes >= Double(goal)
        }

        // Fetch streak
        let streakDescriptor = FetchDescriptor<StreakRecord>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        let records = (try? modelContext.fetch(streakDescriptor)) ?? []
        let streak = streakService.calculateCurrentStreak(records: records)
        await MainActor.run { currentStreak = streak }
    }
}
