import SwiftData
import Foundation

@Model
final class StreakRecord {
    var id: UUID
    var date: Date
    var totalMinutes: Double
    var goalMet: Bool
    var frozenSkip: Bool

    init(date: Date, totalMinutes: Double = 0, goalMet: Bool = false) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.totalMinutes = totalMinutes
        self.goalMet = goalMet
        self.frozenSkip = false
    }
}
