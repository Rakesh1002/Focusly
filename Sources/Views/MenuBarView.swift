import SwiftUI

struct MenuBarView: View {
    private enum Screen { case settings, agent }

    @State private var path: [Screen] = []

    var body: some View {
        VStack(spacing: 0) {
            switch path.last {
            case nil:
                NowView(openSettings: { path.append(.settings) }, openAgentSetup: { path.append(.agent) })
                    .padding(14)
                footer
            case .settings:
                header("Settings")
                SettingsView { path.append(.agent) }
                    .frame(height: 480)
            case .agent:
                header("Coding agent")
                AgentSetupView()
            }
        }
        .frame(width: TimerPanelLayout.width)
        .onDisappear { path.removeAll() }
    }

    private func header(_ title: String) -> some View {
        HStack(spacing: Spacing.s) {
            SquareIconButton(symbol: "chevron.left", label: "Back") { path.removeLast() }
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Ink.primary)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
    }

    private var footer: some View {
        HStack {
            SquareIconButton(symbol: "power", label: "Quit Focusly") { NSApplication.shared.terminate(nil) }
            Spacer()
            Text("\u{2325}\u{2318}T starts or stops a block")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Ink.secondary)
            Spacer()
            SquareIconButton(symbol: "gearshape.fill", label: "Settings") { path.append(.settings) }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .overlay(alignment: .top) { Rectangle().fill(Ink.hairline).frame(height: 0.5) }
    }
}

