import AppKit
import Combine
import Foundation

enum AppCategory: String {
    case focus
    case drift
    case neutral
}

final class FocusMonitor: ObservableObject {
    @Published private(set) var isMonitoring = false
    @Published private(set) var currentCategory: AppCategory = .neutral
    @Published private(set) var driftStartedAt: Date?

    private var workspaceObserver: NSObjectProtocol?

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
        driftStartedAt = nil

        workspaceObserver = NSWorkspace.shared.notificationCenter.addObserver(
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
    }

    func stop() {
        guard isMonitoring else { return }
        isMonitoring = false
        if let observer = workspaceObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            workspaceObserver = nil
        }
        driftStartedAt = nil
        currentCategory = .neutral
    }

    private func handleAppActivated(_ app: NSRunningApplication) {
        // Opening Focusly itself (popover, anchor click) is neither drift nor a return to work.
        guard app.bundleIdentifier != Bundle.main.bundleIdentifier else { return }
        let category = Self.categorize(bundleID: app.bundleIdentifier ?? "")
        if category == .drift {
            if driftStartedAt == nil {
                driftStartedAt = Date()
            }
        } else {
            driftStartedAt = nil
        }
        currentCategory = category
    }

    static func categorize(bundleID: String) -> AppCategory {
        if focusBundleIDs.contains(bundleID) { return .focus }
        if driftBundleIDs.contains(bundleID) { return .drift }
        return .neutral
    }
}
