import SwiftData
import Foundation

@Model
final class AppSettings {
    var id: UUID
    var hasCompletedOnboarding: Bool
    var notificationEnabled: Bool
    var notificationHour: Int
    var notificationMinute: Int
    var soundEnabled: Bool
    var vibrationEnabled: Bool
    var healthKitAuthorized: Bool
    var lastSelectedDuration: Int
    var intervalBellMinutes: Int
    var streakFreezeAvailable: Bool
    var streakFreezeLastReset: Date?

    init() {
        self.id = UUID()
        self.hasCompletedOnboarding = false
        self.notificationEnabled = true
        self.notificationHour = 8
        self.notificationMinute = 0
        self.soundEnabled = true
        self.vibrationEnabled = true
        self.healthKitAuthorized = false
        self.lastSelectedDuration = 480
        self.intervalBellMinutes = 0
        self.streakFreezeAvailable = true
        self.streakFreezeLastReset = nil
    }
}
