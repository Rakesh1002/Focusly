import SwiftUI

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
            ZStack {
                HStack {
                    Button(step == 0 ? "Skip" : "Back") {
                        if step == 0 { onFinish(false) } else { step = 0 }
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Ink.secondary)
                    Spacer()
                }
                Button(step == 0 ? "Next" : "Start") {
                    if step == 0 { step = 1 } else { onFinish(true) }
                }
                .buttonStyle(OrbButtonStyle())
                // On step 0 the task field's own Return advances; both handling it would skip the helpers step.
                .keyboardShortcut(step == 1 ? .defaultAction : nil)
            }
        }
        .padding(28)
        .frame(width: 480, height: 480)
        .onAppear(perform: refreshNotificationStatus)
    }

    private var taskStep: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            HStack(spacing: Spacing.m) {
                AppMark(size: 48)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Welcome to Focusly")
                        .font(.system(size: 30, weight: .light))
                        .foregroundStyle(Ink.primary)
                    Text("One task. Always in view.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Ink.secondary)
                }
            }
            Text("A small anchor in the corner of your screen that shows the one thing you are doing, how long you have, and brings you back when you drift.")
                .font(.system(size: 14))
                .foregroundStyle(Ink.secondary)
                .fixedSize(horizontal: false, vertical: true)
            TaskField { step = 1 }
            DurationPicker()
            anchorPreview
        }
    }

    private var anchorPreview: some View {
        let task = timerManager.task.trimmingCharacters(in: .whitespacesAndNewlines)
        let shape = RoundedRectangle(cornerRadius: 16, style: .continuous)
        return VStack(spacing: 6) {
            HStack(spacing: Spacing.s) {
                FocusRing(progress: 0.3, lineWidth: 2.5)
                    .frame(width: 16, height: 16)
                Text(task.isEmpty ? "Your one task" : task)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(task.isEmpty ? Ink.secondary : Ink.primary)
                    .lineLimit(1)
                Spacer(minLength: Spacing.s)
                Text(settings.workDuration.clock)
                    .font(.system(size: 13, weight: .medium).monospacedDigit())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(width: 280)
            .glassBackground(in: shape)
            .overlay(shape.strokeBorder(Ink.hairline, lineWidth: 0.5))
            Text("Your floating timer, always in view")
                .font(.system(size: 11))
                .foregroundStyle(Ink.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.s)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Preview of the floating timer")
    }

    private var helpersStep: some View {
        VStack(alignment: .leading, spacing: Spacing.l) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("A few helpers")
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(Ink.primary)
                Text("All optional. Change them any time in Settings.")
                    .font(.system(size: 14))
                    .foregroundStyle(Ink.secondary)
            }
            helperRow(
                symbol: "bell.badge.fill",
                title: "Notifications",
                detail: "A gentle note when a block or break ends.",
                done: notificationsAllowed,
                action: ("Allow", requestNotifications)
            )
            helperRow(
                symbol: "calendar",
                title: "Calendar runway",
                detail: "See how long you have until your next meeting.",
                done: calendarManager.hasAccess,
                action: ("Connect", calendarManager.connect)
            )
            HStack(spacing: Spacing.m) {
                helperText(symbol: "power", title: "Launch at login", detail: "Have the anchor ready when you sit down.")
                Spacer()
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
                    .toggleStyle(.switch)
                    .labelsHidden()
            }
        }
    }

    private func helperRow(symbol: String, title: String, detail: String, done: Bool, action: (String, () -> Void)) -> some View {
        HStack(spacing: Spacing.m) {
            helperText(symbol: symbol, title: title, detail: detail)
            Spacer()
            if done {
                Label("On", systemImage: "checkmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Ink.secondary)
            } else {
                Button(action.0, action: action.1)
                    .buttonStyle(.plain)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Ink.secondary)
                    .accessibilityLabel("\(action.0) \(title.lowercased())")
            }
        }
    }

    private func helperText(symbol: String, title: String, detail: String) -> some View {
        HStack(spacing: Spacing.m) {
            IconChip(symbol: symbol, size: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Ink.primary)
                Text(detail)
                    .font(.system(size: 12))
                    .foregroundStyle(Ink.secondary)
            }
        }
    }

    private func requestNotifications() {
        Notifier.requestAuthorization { granted in
            DispatchQueue.main.async { notificationsAllowed = granted }
        }
    }

    private func refreshNotificationStatus() {
        Notifier.isAuthorized { allowed in
            DispatchQueue.main.async { notificationsAllowed = allowed }
        }
    }
}
