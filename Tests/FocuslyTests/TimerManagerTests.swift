import XCTest
@testable import Focusly

final class TimerManagerTests: XCTestCase {
    var settings: Settings!
    var timerManager: TimerManager!

    override func setUp() {
        super.setUp()
        settings = Settings()
        timerManager = TimerManager(settings: settings)
    }

    override func tearDown() {
        timerManager.stop()
        timerManager = nil
        settings = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertFalse(timerManager.isRunning)
        XCTAssertFalse(timerManager.isBreakTime)
        XCTAssertEqual(timerManager.currentCycle, 0)
        XCTAssertEqual(timerManager.remainingTime, settings.workDuration)
    }

    func testStartSetsRunning() {
        timerManager.start()
        XCTAssertTrue(timerManager.isRunning)
        XCTAssertFalse(timerManager.isBreakTime)
    }

    func testStopClearsRunning() {
        timerManager.start()
        timerManager.stop()
        XCTAssertFalse(timerManager.isRunning)
    }

    func testStartIsIdempotent() {
        timerManager.start()
        let firstRemaining = timerManager.remainingTime
        timerManager.start()
        XCTAssertTrue(timerManager.isRunning)
        XCTAssertEqual(timerManager.remainingTime, firstRemaining)
    }

    func testStopResetsBreakOverlayWhenInBreak() {
        timerManager.start()
        timerManager.isBreakTime = true
        timerManager.stop()
        XCTAssertFalse(timerManager.isBreakTime)
        XCTAssertEqual(timerManager.remainingTime, settings.workDuration)
    }
}
