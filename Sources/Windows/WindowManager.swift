import SwiftUI
import AppKit

extension NSScreen {
    var displayID: CGDirectDisplayID {
        deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID ?? 0
    }

    /// Stable across reconnects and reboots, unlike `displayID`.
    var displayUUID: String? {
        guard let uuid = CGDisplayCreateUUIDFromDisplayID(displayID)?.takeRetainedValue() else { return nil }
        return CFUUIDCreateString(nil, uuid) as String
    }
}

class WindowManager {
    static let shared = WindowManager()
    private var timeDisplayWindows: [CGDirectDisplayID: TimeOverlayWindow] = [:]
    private var breakWindows: [CGDirectDisplayID: BreakOverlayWindow] = [:]
    private var settings: Settings?
    private var timerManager: TimerManager?
    private var calendarManager: CalendarManager?
    private var focusMonitor: FocusMonitor?
    private var agentWatch: AgentWatch?

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screensDidChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    func configure(settings: Settings, timerManager: TimerManager, calendarManager: CalendarManager,
                   focusMonitor: FocusMonitor, agentWatch: AgentWatch) {
        self.agentWatch = agentWatch
        self.settings = settings
        self.timerManager = timerManager
        self.calendarManager = calendarManager
        self.focusMonitor = focusMonitor
    }

    @objc private func screensDidChange() {
        if settings?.showTimeDisplay == true {
            showTimeDisplay()
        }
        // A reconfiguration can briefly report no screens and close every overlay, so ask the timer, not breakWindows.
        if timerManager?.isBreakTime == true, settings?.showBreakOverlay == true {
            showBreakOverlay()
        }
    }

    static func reconcile(
        existing: Set<CGDirectDisplayID>,
        targets: [CGDirectDisplayID]
    ) -> (close: Set<CGDirectDisplayID>, create: [CGDirectDisplayID]) {
        (existing.subtracting(targets), targets.filter { !existing.contains($0) })
    }

    /// Origin that keeps `rect` fully inside `bounds`, moving it as little as possible.
    static func clamp(_ rect: NSRect, into bounds: NSRect) -> NSPoint {
        NSPoint(
            x: min(max(rect.minX, bounds.minX), bounds.maxX - rect.width),
            y: min(max(rect.minY, bounds.minY), bounds.maxY - rect.height)
        )
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
            let window = TimeOverlayWindow(displayID: id)
            guard let content = makeAnchorView(for: window) else { continue }
            window.contentView = content
            window.onMoved = { [weak self] in self?.savePosition(of: $0) }
            place(window, on: screen)
            timeDisplayWindows[id] = window
        }
        for (id, window) in timeDisplayWindows {
            if let screen = screensByID[id] {
                window.setFrameOrigin(Self.clamp(window.frame, into: screen.frame))
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

    // Saved per display as the anchor's top-right corner relative to that screen's frame: the anchor grows leftwards.
    private static let positionsKey = "anchorPositions"

    private func place(_ window: TimeOverlayWindow, on screen: NSScreen) {
        let frame = screen.frame
        var topRight = NSPoint(x: screen.visibleFrame.maxX - 20, y: screen.visibleFrame.maxY - 20)
        if let uuid = screen.displayUUID,
           let saved = UserDefaults.app.dictionary(forKey: Self.positionsKey)?[uuid] as? [Double], saved.count == 2 {
            topRight = NSPoint(x: frame.minX + saved[0], y: frame.minY + saved[1])
        }
        let target = NSRect(x: topRight.x - window.frame.width, y: topRight.y - window.frame.height,
                            width: window.frame.width, height: window.frame.height)
        window.setFrameOrigin(Self.clamp(target, into: frame))
    }

    private func savePosition(of window: TimeOverlayWindow) {
        guard let screen = NSScreen.screens.first(where: { $0.displayID == window.displayID }),
              let uuid = screen.displayUUID else { return }
        var positions = UserDefaults.app.dictionary(forKey: Self.positionsKey) ?? [:]
        positions[uuid] = [window.frame.maxX - screen.frame.minX, window.frame.maxY - screen.frame.minY]
        UserDefaults.app.set(positions, forKey: Self.positionsKey)
    }

    func resetPosition(of window: TimeOverlayWindow) {
        guard let screen = NSScreen.screens.first(where: { $0.displayID == window.displayID }) else { return }
        if let uuid = screen.displayUUID, var positions = UserDefaults.app.dictionary(forKey: Self.positionsKey) {
            positions[uuid] = nil
            UserDefaults.app.set(positions, forKey: Self.positionsKey)
        }
        place(window, on: screen)
    }

    private func makeAnchorView(for window: TimeOverlayWindow) -> NSView? {
        guard let settings, let timerManager, let calendarManager, let focusMonitor, let agentWatch else { return nil }
        return NSHostingView(rootView: TimeDisplayWindow(window: window)
            .environmentObject(settings)
            .environmentObject(timerManager)
            .environmentObject(calendarManager)
            .environmentObject(focusMonitor)
            .environmentObject(agentWatch))
    }

    func showBreakOverlay() {
        guard let timerManager else { return }
        let screensByID = Dictionary(NSScreen.screens.map { ($0.displayID, $0) }, uniquingKeysWith: { first, _ in first })
        let diff = Self.reconcile(existing: Set(breakWindows.keys), targets: NSScreen.screens.map(\.displayID))

        for id in diff.close {
            breakWindows.removeValue(forKey: id)?.close()
        }
        for id in diff.create {
            guard let screen = screensByID[id] else { continue }
            breakWindows[id] = BreakOverlayWindow(screen: screen, timerManager: timerManager)
        }
        for (id, window) in breakWindows {
            if let screen = screensByID[id] {
                window.setFrame(screen.frame, display: true)
            }
            window.orderFrontRegardless()
        }
    }

    func hideBreakOverlay() {
        breakWindows.values.forEach { $0.close() }
        breakWindows.removeAll()
    }

    func cleanup() {
        hideTimeDisplay()
        hideBreakOverlay()
    }
}
