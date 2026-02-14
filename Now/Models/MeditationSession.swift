import SwiftData
import Foundation

enum SessionSource: String, Codable {
    case iPhone
    case appleWatch
}

@Model
final class MeditationSession {
    var id: UUID
    var startDate: Date
    var endDate: Date
    var durationSeconds: Int
    var actualDurationSeconds: Int
    var completed: Bool
    var syncedToHealthKit: Bool
    var source: SessionSource
    var watchSessionID: String?

    init(
        startDate: Date,
        durationSeconds: Int,
        source: SessionSource = .iPhone
    ) {
        self.id = UUID()
        self.startDate = startDate
        self.endDate = startDate
        self.durationSeconds = durationSeconds
        self.actualDurationSeconds = 0
        self.completed = false
        self.syncedToHealthKit = false
        self.source = source
        self.watchSessionID = nil
    }

    var actualMinutes: Double {
        Double(actualDurationSeconds) / 60.0
    }
}
