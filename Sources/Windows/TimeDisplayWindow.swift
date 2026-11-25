import SwiftUI
import AppKit

final class TimeOverlayWindow: NSPanel {
    let displayID: CGDirectDisplayID
    var onMoved: ((TimeOverlayWindow) -> Void)?
    private var dragStart: (mouse: NSPoint, origin: NSPoint)?
    private var didDrag = false

    init(displayID: CGDirectDisplayID) {
        self.displayID = displayID
        // Non-activating so dragging or clicking the anchor doesn't pull focus from the app being worked in.
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 120, height: 40),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        // WindowManager owns these windows and closes them on display changes; AppKit must not also release them.
        isReleasedWhenClosed = false
        hidesOnDeactivate = false
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        level = .floating
        collectionBehavior = [.canJoinAllSpaces]
    }

    // NSHostingView resizes the window to its content keeping the top-left corner fixed; the anchor lives
    // top-right, so keep the right edge where it is when only the size changes. Drags keep the size and pass through.
    override func setFrame(_ frameRect: NSRect, display flag: Bool) {
        var rect = frameRect
        if rect.size != frame.size && rect.minX == frame.minX {
            rect.origin.x = frame.maxX - rect.width
            rect.origin.y = frame.maxY - rect.height
        }
        super.setFrame(rect, display: flag)
    }

    // NSHostingView swallows mouseDown, so isMovableByWindowBackground never fires; the SwiftUI drag gesture drives these.
    func dragChanged() {
        let mouse = NSEvent.mouseLocation
        guard let start = dragStart else {
            dragStart = (mouse, frame.origin)
            didDrag = false
            return
        }
        let dx = mouse.x - start.mouse.x, dy = mouse.y - start.mouse.y
        if didDrag || hypot(dx, dy) > 3 {
            didDrag = true
            setFrameOrigin(NSPoint(x: start.origin.x + dx, y: start.origin.y + dy))
        }
    }

    /// True when the gesture moved the window; false means it was a click.
    func dragEnded() -> Bool {
        defer { dragStart = nil }
        if didDrag { onMoved?(self) }
        return didDrag
    }
}

