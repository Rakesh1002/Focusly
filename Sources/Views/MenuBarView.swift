import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var showingSettings = false

    var body: some View {
        VStack(spacing: 0) {
            if showingSettings {
                SettingsView()
                    .frame(height: 440)
            } else {
                NowView()
                    .padding(Spacing.l)
            }
            Divider()
            footer
        }
        .frame(width: 320)
    }

    private var footer: some View {
        HStack(spacing: Spacing.m) {
            iconButton(showingSettings ? "chevron.left" : "gearshape", label: showingSettings ? "Back" : "Settings") {
                showingSettings.toggle()
            }
            if showingSettings {
                Text("Settings").font(.headline)
            } else {
                iconButton(
                    settings.showTimeDisplay ? "pip.fill" : "pip",
                    label: settings.showTimeDisplay ? "Hide floating timer" : "Show floating timer"
                ) {
                    settings.showTimeDisplay.toggle()
                }
            }
            Spacer()
            iconButton("power", label: "Quit Focusly") { NSApplication.shared.terminate(nil) }
        }
        .padding(.horizontal, Spacing.l)
        .padding(.vertical, Spacing.s)
    }

    private func iconButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .frame(width: 20, height: 20)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .foregroundStyle(.secondary)
        .help(label)
        .accessibilityLabel(label)
    }
}

struct NowView: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var calendarManager: CalendarManager
    @State private var note = ""

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            if timerManager.isRunning {
                running
            } else {
                idle
            }
            if timerManager.awaitingNote {
                noteField
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var idle: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            if !timerManager.lastNote.isEmpty && !timerManager.awaitingNote {
                Label(timerManager.lastNote, systemImage: "arrow.uturn.backward")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .accessibilityLabel("Last time: \(timerManager.lastNote)")
            }
            Text(settings.workDuration.clock)
                .font(.heroTimer)
                .frame(maxWidth: .infinity)
                .accessibilityLabel("\(Int(settings.workDuration / 60)) minute block")
            HStack(spacing: Spacing.xs) {
                TextField("What are you working on?", text: $timerManager.task)
                    .textFieldStyle(.plain)
                    .font(.body)
                    .onSubmit(start)
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
            .padding(.horizontal, Spacing.m)
            .padding(.vertical, Spacing.s)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: Radius.s))
            HStack(spacing: Spacing.s) {
                ForEach([25, 50, 90], id: \.self) { minutes in
                    Button {
                        settings.workDuration = TimeInterval(minutes * 60)
                    } label: {
                        Text("\(minutes) min").frame(maxWidth: .infinity)
                    }
                    .glassButton(prominent: Int(settings.workDuration / 60) == minutes)
                    .accessibilityAddTraits(Int(settings.workDuration / 60) == minutes ? .isSelected : [])
                }
            }
            .glassGroup()
            RunwayLine(blockLength: settings.workDuration)
            Button(action: start) {
                Label("Start focus", systemImage: "play.fill").frame(maxWidth: .infinity)
            }
            .glassButton(prominent: true)
            .controlSize(.large)
            .keyboardShortcut(.defaultAction)
        }
    }

    private var running: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(timerManager.isBreakTime ? "On break" : "Focusing")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(timerManager.isBreakTime ? Color.green : Color.accentColor)
                    .textCase(.uppercase)
                Text(timerManager.isBreakTime ? "Step away from the screen" : headline)
                    .font(.title3.weight(.semibold))
                    .lineLimit(2)
            }
            Text(timerManager.remainingTime.clock)
                .font(.heroTimer)
                .frame(maxWidth: .infinity)
            ProgressView(value: progress)
                .tint(timerManager.isBreakTime ? .green : .accentColor)
                .accessibilityLabel("Block progress")
            if !timerManager.isBreakTime {
                RunwayLine(blockLength: timerManager.remainingTime)
            }
            HStack(spacing: Spacing.s) {
                Button {
                    timerManager.stop()
                } label: {
                    Text(timerManager.isBreakTime ? "End session" : "Stop").frame(maxWidth: .infinity)
                }
                .glassButton()
                if timerManager.isBreakTime {
                    Button {
                        timerManager.skipBreakStartWork()
                    } label: {
                        Text("Skip break").frame(maxWidth: .infinity)
                    }
                    .glassButton(prominent: true)
                }
            }
            .controlSize(.large)
            .glassGroup()
        }
    }

    private var progress: Double {
        let total = timerManager.isBreakTime ? settings.breakDuration : settings.workDuration
        guard total > 0 else { return 0 }
        return min(max(1 - timerManager.remainingTime / total, 0), 1)
    }

    private var noteField: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Where did you leave off?")
                .font(.headline)
            TextField("So you can pick it up next time", text: $note, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...3)
                .onSubmit(saveNote)
            HStack {
                Spacer()
                Button("Skip") { timerManager.awaitingNote = false }
                    .glassButton()
                Button("Save", action: saveNote)
                    .glassButton()
                    .disabled(note.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .glassGroup()
        }
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

struct RunwayLine: View {
    @EnvironmentObject var calendarManager: CalendarManager
    let blockLength: TimeInterval

    var body: some View {
        if calendarManager.hasAccess {
            TimelineView(.everyMinute) { _ in
                let now = Date()
                if let event = calendarManager.nextEvent(after: now),
                   event.startDate.timeIntervalSince(now) < 3 * 3600 {
                    let startsIn = event.startDate.timeIntervalSince(now)
                    let collides = startsIn < blockLength
                    Label(
                        collides
                            ? "\(event.title) in \(startsIn.shortDuration), before this block ends"
                            : "\(event.title) in \(startsIn.shortDuration)",
                        systemImage: collides ? "exclamationmark.circle" : "calendar"
                    )
                    .font(.callout)
                    .foregroundStyle(collides ? Color.accentColor : .secondary)
                } else {
                    Label("No meetings in the next 3 hours", systemImage: "calendar")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
