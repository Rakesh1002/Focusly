import SwiftUI
import XCTest
@testable import Focusly

final class TimeDisplayLayoutTests: XCTestCase {
    @MainActor
    func testTimerMatchesMenuWidthWithAndWithoutAgentActivity() {
        _ = NSApplication.shared
        let suite = "FocuslyTests.Layout." + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let settings = Settings(defaults: defaults)
        let timer = TimerManager(settings: settings, defaults: defaults)
        timer.isRunning = true
        timer.task = "Build this week's proof with a long task title"
        let calendar = CalendarManager()
        let watch = AgentWatch()
        func size<V: View>(_ view: V) -> NSSize {
            NSHostingView(rootView: view
                .environmentObject(settings)
                .environmentObject(timer)
                .environmentObject(calendar)
                .environmentObject(watch)
                .environmentObject(FocusMonitor())
                .environmentObject(SoundManager())).fittingSize
        }
        let menu = size(MenuBarView())
        let compact = size(TimeDisplayWindow())
        watch.apply(.init(state: .working, name: "Codex", project: "Focusly"), frontmost: nil)
        let working = size(TimeDisplayWindow())
        XCTAssertEqual(compact.width, menu.width)
        XCTAssertEqual(working.width, menu.width)
        XCTAssertGreaterThan(working.height, compact.height)
        XCTAssertLessThan(working.height, menu.height)
        settings.miniFloatingTimer = true
        let mini = size(TimeDisplayWindow())
        XCTAssertLessThan(mini.width, working.width)
        XCTAssertLessThan(mini.height, compact.height)
        XCTAssertTrue(Settings(defaults: defaults).miniFloatingTimer)
        settings.miniFloatingTimer = false
        XCTAssertEqual(size(TimeDisplayWindow()), working)
    }
}
