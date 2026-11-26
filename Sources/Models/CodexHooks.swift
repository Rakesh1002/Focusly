import Foundation

enum CodexHooks {
    static let events = [
        (name: "UserPromptSubmit", state: "working"),
        (name: "Stop", state: "done"),
        (name: "Interrupt", state: "done")
    ]

    // The hook receives the turn's working directory as JSON on stdin. Encode URL values
    // before invoking LaunchServices, including when a project contains spaces or '&'.
    static func command(for state: String) -> String {
        #"""
        /usr/bin/perl -MJSON::PP -MURI::Escape=uri_escape_utf8 -MFile::Basename=basename -0777 -ne 'my $project = basename(decode_json($_)->{cwd}); exec "/usr/bin/open", "-g", "-b", "unquest.focusly", "focusly://agent?state=\#(state)&name=Codex&project=" . uri_escape_utf8($project) . "&app=" . uri_escape_utf8($ENV{__CFBundleIdentifier} // "") or die $!'
        """#
    }

    private static let label = "Updating Focusly"

    enum InstallError: LocalizedError {
        case invalidConfig, changedDuringInstall
        var errorDescription: String? {
            switch self {
            case .invalidConfig: return "The existing hooks.json has an unexpected format. Check the file and try again."
            case .changedDuringInstall: return "Another app changed hooks.json during installation. Try installing again."
            }
        }
    }

    static func mergedConfig(_ original: Data?) throws -> Data {
        let parsed = try original.map { try JSONSerialization.jsonObject(with: $0) } ?? [:]
        guard var document = parsed as? [String: Any],
              var hooks = (document["hooks"] ?? [:]) as? [String: Any] else { throw InstallError.invalidConfig }
        var changed = false
        for event in events {
            guard var groups = (hooks[event.name] ?? []) as? [[String: Any]] else { throw InstallError.invalidConfig }
            let handler = ["type": "command", "command": command(for: event.state), "statusMessage": label]
            // Keep other tools' positions stable. Codex keys hook approvals by array index.
            if let index = groups.firstIndex(where: { group in
                guard group.count == 1, let entries = group["hooks"] as? [[String: Any]], entries.count == 1,
                      let command = entries[0]["command"] as? String else { return false }
                return entries[0]["statusMessage"] as? String == label && command.contains("focusly://agent?")
            }) {
                if let existing = groups[index]["hooks"] as? [[String: String]], existing == [handler] { continue }
                groups[index]["hooks"] = [handler]
            } else {
                groups.append(["hooks": [handler]])
            }
            hooks[event.name] = groups
            changed = true
        }
        if !changed, let original { return original }
        document["hooks"] = hooks
        var data = try JSONSerialization.data(withJSONObject: document, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        data.append(0x0a)
        return data
    }

    static func install(in directory: URL) throws {
        let url = directory.appendingPathComponent("hooks.json").resolvingSymlinksInPath()
        func currentData() throws -> Data? {
            do { return try Data(contentsOf: url) }
            catch let error as CocoaError where error.code == .fileReadNoSuchFile { return nil }
        }
        let original = try currentData()
        let updated = try mergedConfig(original)
        guard updated != original else { return }
        guard try currentData() == original else { throw InstallError.changedDuringInstall }
        try updated.write(to: url, options: .atomic)
    }
}
