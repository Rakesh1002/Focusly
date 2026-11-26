import Foundation

enum CodingAgent: String, CaseIterable, Identifiable {
    case claude = "Claude Code", codex = "Codex", cursor = "Cursor"

    var id: Self { self }
    var eventName: String { self == .claude ? "Claude" : rawValue }
    var fileName: String { self == .claude ? "settings.json" : "hooks.json" }
    var folderName: String { "." + eventName.lowercased() }

    var defaultFolder: URL {
        if self == .codex, let path = ProcessInfo.processInfo.environment["CODEX_HOME"], path.hasPrefix("/") {
            return URL(fileURLWithPath: path, isDirectory: true)
        }
        // A sandboxed app's Foundation home can point inside its container.
        let home = getpwuid(getuid()).flatMap { $0.pointee.pw_dir }.map { String(cString: $0) }
        return URL(fileURLWithPath: home ?? NSHomeDirectory(), isDirectory: true).appendingPathComponent(folderName)
    }

    var snippet: String? {
        switch self {
        case .claude: return AgentHooks.claudeCode
        case .cursor: return AgentHooks.cursor
        case .codex: return nil
        }
    }

    private func commands(_ groups: [[String: Any]]) -> [String] {
        if self == .cursor { return groups.compactMap { $0["command"] as? String } }
        return groups.flatMap { group -> [String] in
            if let matcher = group["matcher"] as? String, !["", "*"].contains(matcher) { return [] }
            let entries = group["hooks"] as? [[String: Any]] ?? []
            return entries.filter { $0["type"] as? String == "command" }.compactMap { $0["command"] as? String }
        }
    }

    // Recognize direct URL hooks even if a user omitted the project or reordered query items.
    // Only the command that opens the URL counts; comments and echo commands cannot send events.
    private static let directOpen = try! NSRegularExpression(
        pattern: #"^\s*(?:/usr/bin/)?open\s+(?:(?:-g|-j|-b\s+unquest\.focusly)\s+)*["']?(focusly://agent\?[^"'\s]+)["']?\s*$"#)

    private func directSignal(_ command: String) -> String? {
        let range = NSRange(command.startIndex..., in: command)
        guard let match = Self.directOpen.firstMatch(in: command, range: range),
              let url = Range(match.range(at: 1), in: command),
              let items = URLComponents(string: String(command[url]))?.queryItems,
              items.first(where: { $0.name == "name" })?.value == eventName else { return nil }
        return items.first(where: { $0.name == "state" })?.value
    }

    func inspect(_ data: Data) -> HookInstallation {
        guard let document = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
              let hooks = (document["hooks"] ?? [:]) as? [String: Any] else { return .invalid }
        if self == .claude && document["disableAllHooks"] as? Bool == true { return .disabled }
        if self == .cursor, !hooks.isEmpty, document["version"] as? Int != 1 { return .invalid }

        let expected: [String: String]
        if let snippet {
            // Read the same template the Copy button supplies.
            guard let template = (try? JSONSerialization.jsonObject(with: Data(snippet.utf8))) as? [String: Any],
                  let events = template["hooks"] as? [String: [[String: Any]]] else { return .invalid }
            expected = events.compactMapValues { commands($0).first }
        } else {
            expected = Dictionary(uniqueKeysWithValues: CodexHooks.events.map { ($0.name, CodexHooks.command(for: $0.state)) })
        }
        var found = 0
        for (event, command) in expected {
            guard let groups = (hooks[event] ?? []) as? [[String: Any]] else { return .invalid }
            let state = self == .codex ? CodexHooks.events.first { $0.name == event }?.state : directSignal(command)
            if commands(groups).contains(where: { $0 == command || (state != nil && directSignal($0) == state) }) {
                found += 1
            }
        }
        if found == 0 { return .missing }
        return found == expected.count ? .installed : .partial(found, expected.count)
    }
}

enum HookInstallation: Equatable {
    case needsAccess, missing, installed, partial(Int, Int), legacyNotify, disabled, invalid, unreadable

    var title: String {
        switch self {
        case .needsAccess: return "Access needed to check"
        case .missing: return "Not installed"
        case .installed: return "Hooks installed"
        case .legacyNotify: return "Completion hook only"
        case let .partial(found, total): return "\(found) of \(total) hooks installed"
        case .disabled: return "Hooks disabled"
        case .invalid: return "Invalid config"
        case .unreadable: return "Couldn’t read config"
        }
    }
}

struct AgentSetupFiles {
    var defaults: UserDefaults = .app
    static let legacyNotify = #"""
    notify = ["bash", "-lc", "open -g \"focusly://agent?state=done&name=Codex&project=${PWD##*/}&app=${__CFBundleIdentifier}\""]
    """#

    private func key(_ agent: CodingAgent) -> String { "hookFolder." + agent.rawValue }

    func hasSelectedFolder(for agent: CodingAgent) -> Bool { defaults.data(forKey: key(agent)) != nil }

    func remember(_ folder: URL, for agent: CodingAgent) throws {
        var options: URL.BookmarkCreationOptions = [.withSecurityScope]
        if agent != .codex { options.insert(.securityScopeAllowOnlyReadAccess) }
        defaults.set(try folder.bookmarkData(options: options, includingResourceValuesForKeys: nil, relativeTo: nil), forKey: key(agent))
    }

    func withFolder<T>(for agent: CodingAgent, _ action: (URL) throws -> T) throws -> T {
        guard let bookmark = defaults.data(forKey: key(agent)) else { return try action(agent.defaultFolder) }
        var stale = false
        let folder = try URL(resolvingBookmarkData: bookmark, options: [.withSecurityScope, .withoutUI],
                             relativeTo: nil, bookmarkDataIsStale: &stale)
        let scoped = folder.startAccessingSecurityScopedResource()
        defer { if scoped { folder.stopAccessingSecurityScopedResource() } }
        if stale { try remember(folder, for: agent) }
        return try action(folder)
    }

    func status(for agent: CodingAgent) -> HookInstallation {
        do {
            return try withFolder(for: agent) { folder in
                let installation: HookInstallation
                do { installation = agent.inspect(try Data(contentsOf: folder.appendingPathComponent(agent.fileName))) }
                catch let error as CocoaError where error.code == .fileReadNoSuchFile { installation = .missing }
                if agent == .codex, installation == .missing,
                   let config = try? String(contentsOf: folder.appendingPathComponent("config.toml"), encoding: .utf8),
                   config.split(separator: "\n").map({ $0.trimmingCharacters(in: .whitespaces) })
                    .prefix(while: { !$0.hasPrefix("[") }).contains(Self.legacyNotify) { return .legacyNotify }
                return installation
            }
        } catch let error as CocoaError where error.code == .fileReadNoPermission || error.code == .fileNoSuchFile || error.code == .fileReadNoSuchFile {
            return .needsAccess
        } catch { return .unreadable }
    }
}
