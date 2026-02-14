import SwiftUI
import SwiftData

@Observable
final class HistoryViewModel {
    private(set) var heatMapData: [Date: Double] = [:]
    private(set) var weeklyTotalMinutes: Double = 0
    private(set) var weeklySessionCount: Int = 0
    private(set) var previousWeekMinutes: Double = 0
    private(set) var dailyGoalMinutes: Int = 8

    func refresh(modelContext: ModelContext) {
        // Fetch goal
        let goalDescriptor = FetchDescriptor<UserGoal>()
        let goals = (try? modelContext.fetch(goalDescriptor)) ?? []
        dailyGoalMinutes = goals.first?.dailyGoalMinutes ?? 8

        // Fetch last 90 days of streak records
        let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: Date())!
        let startDate = Calendar.current.startOfDay(for: ninetyDaysAgo)
        let predicate = #Predicate<StreakRecord> { record in
            record.date >= startDate
        }
        let descriptor = FetchDescriptor<StreakRecord>(predicate: predicate)
        let records = (try? modelContext.fetch(descriptor)) ?? []

        var map: [Date: Double] = [:]
        for record in records {
            let day = Calendar.current.startOfDay(for: record.date)
            map[day] = record.totalMinutes
        }
        heatMapData = map

        // Weekly summary
        let startOfWeek = Date().startOfWeek
        let sessionPredicate = #Predicate<MeditationSession> { session in
            session.startDate >= startOfWeek
        }
        let sessionDescriptor = FetchDescriptor<MeditationSession>(predicate: sessionPredicate)
        let sessions = (try? modelContext.fetch(sessionDescriptor)) ?? []
        weeklyTotalMinutes = sessions.reduce(0.0) { $0 + $1.actualMinutes }
        weeklySessionCount = sessions.count

        // Previous week
        let prevWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: startOfWeek)!
        let prevPredicate = #Predicate<MeditationSession> { session in
            session.startDate >= prevWeekStart && session.startDate < startOfWeek
        }
        let prevDescriptor = FetchDescriptor<MeditationSession>(predicate: prevPredicate)
        let prevSessions = (try? modelContext.fetch(prevDescriptor)) ?? []
        previousWeekMinutes = prevSessions.reduce(0.0) { $0 + $1.actualMinutes }
    }

    func intensityLevel(for minutes: Double) -> Int {
        let goal = Double(dailyGoalMinutes)
        guard goal > 0 else { return 0 }
        let ratio = minutes / goal
        switch ratio {
        case 0: return 0
        case ..<0.25: return 1
        case ..<0.5: return 2
        case ..<1.0: return 3
        default: return 4
        }
    }
}
