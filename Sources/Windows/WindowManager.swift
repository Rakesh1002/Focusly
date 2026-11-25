import SwiftUI
import AppKit

extension NSScreen {
    var displayID: CGDirectDisplayID {
        deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID ?? 0
    }
}

class WindowManager {
    static let shared = WindowManager()
    private var timeDisplayWindows: [CGDirectDisplayID: TimeOverlayWindow] = [:]
    private var breakOverlayController: BreakOverlayWindowController?
    private var timerManager: TimerManager?
    private var settings: Settings?

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screensDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    func setSettings(_ settings: Settings) {
        self.settings = settings
    }

    @objc private func screensDidChange() {
        if settings?.showTimeDisplay == true {
            showTimeDisplay()
        }
    }

    static func reconcile(
        existing: Set<CGDirectDisplayID>,
        targets: [CGDirectDisplayID]
    ) -> (close: Set<CGDirectDisplayID>, create: [CGDirectDisplayID]) {
        (existing.subtracting(targets), targets.filter { !existing.contains($0) })
    }

    func showTimeDisplay() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in self?.showTimeDisplay() }
            return
        }

        let screens = settings?.showFloatingTimerOnAllScreens == true
            ? NSScreen.screens
            : Array(NSScreen.screens.prefix(1))
        let screensByID = Dictionary(screens.map { ($0.displayID, $0) }, uniquingKeysWith: { first, _ in first })
        let diff = Self.reconcile(existing: Set(timeDisplayWindows.keys), targets: screens.map(\.displayID))

        for id in diff.close {
            timeDisplayWindows.removeValue(forKey: id)?.close()
        }
        for id in diff.create {
            guard let screen = screensByID[id] else { continue }
            let window = TimeOverlayWindow(screen: screen)
            if let manager = timerManager {
                updateTimeDisplayView(window: window, manager: manager)
            }
            timeDisplayWindows[id] = window
        }
        for (id, window) in timeDisplayWindows {
            if let screen = screensByID[id], !screen.visibleFrame.intersects(window.frame) {
                window.place(on: screen)
            }
            window.orderFrontRegardless()
        }
    }

    func hideTimeDisplay() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in self?.hideTimeDisplay() }
            return
        }
        timeDisplayWindows.values.forEach { $0.orderOut(nil) }
    }

    func setTimerManager(_ manager: TimerManager) {
        self.timerManager = manager
        for window in timeDisplayWindows.values {
            updateTimeDisplayView(window: window, manager: manager)
        }
    }

    private func updateTimeDisplayView(window: TimeOverlayWindow, manager: TimerManager) {
        window.contentView = NSHostingView(rootView: TimeDisplayWindow().environmentObject(manager))
    }

    func showBreakOverlay() {
        guard let timerManager = timerManager else { return }
        if breakOverlayController == nil {
            breakOverlayController = BreakOverlayWindowController(timerManager: timerManager)
        }
        breakOverlayController?.show()
    }

    func hideBreakOverlay() {
        breakOverlayController?.hide()
        breakOverlayController?.close()
        breakOverlayController = nil
    }

    func cleanup() {
        hideTimeDisplay()
        hideBreakOverlay()
    }
}
