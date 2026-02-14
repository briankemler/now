import Foundation
import SwiftData

final class StreakService {

    func calculateCurrentStreak(records: [StreakRecord]) -> Int {
        let sorted = records
            .filter { $0.goalMet || $0.frozenSkip }
            .sorted { $0.date > $1.date }

        guard !sorted.isEmpty else { return 0 }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var expectedDate = today

        // Check if today's goal is met
        if let todayRecord = sorted.first(where: { calendar.isDate($0.date, inSameDayAs: today) }) {
            if todayRecord.goalMet || todayRecord.frozenSkip {
                streak = 1
                expectedDate = calendar.date(byAdding: .day, value: -1, to: today)!
            } else {
                expectedDate = calendar.date(byAdding: .day, value: -1, to: today)!
            }
        } else {
            // Today not yet recorded, start checking from yesterday
            expectedDate = calendar.date(byAdding: .day, value: -1, to: today)!
        }

        for record in sorted {
            if calendar.isDate(record.date, inSameDayAs: today) { continue }
            if calendar.isDate(record.date, inSameDayAs: expectedDate) {
                streak += 1
                expectedDate = calendar.date(byAdding: .day, value: -1, to: expectedDate)!
            } else if record.date < expectedDate {
                break
            }
        }

        return streak
    }

    func updateTodayRecord(
        totalMinutes: Double,
        goalMinutes: Int,
        context: ModelContext
    ) {
        let today = Calendar.current.startOfDay(for: Date())
        let predicate = #Predicate<StreakRecord> { record in
            record.date == today
        }
        let descriptor = FetchDescriptor<StreakRecord>(predicate: predicate)

        if let existing = try? context.fetch(descriptor).first {
            existing.totalMinutes = totalMinutes
            existing.goalMet = totalMinutes >= Double(goalMinutes)
        } else {
            let record = StreakRecord(
                date: today,
                totalMinutes: totalMinutes,
                goalMet: totalMinutes >= Double(goalMinutes)
            )
            context.insert(record)
        }
    }

    // MARK: - Streak Freeze (P2)

    func canUseStreakFreeze(settings: AppSettings) -> Bool {
        guard settings.streakFreezeAvailable else { return false }

        // Reset weekly on Monday
        let calendar = Calendar.current
        if let lastReset = settings.streakFreezeLastReset {
            let startOfThisWeek = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
            let startOfLastReset = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: lastReset)
            if startOfThisWeek != startOfLastReset {
                settings.streakFreezeAvailable = true
                settings.streakFreezeLastReset = Date()
            }
        }

        return settings.streakFreezeAvailable
    }

    func applyStreakFreeze(
        settings: AppSettings,
        context: ModelContext
    ) {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let startOfYesterday = Calendar.current.startOfDay(for: yesterday)
        let predicate = #Predicate<StreakRecord> { record in
            record.date == startOfYesterday
        }
        let descriptor = FetchDescriptor<StreakRecord>(predicate: predicate)

        if let existing = try? context.fetch(descriptor).first {
            existing.frozenSkip = true
            existing.goalMet = true
        } else {
            let record = StreakRecord(date: yesterday, totalMinutes: 0, goalMet: true)
            record.frozenSkip = true
            context.insert(record)
        }

        settings.streakFreezeAvailable = false
    }
}
