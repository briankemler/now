import XCTest
@testable import Now

final class TimerServiceTests: XCTestCase {
    var sut: TimerService!

    override func setUp() {
        super.setUp()
        sut = TimerService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(sut.state, .idle)
        XCTAssertEqual(sut.remainingSeconds, 0)
        XCTAssertEqual(sut.elapsedSeconds, 0)
    }

    func testStartSetsRunning() {
        sut.start(duration: 480)
        XCTAssertEqual(sut.state, .running)
        XCTAssertEqual(sut.remainingSeconds, 480)
        XCTAssertEqual(sut.elapsedSeconds, 0)
    }

    func testPauseFromRunning() {
        sut.start(duration: 300)
        sut.pause()
        XCTAssertEqual(sut.state, .paused)
    }

    func testPauseFromIdle() {
        sut.pause()
        XCTAssertEqual(sut.state, .idle)
    }

    func testResumeFromPaused() {
        sut.start(duration: 300)
        sut.pause()
        sut.resume()
        XCTAssertEqual(sut.state, .running)
    }

    func testStopReturnsElapsed() {
        sut.start(duration: 300)
        let elapsed = sut.stop()
        XCTAssertGreaterThanOrEqual(elapsed, 0)
        XCTAssertEqual(sut.state, .idle)
    }

    func testProgressCalculation() {
        sut.start(duration: 100)
        XCTAssertEqual(sut.progress, 0.0, accuracy: 0.01)
    }

    func testProgressWithZeroDuration() {
        XCTAssertEqual(sut.progress, 0.0)
    }

    func testRecalculateAfterBackgroundDoesNothingWhenIdle() {
        sut.recalculateAfterBackground()
        XCTAssertEqual(sut.state, .idle)
    }
}
