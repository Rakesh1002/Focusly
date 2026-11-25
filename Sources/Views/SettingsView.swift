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
                        .buttonStyle(PanelButtonStyle(height: 30))
                }
            } header: {
                Text("Calendar")
            } footer: {
                Text("Shows how long you have until your next meeting.")
            }

            Section {
                Button("Copy Claude Code hooks") { copy(AgentHooks.claudeCode) }
                    .help("Paste into ~/.claude/settings.json or a project's .claude/settings.json")
                Button("Copy Codex notify line") { copy(AgentHooks.codex) }
                    .help("Paste at the top of ~/.codex/config.toml, above any [section]")
                Button("Copy Cursor hooks") { copy(AgentHooks.cursor) }
                    .help("Paste into ~/.cursor/hooks.json")
                Button("Send a test") {
                    NSWorkspace.shared.open(URL(string: "focusly://agent?state=done&name=Test")!)
                }
            } header: {
                Text("Agent hand-off")
            } footer: {
                Text("Your coding agent tells the floating timer when it is working, and calls you back when it finishes or needs you.")
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
        .tint(Brand.tide[0])
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

    private func copy(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    private func minutes(_ keyPath: ReferenceWritableKeyPath<Settings, TimeInterval>) -> Binding<Double> {
        Binding(
            get: { settings[keyPath: keyPath] / 60 },
            set: { settings[keyPath: keyPath] = $0 * 60 }
        )
    }
}

// The app is sandboxed and can't edit agent config files, so the user pastes these.
// shortcut: project names with spaces break the URL; percent-encode if users report it.
enum AgentHooks {
    static let claudeCode = #"""
    {
      "hooks": {
        "UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": "open -g \"focusly://agent?state=working&name=Claude&project=${CLAUDE_PROJECT_DIR##*/}&app=${__CFBundleIdentifier}\"" }] }],
        "Stop": [{ "hooks": [{ "type": "command", "command": "open -g \"focusly://agent?state=done&name=Claude&project=${CLAUDE_PROJECT_DIR##*/}&app=${__CFBundleIdentifier}\"" }] }],
        "Notification": [{ "hooks": [{ "type": "command", "command": "open -g \"focusly://agent?state=waiting&name=Claude&project=${CLAUDE_PROJECT_DIR##*/}&app=${__CFBundleIdentifier}\"" }] }]
      }
    }
    """#

    static let codex = #"notify = ["bash", "-lc", "open -g \"focusly://agent?state=done&name=Codex&project=${PWD##*/}&app=${__CFBundleIdentifier}\""]"#

    static let cursor = #"""
    {
      "version": 1,
      "hooks": {
        "beforeSubmitPrompt": [{ "command": "open -g \"focusly://agent?state=working&name=Cursor&app=${__CFBundleIdentifier}\"" }],
        "stop": [{ "command": "open -g \"focusly://agent?state=done&name=Cursor&app=${__CFBundleIdentifier}\"" }]
      }
    }
    """#
}