struct NowView: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var calendarManager: CalendarManager
    @EnvironmentObject var agentWatch: AgentWatch
    let openSettings: () -> Void
    let openAgentSetup: () -> Void
    @State private var note = ""

    private var mood: Mood { Mood(running: timerManager.isRunning, onBreak: timerManager.isBreakTime) }

    var body: some View {
        VStack(spacing: 10) {
            heroCard
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible())], spacing: 10) {
                // The timeline only schedules the refresh; reading the clock here keeps the card and the collision warning in step.
                TimelineView(.everyMinute) { _ in meetingCard(now: Date()) }
                agentCard
                floatingTimerCard
                breaksCard
            }
        }
    }

    // MARK: Hero

    private var heroCard: some View {
        VStack(spacing: Spacing.m) {
            ZStack {
                FocusRing(progress: timerManager.isRunning ? progress : 0)
                VStack(spacing: 2) {
                    Text(ringLabel)
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1.4)
                        .foregroundStyle(Ink.secondary)
                    Text((timerManager.isRunning ? timerManager.remainingTime : settings.workDuration).clock)
                        .font(.system(size: 42, weight: .light).monospacedDigit())
                        .foregroundStyle(Ink.primary)
                }
                .accessibilityElement(children: .combine)
            }
            .frame(width: 156, height: 156)

            VStack(spacing: 4) {
                (Text("Focus: ") + Text(mood.word).foregroundColor(Ink.secondary))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Ink.primary)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(Ink.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }

            if timerManager.awaitingNote {
                noteField
            } else if timerManager.isRunning {
                runningControls
            } else {
                idleControls
            }
        }
        .padding(.vertical, Spacing.s)
        .frame(maxWidth: .infinity)
    }

    private var ringLabel: String {
        switch mood {
        case .ready: return "READY"
        case .focus: return "FOCUS"
        case .rest: return "BREAK"
        }
    }

    private var subtitle: String {
        switch mood {
        case .ready:
            if timerManager.awaitingNote {
                return "Block done. Leave yourself a note for next time."
            }
            if !timerManager.lastNote.isEmpty {
                return "Last time: \(timerManager.lastNote)"
            }
            return "Pick one task. Everything else can wait."
        case .focus: return headline
        case .rest: return "Step away for a bit"
        }
    }

    private var progress: Double {
        let total = timerManager.isBreakTime ? settings.breakDuration : settings.workDuration
        guard total > 0 else { return 0 }
        return min(max(1 - timerManager.remainingTime / total, 0), 1)
    }

    // MARK: Controls

    private var idleControls: some View {
        VStack(spacing: 10) {
            TaskField(onSubmit: start)
            DurationPicker()
            if let warning = collisionWarning(blockLength: settings.workDuration) {
                Label(warning, systemImage: "exclamationmark.circle")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Signal.soon)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Button(action: start) {
                Label("Start focus", systemImage: "play.fill")
            }
            .buttonStyle(PanelButtonStyle(kind: .cta))
            .keyboardShortcut(.defaultAction)
        }
    }

    private var runningControls: some View {
        HStack(spacing: Spacing.s) {
            Button(timerManager.isBreakTime ? "End session" : "Stop") { timerManager.stop() }
                .buttonStyle(PanelButtonStyle())
            if timerManager.isBreakTime {
                Button("Skip break") { timerManager.skipBreakStartWork() }
                    .buttonStyle(PanelButtonStyle(kind: .cta))
            }
        }
    }

    private var noteField: some View {
        VStack(spacing: Spacing.s) {
            TextField("Where did you leave off?", text: $note, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .lineLimit(1...3)
                .onSubmit(saveNote)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Ink.fill, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            HStack(spacing: Spacing.s) {
                Button("Skip") { timerManager.awaitingNote = false }
                    .buttonStyle(PanelButtonStyle(height: 34))
                Button("Save note", action: saveNote)
                    .buttonStyle(PanelButtonStyle(kind: .cta, height: 34))
                    .disabled(note.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    // MARK: Cards

    @ViewBuilder private func meetingCard(now: Date) -> some View {
        if !calendarManager.hasAccess {
            ActionCard(symbol: "calendar", title: "Next meeting",
                       value: Text("Not connected").foregroundColor(Ink.secondary),
                       action: ("Connect", calendarManager.connect))
        } else if let event = calendarManager.nextEvent(after: now) {
            let startsIn = event.startDate.timeIntervalSince(now)
            ActionCard(symbol: "calendar", title: event.title,
                       value: Text("In \(startsIn.shortDuration)").foregroundColor(startsIn < 5 * 60 ? Signal.now : Ink.secondary))
        } else {
            ActionCard(symbol: "calendar", title: "Next meeting",
                       value: Text("Free for today").foregroundColor(Ink.secondary))
        }
    }

    @ViewBuilder private var agentCard: some View {
        switch agentWatch.state {
        case .working:
            ActionCard(symbol: "sparkles", title: agentWatch.name,
                       value: (Text("Working \u{00B7} ") + Text(timerInterval: (agentWatch.since ?? Date())...Date.distantFuture, countsDown: false))
                        .foregroundColor(Ink.secondary))
        case .done, .waiting:
            ActionCard(symbol: "sparkles", title: agentWatch.name,
                       value: Text(agentWatch.state == .done ? "Finished" : "Needs you").foregroundColor(Signal.soon),
                       action: ("Return", agentWatch.returnToAgent))
        case nil:
            ActionCard(symbol: "sparkles", title: "Coding agent",
                       value: Text("Idle").foregroundColor(Ink.secondary),
                       action: ("Set up", openAgentSetup))
        }
    }

    private var floatingTimerCard: some View {
        ActionCard(symbol: "pip", title: "Floating timer",
                   value: Text(settings.showTimeDisplay ? "Showing" : "Hidden")
                    .foregroundColor(Ink.secondary),
                   action: (settings.showTimeDisplay ? "Hide" : "Show", { settings.showTimeDisplay.toggle() }))
    }

    private var breaksCard: some View {
        ActionCard(symbol: "cup.and.saucer", title: "Breaks",
                   value: Text("\(Int(settings.breakDuration / 60)) min each")
                    .foregroundColor(Ink.secondary),
                   action: ("Adjust", openSettings))
    }

    // MARK: Helpers

    private func collisionWarning(blockLength: TimeInterval) -> String? {
        guard calendarManager.hasAccess, let event = calendarManager.nextEvent() else { return nil }
        let startsIn = event.startDate.timeIntervalSinceNow
        guard startsIn < blockLength else { return nil }
        return "\(event.title) starts in \(startsIn.shortDuration), before this block ends"
    }

    private var headline: String {
        let task = timerManager.task.trimmingCharacters(in: .whitespacesAndNewlines)
        return task.isEmpty ? "Focusing" : task
    }

    private func start() {
        timerManager.start()
        NotificationCenter.default.post(name: NSNotification.Name("ClosePopover"), object: nil)
    }

    private func saveNote() {
        guard !note.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        timerManager.saveNote(note)
        note = ""
    }
}

struct TaskField: View {
    @EnvironmentObject var timerManager: TimerManager
    @FocusState private var isFocused: Bool
    let onSubmit: () -> Void

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 10, style: .continuous)
        let question: LocalizedStringKey = "What are you working on?"
        let secondaryText = Color(nsColor: .secondaryLabelColor)
        let textColor = Color(nsColor: .textColor)
        HStack(spacing: Spacing.s) {
            Image(systemName: "scope")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(secondaryText)
            TextField(question, text: $timerManager.task, prompt: Text(question).foregroundColor(textColor.opacity(0.72)))
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .foregroundStyle(textColor)
                .focused($isFocused)
                .onSubmit(onSubmit)
            if !timerManager.recentTasks.isEmpty {
                Menu {
                    ForEach(timerManager.recentTasks, id: \.self) { recent in
                        Button(recent) { timerManager.task = recent }
                    }
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .fixedSize()
                .help("Recent tasks")
                .accessibilityLabel("Recent tasks")
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 36)
        .background(Color(nsColor: .textBackgroundColor), in: shape)
        .overlay {
            shape.strokeBorder(isFocused ? Color.accentColor : secondaryText.opacity(0.65),
                               lineWidth: isFocused ? 2 : 1)
                .allowsHitTesting(false)
        }
    }
}

struct DurationPicker: View {
    @EnvironmentObject var settings: Settings
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace private var pill

    var body: some View {
        HStack(spacing: 2) {
            ForEach([25, 50, 90], id: \.self) { minutes in
                let selected = Int(settings.workDuration / 60) == minutes
                Button {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.85)) {
                        settings.workDuration = TimeInterval(minutes * 60)
                    }
                } label: {
                    Text("\(minutes) min")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(selected ? Ink.primary : Ink.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 28)
                        .background {
                            if selected {
                                RoundedRectangle(cornerRadius: 7, style: .continuous).fill(.background)
                                    .shadow(color: .black.opacity(0.08), radius: 1, y: 0.5)
                                    .matchedGeometryEffect(id: "pill", in: pill)
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(minutes) minute block")
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
        .padding(3)
        .background(Ink.fill, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
