import XCTest
@testable import Now

final class ModelTests: XCTestCase {

    // MARK: - MeditationSession Tests

    func testMeditationSessionInit() {
        let date = Date()
        let session = MeditationSession(startDate: date, durationSeconds: 480)

        XCTAssertEqual(session.durationSeconds, 480)
        XCTAssertEqual(session.actualDurationSeconds, 0)
        XCTAssertFalse(session.completed)
        XCTAssertFalse(session.syncedToHealthKit)
        XCTAssertEqual(session.source, .iPhone)
        XCTAssertNil(session.watchSessionID)
        XCTAssertEqual(session.startDate, date)
    }

    func testMeditationSessionActualMinutes() {
        let session = MeditationSession(startDate: Date(), durationSeconds: 480)
        session.actualDurationSeconds = 360
        XCTAssertEqual(session.actualMinutes, 6.0, accuracy: 0.01)
    }

    func testMeditationSessionZeroMinutes() {
        let session = MeditationSession(startDate: Date(), durationSeconds: 480)
        XCTAssertEqual(session.actualMinutes, 0.0)
    }

    func testMeditationSessionWatchSource() {
        let session = MeditationSession(startDate: Date(), durationSeconds: 480, source: .appleWatch)
        XCTAssertEqual(session.source, .appleWatch)
    }

    // MARK: - UserGoal Tests

    func testUserGoalDefaultMinutes() {
        let goal = UserGoal()
        XCTAssertEqual(goal.dailyGoalMinutes, 8)
    }

    func testUserGoalCustomMinutes() {
        let goal = UserGoal(dailyGoalMinutes: 15)
        XCTAssertEqual(goal.dailyGoalMinutes, 15)
    }

    // MARK: - StreakRecord Tests

    func testStreakRecordInit() {
        let date = Date()
        let record = StreakRecord(date: date, totalMinutes: 10, goalMet: true)

        XCTAssertEqual(record.totalMinutes, 10)
        XCTAssertTrue(record.goalMet)
        XCTAssertFalse(record.frozenSkip)
    }

    func testStreakRecordNormalizesDate() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 15
        components.minute = 30
        let midAfternoon = calendar.date(from: components)!

        let record = StreakRecord(date: midAfternoon)
        let startOfDay = calendar.startOfDay(for: midAfternoon)
        XCTAssertEqual(record.date, startOfDay)
    }

    // MARK: - AppSettings Tests

    func testAppSettingsDefaults() {
        let settings = AppSettings()

        XCTAssertFalse(settings.hasCompletedOnboarding)
        XCTAssertTrue(settings.notificationEnabled)
        XCTAssertEqual(settings.notificationHour, 8)
        XCTAssertEqual(settings.notificationMinute, 0)
        XCTAssertTrue(settings.soundEnabled)
        XCTAssertTrue(settings.vibrationEnabled)
        XCTAssertFalse(settings.healthKitAuthorized)
        XCTAssertEqual(settings.lastSelectedDuration, 480)
        XCTAssertEqual(settings.intervalBellMinutes, 0)
        XCTAssertTrue(settings.streakFreezeAvailable)
        XCTAssertNil(settings.streakFreezeLastReset)
    }

    // MARK: - SyncPayload Tests

    func testSessionSyncPayloadEncoding() throws {
        let payload = SessionSyncPayload(
            sessionID: "test-123",
            startDate: Date(),
            endDate: Date().addingTimeInterval(480),
            durationSeconds: 480,
            actualDurationSeconds: 480,
            completed: true,
            source: "iPhone"
        )

        let data = try JSONEncoder().encode(payload)
        let decoded = try JSONDecoder().decode(SessionSyncPayload.self, from: data)

        XCTAssertEqual(decoded.sessionID, "test-123")
        XCTAssertEqual(decoded.durationSeconds, 480)
        XCTAssertTrue(decoded.completed)
    }

    func testGoalSyncPayloadEncoding() throws {
        let payload = GoalSyncPayload(
            dailyGoalMinutes: 8,
            currentStreak: 5,
            todayMinutes: 6.5
        )

        let data = try JSONEncoder().encode(payload)
        let decoded = try JSONDecoder().decode(GoalSyncPayload.self, from: data)

        XCTAssertEqual(decoded.dailyGoalMinutes, 8)
        XCTAssertEqual(decoded.currentStreak, 5)
        XCTAssertEqual(decoded.todayMinutes, 6.5, accuracy: 0.01)
    }
}
