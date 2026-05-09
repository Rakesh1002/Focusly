import AppKit
import Combine
import Foundation

enum AppCategory: String {
    case focus
    case drift
    case neutral
}

struct FocusEvent {
    let timestamp: Date
    let bundleID: String
    let appName: String
    let category: AppCategory
}

extension Notification.Name {
    static let focusMonitorEvent = Notification.Name("FocuslyAI.focusMonitorEvent")
}

final class FocusMonitor: ObservableObject {
    @Published private(set) var isMonitoring = false
    @Published private(set) var currentAppName: String?
    @Published private(set) var currentCategory: AppCategory = .neutral
    @Published private(set) var cumulativeDriftSeconds: TimeInterval = 0
    @Published private(set) var sessionStartedAt: Date?

    private var workspaceObserver: NSObjectProtocol?
    private var driftStartedAt: Date?

    private static let focusBundleIDs: Set<String> = [
        "com.apple.dt.Xcode",
        "com.microsoft.VSCode",
        "com.microsoft.VSCodeInsiders",
        "com.todesktop.230313mzl4w4u92",
        "com.exafunction.windsurf",
        "com.apple.Terminal",
        "com.googlecode.iterm2",
        "co.zeit.hyper",
        "com.figma.Desktop",
        "notion.id",
        "md.obsidian",
        "com.apple.TextEdit",
        "com.apple.Notes"
    ]

    private static let driftBundleIDs: Set<String> = [
        "com.tinyspeck.slackmacgap",
        "ru.keepcoder.Telegram",
        "com.hnc.Discord",
        "com.spotify.client",
        "com.apple.Music",
        "com.apple.MobileSMS",
        "com.twitter.twitter-mac",
        "com.tweetdeck.tweetdeck",
        "com.reederapp.5.macOS"
    ]

    func start() {
        guard !isMonitoring else { return }
        isMonitoring = true
        sessionStartedAt = Date()
        driftStartedAt = nil
        cumulativeDriftSeconds = 0

        let center = NSWorkspace.shared.notificationCenter
        workspaceObserver = center.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard
                let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
            else { return }
            self?.handleAppActivated(app)
        }

        if let app = NSWorkspace.shared.frontmostApplication {
            handleAppActivated(app)
        }

        NSLog("[FocusMonitor] started")
    }

    func stop() {
        guard isMonitoring else { return }
        isMonitoring = false
        if let observer = workspaceObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            workspaceObserver = nil
        }
        if let started = driftStartedAt {
            cumulativeDriftSeconds += Date().timeIntervalSince(started)
        }
        driftStartedAt = nil
        currentAppName = nil
        currentCategory = .neutral
        NSLog("[FocusMonitor] stopped, total drift: %.0fs", cumulativeDriftSeconds)
    }

    private func handleAppActivated(_ app: NSRunningApplication) {
        let bundleID = app.bundleIdentifier ?? "unknown"
        let name = app.localizedName ?? bundleID
        let category = Self.categorize(bundleID: bundleID)
        let now = Date()

        switch category {
        case .drift:
            if driftStartedAt == nil {
                driftStartedAt = now
            }
        case .focus, .neutral:
            if let started = driftStartedAt {
                cumulativeDriftSeconds += now.timeIntervalSince(started)
                driftStartedAt = nil
            }
        }

        currentAppName = name
        currentCategory = category

        let event = FocusEvent(
            timestamp: now,
            bundleID: bundleID,
            appName: name,
            category: category
        )
        NotificationCenter.default.post(name: .focusMonitorEvent, object: event)
        NSLog(
            "[FocusMonitor] %@ (%@) -> %@ — drift total %.0fs",
            name,
            bundleID,
            category.rawValue,
            cumulativeDriftSeconds
        )
    }

    static func categorize(bundleID: String) -> AppCategory {
        if focusBundleIDs.contains(bundleID) { return .focus }
        if driftBundleIDs.contains(bundleID) { return .drift }
        return .neutral
    }
}
