import AppKit
import Combine

/// Tracks a coding agent (Claude Code, Codex, Cursor) through `focusly://agent?state=&name=&project=` URLs
/// sent by its hooks, and pulls the user back to it when it finishes or needs input.
// shortcut: one slot, so parallel agents show only the latest; move to per-project slots if users run several.
final class AgentWatch: ObservableObject {
    enum State: String {
        case working, waiting, done
    }

    struct Event: Equatable {
        let state: State
        let name: String
        let project: String
    }

    static let notificationID = "agent"

    @Published private(set) var state: State?
    @Published private(set) var name = ""
    @Published private(set) var project = ""
    @Published private(set) var since: Date?

    var soundManager: SoundManager?
    weak var focusMonitor: FocusMonitor?
    private var origin: NSRunningApplication?
    private var activationObserver: NSObjectProtocol?

    init() {
        activationObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let self, self.state == .done || self.state == .waiting,
                  let app = note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
                  app.processIdentifier == self.origin?.processIdentifier else { return }
            self.clear()
        }
    }

    deinit {
        if let activationObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(activationObserver)
        }
    }

    static func parse(_ url: URL) -> Event? {
        guard url.scheme == "focusly", url.host == "agent",
              let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
              let state = items.first(where: { $0.name == "state" })?.value.flatMap(State.init) else { return nil }
        func value(_ key: String) -> String? {
            items.first(where: { $0.name == key })?.value.flatMap { $0.isEmpty ? nil : $0 }
        }
        return Event(state: state, name: value("name") ?? "Agent", project: value("project") ?? "")
    }

    func handle(url: URL) {
        guard let event = Self.parse(url) else { return }
        apply(event, frontmost: NSWorkspace.shared.frontmostApplication)
    }

    func apply(_ event: Event, frontmost: NSRunningApplication?) {
        name = event.name
        project = event.project
        if event.state == .working {
            // The hook fires from the app the user typed the prompt in; Focusly itself is never the way back.
            if let frontmost, frontmost.bundleIdentifier != Bundle.main.bundleIdentifier {
                origin = frontmost
            }
            state = .working
            since = Date()
            return
        }

        if let origin, frontmost?.processIdentifier == origin.processIdentifier {
            clear()
            return
        }
        state = event.state
        since = Date()
        let place = project.isEmpty ? "" : " in \(project)"
        let title = event.state == .done ? "\(name) finished\(place)" : "\(name) needs you\(place)"
        let body = origin?.localizedName.map { "Click to switch back to \($0)." } ?? ""
        Notifier.send(id: Self.notificationID, title: title, body: body, sound: false)
        soundManager?.playAgentSound(evenIfMuted: focusMonitor?.currentCategory == .drift)
    }

    func returnToAgent() {
        // Goes through LaunchServices: since macOS 14 a background app can't reliably activate another app directly.
        if let url = origin?.bundleURL {
            NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
        }
        clear()
    }

    private func clear() {
        state = nil
        since = nil
    }
}
