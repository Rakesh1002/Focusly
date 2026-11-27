import XCTest
@testable import Focusly

final class AgentSetupTests: XCTestCase {
    func testShippedSettingsMatchEachTool() throws {
        XCTAssertEqual(CodingAgent.claude.inspect(Data(AgentHooks.claudeCode.utf8)), .installed)
        XCTAssertEqual(CodingAgent.cursor.inspect(Data(AgentHooks.cursor.utf8)), .installed)
        XCTAssertEqual(CodingAgent.codex.inspect(try CodexHooks.mergedConfig(nil)), .installed)
        for agent in CodingAgent.allCases {
            XCTAssertEqual(agent.inspect(Data(#"{"hooks":{}}"#.utf8)), .missing)
            XCTAssertEqual(agent.inspect(Data("bad".utf8)), .invalid)
        }
    }

    func testPartialDisabledAndUnrelatedHooks() throws {
        let partial = #"{"version":1,"hooks":{"stop":[{"command":"open -g 'focusly://agent?name=Cursor&state=done'"}]}}"#
        XCTAssertEqual(CodingAgent.cursor.inspect(Data(partial.utf8)), .partial(1, 2))
        for changed in [partial.replacingOccurrences(of: "name=Cursor", with: "name=Claude"),
                        partial.replacingOccurrences(of: "open -g", with: "echo")] {
            XCTAssertEqual(CodingAgent.cursor.inspect(Data(changed.utf8)), .missing)
        }
        let disabled = AgentHooks.claudeCode.replacingOccurrences(of: #""hooks": {"#, with: #""disableAllHooks":true,"hooks":{"#)
        XCTAssertEqual(CodingAgent.claude.inspect(Data(disabled.utf8)), .disabled)
        XCTAssertEqual(CodingAgent.codex.inspect(Data(#"{"hooks":{"Stop":"bad"}}"#.utf8)), .invalid)
    }

    func testRealSignalsPersistPerAgentAndTestDoesNotInterruptWork() {
        let suite = "FocuslyTests.AgentSetup." + UUID().uuidString
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        let watch = AgentWatch(defaults: defaults)
        for agent in [CodingAgent.claude, .codex] {
            watch.handle(url: URL(string: "focusly://agent?state=working&name=" + agent.eventName)!)
        }
        let signals = watch.lastSignals
        watch.handle(url: URL(string: "focusly://agent?state=done&name=Test")!)
        XCTAssertEqual(Set(signals.keys), ["Codex", "Claude Code"])
        XCTAssertNotNil(watch.lastLinkTest)
        XCTAssertEqual(watch.name, "Codex")
        XCTAssertEqual(watch.state, .working)
        XCTAssertEqual(signals, watch.lastSignals)
        XCTAssertEqual(AgentWatch(defaults: defaults).lastSignals, signals)
    }
}
