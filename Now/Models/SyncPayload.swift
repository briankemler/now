import Foundation

struct SessionSyncPayload: Codable {
    let sessionID: String
    let startDate: Date
    let endDate: Date
    let durationSeconds: Int
    let actualDurationSeconds: Int
    let completed: Bool
    let source: String
}

struct GoalSyncPayload: Codable {
    let dailyGoalMinutes: Int
    let currentStreak: Int
    let todayMinutes: Double
}
