import XCTest
@testable import Focusly

final class TimerManagerTests: XCTestCase {
    var settings: Settings!
    var timerManager: TimerManager!
    var posted: [String] = []

    override func setUp() {
        super.setUp()
        posted = []
        Notifier.post = { [unowned self] in self.posted.append($0.identifier) }
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

    func testBreakEndingLeavesTimerStoppedAndReady() {
        timerManager.start()
        timerManager.handleTimerComplete()
        XCTAssertTrue(timerManager.isBreakTime)
        XCTAssertTrue(timerManager.isRunning)
        XCTAssertEqual(timerManager.remainingTime, settings.breakDuration)

        posted = []
        timerManager.handleTimerComplete()
        XCTAssertFalse(timerManager.isRunning)
        XCTAssertFalse(timerManager.isBreakTime)
        XCTAssertEqual(timerManager.remainingTime, settings.workDuration)
        if settings.breakNotifications {
            XCTAssertEqual(posted, ["breakComplete"])
        }
    }
}
