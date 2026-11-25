import SwiftUI
import UserNotifications

struct OnboardingView: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var timerManager: TimerManager
    @EnvironmentObject var calendarManager: CalendarManager
    /// Called with `true` when the user chose to start a focus block right away.
    let onFinish: (Bool) -> Void

    @State private var step = 0
    @State private var notificationsAllowed = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            if step == 0 {
                taskStep
            } else {
                helpersStep
            }
            Spacer(minLength: 0)
            HStack {
                Button("Skip") { onFinish(false) }
                    .buttonStyle(.borderless)
                Spacer()
                if step == 0 {
                    Button("Next") { step = 1 }
                        .glassButton(prominent: true)
                        .keyboardShortcut(.defaultAction)
                } else {
                    Button("Back") { step = 0 }
                        .glassButton()
                    Button("Start focusing") { onFinish(true) }
                        .glassButton(prominent: true)
                        .keyboardShortcut(.defaultAction)
                }
            }
            .controlSize(.large)
        }
        .padding(Spacing.xl)
        .frame(width: 460, height: 420)
        .onAppear(perform: refreshNotificationStatus)
    }

    private var taskStep: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("Welcome to Focusly")
                    .font(.largeTitle.weight(.semibold))
                Text("A small anchor in the corner of your screen that shows the one thing you are doing, how long you have, and brings you back when you drift.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("What are you working on?")
                    .font(.headline)
                TextField("One task", text: $timerManager.task)
                    .textFieldStyle(.roundedBorder)
                    .controlSize(.large)
            }
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("For how long?")
                    .font(.headline)
                Picker("Focus block length", selection: blockMinutes) {
                    Text("25 min").tag(25)
                    Text("50 min").tag(50)
                    Text("90 min").tag(90)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
        }
    }

    private var helpersStep: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            VStack(alignment: .leading, spacing: Spacing.s) {
                Text("A few optional helpers")
                    .font(.largeTitle.weight(.semibold))
                Text("You can change these any time in Settings.")
                    .foregroundStyle(.secondary)
            }
            helperRow(
                title: "Notifications",
                detail: "A gentle note when a block or break ends.",
                done: notificationsAllowed,
                action: ("Allow", requestNotifications)
            )
            helperRow(
                title: "Calendar runway",
                detail: "See how long you have until your next meeting.",
                done: calendarManager.hasAccess,
                action: ("Connect", calendarManager.connect)
            )
            HStack(spacing: Spacing.m) {
                helperText(title: "Launch at login", detail: "Have the anchor ready when you sit down.")
                Spacer()
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }
        }
    }

    private func helperRow(title: String, detail: String, done: Bool, action: (String, () -> Void)) -> some View {
        HStack(spacing: Spacing.m) {
            helperText(title: title, detail: detail)
            Spacer()
            if done {
                Label("On", systemImage: "checkmark")
                    .foregroundStyle(.secondary)
            } else {
                Button(action.0, action: action.1)
                    .glassButton()
                    .accessibilityLabel("\(action.0) \(title.lowercased())")
            }
        }
    }

    private func helperText(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.headline)
            Text(detail)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
    }

    private var blockMinutes: Binding<Int> {
        Binding(
            get: { Int(settings.workDuration / 60) },
            set: { settings.workDuration = TimeInterval($0 * 60) }
        )
    }

    private func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async { notificationsAllowed = granted }
        }
    }

    private func refreshNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { status in
            DispatchQueue.main.async { notificationsAllowed = status.authorizationStatus == .authorized }
        }
    }
}
