import XCTest
@testable import Focusly

final class TimerManagerTests: XCTestCase {
    var settings: Settings!
    var timerManager: TimerManager!
    var posted: [String] = []
    var defaults: UserDefaults!
    let suiteName = "FocuslyTests.TimerManager"

    override func setUp() {
        super.setUp()
        posted = []
        Notifier.post = { [unowned self] in self.posted.append($0.identifier) }
        settings = Settings()
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
        timerManager = TimerManager(settings: settings, defaults: defaults)
    }

    override func tearDown() {
        timerManager.stop()
        timerManager = nil
        settings = nil
        defaults.removePersistentDomain(forName: suiteName)
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

    func testStartRemembersTaskAtFrontWithoutDuplicatesCappedAtFive() {
        for name in ["a", "b", "c", "d", "e", "f", " b "] {
            timerManager.task = name
            timerManager.start()
            timerManager.stop()
        }
        XCTAssertEqual(timerManager.recentTasks, ["b", "f", "e", "d", "c"])
        XCTAssertEqual(TimerManager(settings: settings, defaults: defaults).recentTasks, timerManager.recentTasks)
    }

    func testStoppingAFocusBlockAsksWhereYouLeftOff() {
        timerManager.start()
        timerManager.stop()
        XCTAssertTrue(timerManager.awaitingNote)
        timerManager.saveNote("  wire the runway  ")
        XCTAssertFalse(timerManager.awaitingNote)
        XCTAssertEqual(TimerManager(settings: settings, defaults: defaults).lastNote, "wire the runway")
    }

    func testStopWhileIdleDoesNotAskForANote() {
        timerManager.stop()
        XCTAssertFalse(timerManager.awaitingNote)
    }
}
