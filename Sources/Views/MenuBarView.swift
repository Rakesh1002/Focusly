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
            HStack(spacing: Spacing.l) {
                Button {
                    showingSettings.toggle()
                } label: {
                    Image(systemName: showingSettings ? "chevron.left" : "gearshape")
                }
                .help(showingSettings ? "Back" : "Settings")
                .accessibilityLabel(showingSettings ? "Back" : "Settings")
                Spacer()
                if !settings.showTimeDisplay {
                    Button("Show floating timer") { settings.showTimeDisplay = true }
                }
                Button("Quit") { NSApplication.shared.terminate(nil) }
            }
            .buttonStyle(.borderless)
            .padding(.horizontal, Spacing.l)
            .padding(.vertical, Spacing.s)
        }
        .frame(width: 320)
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
                Text("Last time: \(timerManager.lastNote)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("What are you working on?")
                    .font(.headline)
                HStack(spacing: Spacing.xs) {
                    TextField("One task", text: $timerManager.task)
                        .textFieldStyle(.roundedBorder)
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
            }
            Picker("Focus block length", selection: blockMinutes) {
                Text("25 min").tag(25)
                Text("50 min").tag(50)
                Text("90 min").tag(90)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            RunwayLine(blockLength: settings.workDuration)
            Button(action: start) {
                Text("Start").frame(maxWidth: .infinity)
            }
            .glassButton(prominent: true)
            .controlSize(.large)
            .keyboardShortcut(.defaultAction)
        }
    }

    private var running: some View {
        VStack(alignment: .leading, spacing: Spacing.s) {
            Text(timerManager.isBreakTime ? "Break" : headline)
                .font(.headline)
                .lineLimit(2)
            Text(timerManager.remainingTime.clock)
                .font(.timer)
            if !timerManager.isBreakTime {
                RunwayLine(blockLength: timerManager.remainingTime)
            }
            HStack(spacing: Spacing.s) {
                Button(timerManager.isBreakTime ? "End session" : "Stop") { timerManager.stop() }
                    .glassButton()
                if timerManager.isBreakTime {
                    Button("Skip break") { timerManager.skipBreakStartWork() }
                        .glassButton(prominent: true)
                }
            }
            .controlSize(.large)
            .glassGroup()
        }
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

    private var blockMinutes: Binding<Int> {
        Binding(
            get: { Int(settings.workDuration / 60) },
            set: { settings.workDuration = TimeInterval($0 * 60) }
        )
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
