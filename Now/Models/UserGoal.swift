import SwiftData
import Foundation

@Model
final class UserGoal {
    var id: UUID
    var dailyGoalMinutes: Int
    var createdDate: Date
    var modifiedDate: Date

    init(dailyGoalMinutes: Int = 8) {
        self.id = UUID()
        self.dailyGoalMinutes = dailyGoalMinutes
        self.createdDate = Date()
        self.modifiedDate = Date()
    }
}
