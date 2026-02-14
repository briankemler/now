import XCTest
@testable import Now

final class ExtensionTests: XCTestCase {

    // MARK: - TimeInterval+Formatting Tests

    func testMinutesSecondsFormatting() {
        XCTAssertEqual(TimeInterval(480).minutesSeconds, "8:00")
        XCTAssertEqual(TimeInterval(65).minutesSeconds, "1:05")
        XCTAssertEqual(TimeInterval(0).minutesSeconds, "0:00")
        XCTAssertEqual(TimeInterval(3599).minutesSeconds, "59:59")
    }

    func testIntAsMinutesSeconds() {
        XCTAssertEqual(480.asMinutesSeconds, "8:00")
        XCTAssertEqual(65.asMinutesSeconds, "1:05")
        XCTAssertEqual(0.asMinutesSeconds, "0:00")
    }

    func testIntAsMinutesFormatted() {
        XCTAssertEqual(60.asMinutesFormatted, "1 min")
        XCTAssertEqual(480.asMinutesFormatted, "8 min")
        XCTAssertEqual(1800.asMinutesFormatted, "30 min")
    }

    // MARK: - Date+Extensions Tests

    func testStartOfDay() {
        let date = Date()
        let startOfDay = date.startOfDay
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: startOfDay)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }

    func testIsToday() {
        XCTAssertTrue(Date().isToday)
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        XCTAssertFalse(yesterday.isToday)
    }

    func testIsYesterday() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        XCTAssertTrue(yesterday.isYesterday)
        XCTAssertFalse(Date().isYesterday)
    }

    func testDaysBetween() {
        let today = Date()
        let threeDaysLater = Calendar.current.date(byAdding: .day, value: 3, to: today)!
        XCTAssertEqual(today.daysBetween(threeDaysLater), 3)
    }

    func testAddingDays() {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = today.adding(days: 1)
        let expected = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        XCTAssertEqual(
            Calendar.current.startOfDay(for: tomorrow),
            Calendar.current.startOfDay(for: expected)
        )
    }
}
