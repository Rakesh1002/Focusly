import XCTest
@testable import Focusly

final class CodexHooksTests: XCTestCase {
    func testInstallPreservesOtherHooksAndIsRepeatable() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let file = folder.appendingPathComponent("hooks.json")
        let other = #"{"hooks":[{"type":"command","command":"echo other"}]}"#
        try Data(#"{"extra":true,"hooks":{"Stop":[\#(other)],"SessionStart":[\#(other)]}}"#.utf8).write(to: file)
        try CodexHooks.install(in: folder)
        let installed = try Data(contentsOf: file)
        let document = try XCTUnwrap(JSONSerialization.jsonObject(with: installed) as? [String: Any])
        let hooks = try XCTUnwrap(document["hooks"] as? [String: [[String: [[String: String]]]]])
        XCTAssertEqual(document["extra"] as? Bool, true)
        XCTAssertEqual(hooks["SessionStart"]?.first, hooks["Stop"]?.first)
        XCTAssertEqual(hooks["Stop"]?.first?["hooks"]?.first?["command"], "echo other")
        XCTAssertEqual(hooks["Stop"]?.count, 2)
        for (event, state) in [("UserPromptSubmit", "working"), ("Stop", "done"), ("Interrupt", "done")] {
            XCTAssertEqual(hooks[event]?.last?["hooks"]?.first?["command"], CodexHooks.command(for: state))
        }
        try CodexHooks.install(in: folder)
        XCTAssertEqual(try Data(contentsOf: file), installed)
    }

    func testCreatesMissingFileAndRejectsInvalidConfig() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let file = folder.appendingPathComponent("hooks.json")
        try CodexHooks.install(in: folder)
        XCTAssertEqual(try Data(contentsOf: file), try CodexHooks.mergedConfig(nil))
        for invalid in ["{", "[]", #"{"hooks":{"Stop":false}}"#] {
            let bytes = Data(invalid.utf8)
            try bytes.write(to: file)
            XCTAssertThrowsError(try CodexHooks.install(in: folder))
            XCTAssertEqual(try Data(contentsOf: file), bytes)
        }
    }

    func testHookEncodesTheProjectFromTheCodexEvent() throws {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/sh")
        // Substitute only the final URL opener so this test can observe its actual arguments.
        let command = CodexHooks.command(for: "working").replacingOccurrences(of: #""/usr/bin/open""#, with: #""/bin/echo""#)
        task.arguments = ["-c", command]
        task.environment = ["__CFBundleIdentifier": "com.apple.Terminal"]
        let input = Pipe(), output = Pipe()
        task.standardInput = input
        task.standardOutput = output
        try task.run()
        input.fileHandleForWriting.write(Data(#"{"cwd":"/tmp/Café & #1"}"#.utf8))
        try input.fileHandleForWriting.close()
        task.waitUntilExit()
        XCTAssertEqual(task.terminationStatus, 0)
        let args = String(decoding: output.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        let url = try XCTUnwrap(URL(string: try XCTUnwrap(args.split(separator: " ").last).trimmingCharacters(in: .whitespacesAndNewlines)))
        XCTAssertEqual(AgentWatch.parse(url), .init(state: .working, name: "Codex", project: "Café & #1", app: "com.apple.Terminal"))
    }
}
