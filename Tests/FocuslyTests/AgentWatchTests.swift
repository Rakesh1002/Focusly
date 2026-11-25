import AppKit
import XCTest
@testable import Focusly

final class AgentWatchTests: XCTestCase {
    var posted: [String] = []

    override func setUp() {
        super.setUp()
        posted = []
        Notifier.post = { [unowned self] in self.posted.append($0.content.title) }
    }

    func testParsesAValidAgentURL() {
        let event = AgentWatch.parse(URL(string: "focusly://agent?state=done&name=Claude&project=focusly")!)
        XCTAssertEqual(event, AgentWatch.Event(state: .done, name: "Claude", project: "focusly"))
    }

    func testRejectsMissingOrUnknownState() {
        XCTAssertNil(AgentWatch.parse(URL(string: "focusly://agent?name=Claude")!))
        XCTAssertNil(AgentWatch.parse(URL(string: "focusly://agent?state=sleeping")!))
    }

    func testRejectsUnknownHostOrScheme() {
        XCTAssertNil(AgentWatch.parse(URL(string: "focusly://timer?state=done")!))
        XCTAssertNil(AgentWatch.parse(URL(string: "other://agent?state=done")!))
    }

    func testDefaultsNameWhenMissing() {
        XCTAssertEqual(AgentWatch.parse(URL(string: "focusly://agent?state=working")!)?.name, "Agent")
    }

    func testWorkingThenDoneElsewhereAlerts() {
        let watch = AgentWatch()
        watch.apply(AgentWatch.Event(state: .working, name: "Claude", project: "focusly"), frontmost: nil)
        XCTAssertEqual(watch.state, .working)
        watch.apply(AgentWatch.Event(state: .done, name: "Claude", project: "focusly"), frontmost: nil)
        XCTAssertEqual(watch.state, .done)
        XCTAssertEqual(posted, ["Claude finished in focusly"])
    }

    func testDoneWhileAlreadyInTheOriginAppClearsQuietly() throws {
        let dock = try XCTUnwrap(NSWorkspace.shared.runningApplications.first { $0.bundleIdentifier == "com.apple.dock" })
        let watch = AgentWatch()
        watch.apply(AgentWatch.Event(state: .working, name: "Claude", project: ""), frontmost: dock)
        watch.apply(AgentWatch.Event(state: .done, name: "Claude", project: ""), frontmost: dock)
        XCTAssertNil(watch.state)
        XCTAssertEqual(posted, [])
    }

    func testStripsBidiAndControlCharactersAndCapsLength() {
        let spoof = AgentWatch.parse(URL(string: "focusly://agent?state=done&name=%E2%80%AEevil%0A")!)
        XCTAssertEqual(spoof?.name, "evil")
        let long = AgentWatch.parse(URL(string: "focusly://agent?state=done&project=\(String(repeating: "a", count: 500))")!)
        XCTAssertEqual(long?.project.count, 60)
    }

    func testHookSuppliedAppIsTheWayBackWithoutAWorkingEvent() throws {
        let dock = try XCTUnwrap(NSWorkspace.shared.runningApplications.first { $0.bundleIdentifier == "com.apple.dock" })
        let watch = AgentWatch()
        watch.apply(AgentWatch.Event(state: .done, name: "Codex", project: "", app: "com.apple.dock"), frontmost: dock)
        XCTAssertNil(watch.state)
        XCTAssertEqual(posted, [])
    }

    func testCopiedHookSnippetsAreValidJSON() throws {
        for snippet in [AgentHooks.claudeCode, AgentHooks.cursor] {
            XCTAssertNoThrow(try JSONSerialization.jsonObject(with: Data(snippet.utf8)))
        }
    }
}
