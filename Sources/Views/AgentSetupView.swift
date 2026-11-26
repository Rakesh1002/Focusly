import SwiftUI

struct AgentSetupView: View {
    @EnvironmentObject var agentWatch: AgentWatch
    @State private var installations: [CodingAgent: HookInstallation] = [:]
    @State private var copied: CodingAgent?
    @State private var testSentAt: Date?
    private let files = AgentSetupFiles()

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.m) {
            VStack(spacing: 0) {
                ForEach(CodingAgent.allCases) { agent in
                    if agent != .claude { Divider().padding(.leading, 12) }
                    row(agent, status: installations[agent] ?? .needsAccess)
                }
            }
            .background(Ink.fill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            HStack {
                Button(action: refresh) { Label("Refresh", systemImage: "arrow.clockwise") }
                Spacer()
                Button {
                    testSentAt = Date()
                    NSWorkspace.shared.open(URL(string: "focusly://agent?state=done&name=Test")!)
                } label: {
                    if let testSentAt, let received = agentWatch.lastLinkTest, received >= testSentAt {
                        Label("Link works", systemImage: "checkmark")
                    } else { Text("Test Focusly link") }
                }
                .help("Send a test to Focusly’s URL handler")
            }
            .buttonStyle(.borderless)
            .font(.system(size: 12))
        }
        .padding(14)
        .onAppear(perform: refresh)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in refresh() }
    }

    private func row(_ agent: CodingAgent, status: HookInstallation) -> some View {
        let last = agentWatch.lastSignals[agent.rawValue]
        let signalOnly = last != nil && (status == .needsAccess || status == .unreadable)
        return HStack(alignment: .center, spacing: Spacing.s) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(agent.rawValue).font(.system(size: 14, weight: .semibold))
                Label(signalOnly ? "Signal received" : status.title, systemImage: signalOnly ? "waveform" : symbol(for: status))
                    .font(.system(size: 12, weight: .medium))
                if let last {
                    if agentWatch.name == agent.eventName && agentWatch.state == .working {
                        Text("Working now").font(.caption).foregroundStyle(.secondary)
                    } else {
                        Text("Last signal \(last, style: .relative) ago")
                            .font(.caption).foregroundStyle(.secondary)
                            .help(last.formatted())
                    }
                } else if status == .installed {
                    Text(agent == .codex ? "Awaiting signal. Trust in /hooks and send a prompt." : "Awaiting first signal")
                        .font(.caption).foregroundStyle(.secondary)
                }
                if status != .installed {
                    Text(files.hasSelectedFolder(for: agent) ? agent.fileName : "~/" + agent.folderName + "/" + agent.fileName)
                        .font(.caption).foregroundStyle(.secondary)
                        .help("Expected config in the agent’s folder")
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            switch status {
            case .needsAccess, .unreadable:
                Button("Check…") { chooseFolder(for: agent) }
                    .buttonStyle(PanelButtonStyle(height: 28)).frame(width: 84)
            case .missing, .partial, .legacyNotify:
                if agent == .codex {
                    Button(status == .legacyNotify || status == .missing ? "Install…" : "Repair…") { installCodex() }
                        .buttonStyle(PanelButtonStyle(height: 28)).frame(width: 84)
                } else {
                    Button(copied == agent ? "Copied" : "Copy hooks") { copyHooks(for: agent) }
                        .buttonStyle(PanelButtonStyle(height: 28)).frame(width: 84)
                }
            default:
                Menu("Manage") { actions(for: agent) }
                    .fixedSize()
                    .accessibilityLabel("Manage \(agent.rawValue) hooks")
            }
        }
        .padding(12)
        .contextMenu { actions(for: agent) }
    }

    @ViewBuilder private func actions(for agent: CodingAgent) -> some View {
        Button("Choose config folder…") { chooseFolder(for: agent) }
        if agent == .codex {
            Button("Install or repair hooks…") { installCodex() }
        } else {
            Button("Copy hook settings") { copyHooks(for: agent) }
        }
    }

    private func symbol(for status: HookInstallation) -> String {
        switch status {
        case .installed: return "checkmark.circle.fill"
        case .missing: return "minus.circle"
        case .partial, .disabled, .invalid, .legacyNotify: return "exclamationmark.circle"
        case .unreadable, .needsAccess: return "questionmark.circle"
        }
    }

    private func refresh() {
        installations = Dictionary(uniqueKeysWithValues: CodingAgent.allCases.map { ($0, files.status(for: $0)) })
    }

    private func copyHooks(for agent: CodingAgent) {
        guard let snippet = agent.snippet else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(snippet, forType: .string)
        copied = agent
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { if copied == agent { copied = nil } }
    }

    private func installCodex() {
        guard files.hasSelectedFolder(for: .codex) else {
            chooseFolder(for: .codex, install: true)
            return
        }
        do { try files.withFolder(for: .codex) { try installCodex(in: $0) } }
        catch { NSAlert(error: error).runModal() }
        refresh()
    }

    private func installCodex(in folder: URL) throws {
        try CodexHooks.install(in: folder)
        let alert = NSAlert()
        alert.messageText = "Codex hooks installed"
        alert.informativeText = "Trust the Updating Focusly commands in /hooks, then send a prompt. Your last signal will appear here. If you previously added Focusly’s notify line to config.toml, remove that line to avoid duplicate alerts."
        alert.runModal()
    }

    private func chooseFolder(for agent: CodingAgent, install: Bool = false) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.showsHiddenFiles = true
        panel.prompt = install ? "Install hooks" : "Check folder"
        panel.message = install ? "Choose your Codex folder to add Focusly to hooks.json."
                                : "Choose your \(agent.rawValue) config folder so Focusly can check \(agent.fileName)."
        panel.directoryURL = (try? files.withFolder(for: agent) { $0 }) ?? agent.defaultFolder
        guard panel.runModal() == .OK, let folder = panel.url else { return }
        let scoped = folder.startAccessingSecurityScopedResource()
        defer { if scoped { folder.stopAccessingSecurityScopedResource() } }
        do {
            try files.remember(folder, for: agent)
            if install { try installCodex(in: folder) }
        } catch {
            NSAlert(error: error).runModal()
        }
        refresh()
    }

}
