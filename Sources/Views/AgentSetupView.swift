import SwiftUI

/// Tray screen that connects Claude Code, Codex or Cursor to the floating timer.
struct AgentSetupView: View {
    @EnvironmentObject var agentWatch: AgentWatch
    @State private var copied: String?

    private struct Integration: Identifiable {
        let id: String
        let destination: String
        let snippet: String?
    }

    private let integrations = [
        Integration(id: "Claude Code", destination: "~/.claude/settings.json", snippet: AgentHooks.claudeCode),
        Integration(id: "Codex", destination: "Choose your Codex config folder", snippet: nil),
        Integration(id: "Cursor", destination: "~/.cursor/hooks.json", snippet: AgentHooks.cursor),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            Text("Your agent tells the floating timer when it is working, and calls you back when it finishes or needs you. Install the Codex hooks or copy the settings for your tool.")
                .font(.system(size: 12))
                .foregroundStyle(Ink.secondary)
                .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: 0) {
                ForEach(Array(integrations.enumerated()), id: \.element.id) { index, integration in
                    if index > 0 { Divider().padding(.leading, 12) }
                    row(integration)
                }
            }
            .background(Ink.fill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            HStack(spacing: Spacing.s) {
                Circle()
                    .fill(agentWatch.state == nil ? Ink.secondary : Ink.primary)
                    .frame(width: 6, height: 6)
                    .accessibilityHidden(true)
                Text(status)
                    .font(.system(size: 12))
                    .foregroundStyle(Ink.secondary)
                Spacer()
                Button("Send a test") {
                    NSWorkspace.shared.open(URL(string: "focusly://agent?state=done&name=Test")!)
                }
                .buttonStyle(PanelButtonStyle(height: 28))
                .frame(width: 100)
            }
        }
        .padding(14)
    }

    private func row(_ integration: Integration) -> some View {
        HStack(spacing: Spacing.m) {
            VStack(alignment: .leading, spacing: 2) {
                Text(integration.id)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Ink.primary)
                Text(integration.destination)
                    .font(.system(size: 11))
                    .foregroundStyle(Ink.secondary)
                    .lineLimit(2)
            }
            Spacer()
            if let snippet = integration.snippet {
                Button {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(snippet, forType: .string)
                    copied = integration.id
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        if copied == integration.id { copied = nil }
                    }
                } label: {
                    Label(copied == integration.id ? "Copied" : "Copy",
                          systemImage: copied == integration.id ? "checkmark" : "doc.on.doc")
                }
                .buttonStyle(PanelButtonStyle(height: 28))
                .frame(width: 92)
                .accessibilityLabel(copied == integration.id ? "Copied" : "Copy \(integration.id) hook")
            } else {
                Button("Install…", action: installCodexHooks)
                    .buttonStyle(PanelButtonStyle(height: 28))
                    .frame(width: 92)
                    .accessibilityLabel("Install Codex hooks")
            }
        }
        .padding(12)
    }

    private func installCodexHooks() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.showsHiddenFiles = true
        panel.prompt = "Install hooks"
        panel.message = "Choose your Codex config folder. Focusly will add its entries to hooks.json."
        if let home = NSHomeDirectoryForUser(NSUserName()) {
            panel.directoryURL = URL(fileURLWithPath: home).appendingPathComponent(".codex")
        }
        guard panel.runModal() == .OK, let folder = panel.url else { return }
        let scoped = folder.startAccessingSecurityScopedResource()
        defer { if scoped { folder.stopAccessingSecurityScopedResource() } }
        let alert = NSAlert()
        do {
            try CodexHooks.install(in: folder)
            alert.messageText = "Focusly hooks installed"
            alert.informativeText = "Open /hooks in Codex and trust the three Updating Focusly commands. If you added Focusly’s old notify line to config.toml, remove that line to avoid duplicate alerts."
        } catch {
            alert.messageText = "Couldn’t install the Codex hooks"
            alert.informativeText = error.localizedDescription
        }
        alert.runModal()
    }

    private var status: String {
        switch agentWatch.state {
        case .working: return "\(agentWatch.name) is working"
        case .done: return "\(agentWatch.name) finished"
        case .waiting: return "\(agentWatch.name) needs you"
        case nil: return "Idle"
        }
    }
}

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
