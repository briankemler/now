import XCTest
@testable import Now

final class StreakServiceTests: XCTestCase {
    var sut: StreakService!
    let calendar = Calendar.current

    override func setUp() {
        super.setUp()
        sut = StreakService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testEmptyRecordsReturnsZeroStreak() {
        let streak = sut.calculateCurrentStreak(records: [])
        XCTAssertEqual(streak, 0)
    }

    func testSingleDayStreak() {
        let today = calendar.startOfDay(for: Date())
        let record = StreakRecord(date: today, totalMinutes: 8, goalMet: true)
        let streak = sut.calculateCurrentStreak(records: [record])
        XCTAssertEqual(streak, 1)
    }

    func testConsecutiveDayStreak() {
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

        let records = [
            StreakRecord(date: today, totalMinutes: 10, goalMet: true),
            StreakRecord(date: yesterday, totalMinutes: 8, goalMet: true),
            StreakRecord(date: twoDaysAgo, totalMinutes: 8, goalMet: true)
        ]
        let streak = sut.calculateCurrentStreak(records: records)
        XCTAssertEqual(streak, 3)
    }

    func testBrokenStreak() {
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!

        let records = [
            StreakRecord(date: today, totalMinutes: 10, goalMet: true),
            // Day -1 missing (yesterday not met)
            StreakRecord(date: threeDaysAgo, totalMinutes: 8, goalMet: true)
        ]
        let streak = sut.calculateCurrentStreak(records: records)
        XCTAssertEqual(streak, 1) // Only today counts
    }

    func testGoalNotMet() {
        let today = calendar.startOfDay(for: Date())
        let record = StreakRecord(date: today, totalMinutes: 3, goalMet: false)
        let streak = sut.calculateCurrentStreak(records: [record])
        XCTAssertEqual(streak, 0)
    }

    func testFrozenSkipCountsAsStreak() {
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let todayRecord = StreakRecord(date: today, totalMinutes: 8, goalMet: true)
        let frozenRecord = StreakRecord(date: yesterday, totalMinutes: 0, goalMet: true)
        frozenRecord.frozenSkip = true

        let records = [todayRecord, frozenRecord]
        let streak = sut.calculateCurrentStreak(records: records)
        XCTAssertEqual(streak, 2)
    }
}
