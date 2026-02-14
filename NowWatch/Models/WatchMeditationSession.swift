import SwiftData
import Foundation

@Model
final class WatchMeditationSession {
    var id: UUID
    var sessionID: String
    var startDate: Date
    var endDate: Date
    var durationSeconds: Int
    var actualDurationSeconds: Int
    var completed: Bool
    var syncedToPhone: Bool

    init(startDate: Date, durationSeconds: Int) {
        self.id = UUID()
        self.sessionID = UUID().uuidString
        self.startDate = startDate
        self.endDate = startDate
        self.durationSeconds = durationSeconds
        self.actualDurationSeconds = 0
        self.completed = false
        self.syncedToPhone = false
    }

    var actualMinutes: Double {
        Double(actualDurationSeconds) / 60.0
    }
}
