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
}