struct TimeDisplayWindow: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var calendarManager: CalendarManager
    @EnvironmentObject var focusMonitor: FocusMonitor
    @EnvironmentObject var agentWatch: AgentWatch
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    weak var window: TimeOverlayWindow?
    @State private var hovering = false

    private static let driftGrace: TimeInterval = 120
    private static let leadingSlot: CGFloat = 18

    var body: some View {
        let drifting = isDrifting
        let shape = RoundedRectangle(cornerRadius: 16)
        TimelineView(.everyMinute) { context in
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack(spacing: Spacing.s) {
                    leadingSlot
                    Text(drifting ? (task.isEmpty ? "Back to your focus block" : "Back to: \(task)") : headline)
                        .font(.callout.weight(.medium))
                        .foregroundStyle(timerManager.isRunning ? .primary : .secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    if timerManager.isRunning {
                        Spacer(minLength: Spacing.s)
                        Text(timerManager.remainingTime.clock)
                            .font(.callout.weight(.medium).monospacedDigit())
                    }
                }
                HStack(spacing: Spacing.s) {
                    if let runway = runway(at: Date()) {
                        Text(runway.text)
                            .foregroundStyle(runway.urgent ? Signal.soon : .secondary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: Spacing.s)
                    Text(context.date.formatted(date: .omitted, time: .shortened))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Time \(context.date.formatted(date: .omitted, time: .shortened))")
                }
                .font(.caption)
                .padding(.leading, Self.leadingSlot + Spacing.s)
                if let agentState = agentWatch.state {
                    agentRow(agentState)
                        .font(.caption)
                        .padding(.leading, Self.leadingSlot + Spacing.s)
                }
            }
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.s)
            .frame(maxWidth: 300, alignment: .leading)
            .fixedSize()
            .glassBackground(in: shape, interactive: true)
            .overlay(shape.strokeBorder(Ink.hairline, lineWidth: 0.5))
            .overlay {
                if drifting {
                    DriftBorder(shape: shape, animated: !reduceMotion)
                }
            }
        }
        .contentShape(shape)
        .onHover { hovering = $0 }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in window?.dragChanged() }
                .onEnded { _ in
                    if window?.dragEnded() == false { click() }
                }
        )
        .contextMenu {
            Button("Hide floating timer") { settings.showTimeDisplay = false }
            Button("Reset position") {
                if let window { WindowManager.shared.resetPosition(of: window) }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityAction(named: "Open Focusly", click)
    }

    private var leadingSlot: some View {
        ZStack {
            Group {
                if timerManager.isRunning {
                    FocusRing(progress: blockProgress, lineWidth: 2.5)
                } else {
                    Circle().fill(Ink.secondary).frame(width: 8, height: 8)
                }
            }
            .opacity(hovering ? 0 : 1)
            .accessibilityHidden(true)
            Image(systemName: "xmark")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.secondary)
                .frame(width: Self.leadingSlot, height: Self.leadingSlot)
                .contentShape(Circle())
                // Outranks the anchor-wide drag gesture, which would otherwise treat this as a click on the anchor.
                .highPriorityGesture(TapGesture().onEnded { settings.showTimeDisplay = false })
                .allowsHitTesting(hovering)
                .accessibilityAddTraits(.isButton)
                .accessibilityAction { settings.showTimeDisplay = false }
            .opacity(hovering ? 1 : 0)
            .help("Hide floating timer")
            .accessibilityLabel("Hide floating timer")
        }
        .frame(width: Self.leadingSlot, height: Self.leadingSlot)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: hovering)
    }

    @ViewBuilder private func agentRow(_ state: AgentWatch.State) -> some View {
        if state == .working, let since = agentWatch.since {
            HStack(spacing: Spacing.xs) {
                Text("\(agentWatch.name) working \u{00B7}")
                Text(timerInterval: since...Date.distantFuture, countsDown: false)
                    .monospacedDigit()
                if !agentWatch.project.isEmpty {
                    Text("\u{00B7} \(agentWatch.project)").lineLimit(1)
                }
            }
            .foregroundStyle(.secondary)
        } else {
            Text("\(agentWatch.name) \(state == .done ? "done" : "needs you"), click to return")
                .fontWeight(.medium)
                .foregroundStyle(Ink.primary)
                .lineLimit(1)
        }
    }

    private func click() {
        if agentWatch.state == .done || agentWatch.state == .waiting {
            agentWatch.returnToAgent()
        } else {
            NotificationCenter.default.post(name: NSNotification.Name("OpenMainPopover"), object: window)
        }
    }

    private var blockProgress: Double {
        let total = timerManager.isBreakTime ? settings.breakDuration : settings.workDuration
        guard total > 0 else { return 0 }
        return 1 - timerManager.remainingTime / total
    }

    private var task: String {
        timerManager.task.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var headline: String {
        if timerManager.isBreakTime { return "On break" }
        if !task.isEmpty { return task }
        return timerManager.isRunning ? "Focusing" : "Not focusing"
    }


    // Evaluated on every body pass; while focusing the countdown re-renders the view each second.
    private var isDrifting: Bool {
        guard timerManager.isRunning, !timerManager.isBreakTime, let since = focusMonitor.driftStartedAt else { return false }
        return Date().timeIntervalSince(since) >= Self.driftGrace
    }

    private func runway(at date: Date) -> (text: String, urgent: Bool)? {
        guard calendarManager.hasAccess, let event = calendarManager.nextEvent(after: date) else { return nil }
        let startsIn = event.startDate.timeIntervalSince(date)
        guard startsIn < 3 * 3600 else { return nil }
        return ("\(event.title) in \(startsIn.shortDuration)", startsIn < 5 * 60)
    }
}

/// Lives only while drifting, so its repeating animation ends with it instead of sticking to the anchor.
private struct DriftBorder<S: InsettableShape>: View {
    let shape: S
    let animated: Bool
    @State private var dim = false

    var body: some View {
        shape
            .strokeBorder(Signal.soon, lineWidth: 1.5)
            .opacity(dim ? 0.35 : 1)
            .onAppear {
                guard animated else { return }
                withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) { dim = true }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}
