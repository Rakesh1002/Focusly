import XCTest
@testable import Focusly

final class WindowReconcileTests: XCTestCase {
    func testUnplugTwoOfThreeDisplaysClosesTheirWindows() {
        let diff = WindowManager.reconcile(existing: [1, 2, 3], targets: [1])
        XCTAssertEqual(diff.close, [2, 3])
        XCTAssertEqual(diff.create, [])
    }

    func testPlugInDisplayCreatesOnlyTheNewWindow() {
        let diff = WindowManager.reconcile(existing: [1], targets: [1, 4])
        XCTAssertEqual(diff.close, [])
        XCTAssertEqual(diff.create, [4])
    }

    func testClampBringsAnOffScreenAnchorBackInside() {
        let screen = NSRect(x: 0, y: 0, width: 1512, height: 982)
        let saved = NSRect(x: 2400, y: 1300, width: 200, height: 50)
        XCTAssertEqual(WindowManager.clamp(saved, into: screen), NSPoint(x: 1312, y: 932))
    }

    func testClampLeavesAnOnScreenAnchorAlone() {
        let screen = NSRect(x: -1920, y: 0, width: 1920, height: 1080)
        let anchor = NSRect(x: -900, y: 400, width: 200, height: 50)
        XCTAssertEqual(WindowManager.clamp(anchor, into: screen), anchor.origin)
    }
}
