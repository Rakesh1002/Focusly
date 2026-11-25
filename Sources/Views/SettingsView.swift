import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var soundManager: SoundManager
    @EnvironmentObject var calendarManager: CalendarManager

    var body: some View {
        Form {
            Section("Focus") {
                LabeledContent("Focus block") {
                    Stepper("\(Int(settings.workDuration / 60)) min", value: minutes(\.workDuration), in: 5...180, step: 5)
                }
                LabeledContent("Break") {
                    Stepper("\(Int(settings.breakDuration / 60)) min", value: minutes(\.breakDuration), in: 1...60)
                }
            }

            Section("Floating timer") {
                Toggle("Show floating timer", isOn: $settings.showTimeDisplay)
                Toggle("On all displays", isOn: $settings.showFloatingTimerOnAllScreens)
                    .disabled(!settings.showTimeDisplay)
            }

            Section("Break screen") {
                Toggle("Cover the screen during breaks", isOn: $settings.showBreakOverlay)
            }

            Section("Notifications") {
                Toggle("Break reminders", isOn: $settings.breakNotifications)
            }

            Section("Sound") {
                Toggle("Play sounds", isOn: $soundManager.isEnabled)
                Slider(value: $soundManager.volume, in: 0...1) {
                    Text("Volume")
                }
                .disabled(!soundManager.isEnabled)
            }

            Section {
                if calendarManager.hasAccess {
                    LabeledContent("Status", value: "Connected")
                } else {
                    Button("Connect calendar") { calendarManager.connect() }
                        .glassButton()
                }
            } header: {
                Text("Calendar")
            } footer: {
                Text("Shows how long you have until your next meeting.")
            }

            Section("General") {
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
                Link("Privacy policy", destination: URL(string: "https://focusly.unquest.ai/privacy")!)
                LabeledContent("Start or stop", value: "\u{2325}\u{2318}T")
                LabeledContent("Skip break", value: "\u{2325}\u{2318}S")
                LabeledContent("Show or hide floating timer", value: "\u{2325}\u{2318}B")
                LabeledContent("Version", value: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "-")
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .onChange(of: settings.showFloatingTimerOnAllScreens) { _ in
            if settings.showTimeDisplay {
                WindowManager.shared.showTimeDisplay()
            }
        }
        .onChange(of: settings.showBreakOverlay) { show in
            if !show {
                WindowManager.shared.hideBreakOverlay()
            }
        }
    }

    private func minutes(_ keyPath: ReferenceWritableKeyPath<Settings, TimeInterval>) -> Binding<Double> {
        Binding(
            get: { settings[keyPath: keyPath] / 60 },
            set: { settings[keyPath: keyPath] = $0 * 60 }
        )
    }
}
