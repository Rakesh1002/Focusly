<p align="center">
  <img src="https://focusly.roushan.xyz/images/v2/focusly-icon.png" width="128" height="128" alt="Focusly icon">
</p>

<h1 align="center">Focusly</h1>

<p align="center">
  A calm floating focus timer for your Mac. It keeps the one thing you're working on in view, shows how long you have until your next meeting, and brings you back when your coding agent is done.
</p>

<p align="center">
  <a href="https://go2.gg/focusly">Mac App Store</a> ·
  <a href="https://go2.gg/focusly-download">Download</a> ·
  <a href="https://go2.gg/focusly-site">Website</a> ·
  <a href="https://go2.gg/focusly-press">Press kit</a>
</p>

![The Focusly floating timer above your work](https://focusly.roushan.xyz/press/focusly-1-hero.jpg)

## Install

- **Mac App Store:** [go2.gg/focusly](https://go2.gg/focusly)
- **Direct download:** [go2.gg/focusly-download](https://go2.gg/focusly-download), a notarised DMG
- **Homebrew:**

  ```sh
  brew tap rakesh1002/tap && brew trust rakesh1002/tap && brew install --cask focusly
  ```

Focusly needs macOS 13 or later on a Mac with Apple silicon.

## What it does

- **Floating timer.** Your task, the countdown and the time of day in one small glass pill above your other windows. Use the arrows on the timer to switch between the full panel and a single-line mini timer. Drag it anywhere. Each display remembers its position. Hide it with ⌥⌘B without quitting.
- **Your next meeting.** With read-only calendar access, Focusly shows how long you have until your next meeting and warns you before a block runs into one.
- **Breaks that happen.** A calm full-screen break on every display when a block ends. The next block waits until you start it.
- **Pick up where you left off.** Leave yourself one line after each block. Focusly shows it when you come back.
- **Coding agent hand-off.** Claude Code, Codex and Cursor tell Focusly when a run starts, finishes or needs you. One click takes you back to your terminal.
- **Keyboard first.** ⌥⌘T starts or stops a block, ⌥⌘S skips a break, ⌥⌘B shows or hides the floating timer.
- **Private.** No account, no analytics and no network connections. Everything stays on your Mac.

![A coding agent finishing its run](https://focusly.roushan.xyz/press/focusly-3-agent.jpg)

## Coding agent hand-off

Agents talk to Focusly through its URL scheme:

```sh
open -g "focusly://agent?state=working&name=Claude&project=api&app=com.apple.Terminal"
```

`state` is `working`, `waiting` or `done`. `app` is the bundle ID of the app to return to, which the hooks below fill in from `__CFBundleIdentifier`. Open Settings → Coding agent hand-off to connect an agent or send a test event.

**Claude Code**, in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [{ "hooks": [{ "type": "command", "command": "open -g \"focusly://agent?state=working&name=Claude&project=${CLAUDE_PROJECT_DIR##*/}&app=${__CFBundleIdentifier}\"" }] }],
    "Stop": [{ "hooks": [{ "type": "command", "command": "open -g \"focusly://agent?state=done&name=Claude&project=${CLAUDE_PROJECT_DIR##*/}&app=${__CFBundleIdentifier}\"" }] }],
    "Notification": [{ "hooks": [{ "type": "command", "command": "open -g \"focusly://agent?state=waiting&name=Claude&project=${CLAUDE_PROJECT_DIR##*/}&app=${__CFBundleIdentifier}\"" }] }]
  }
}
```

**Codex** — In Focusly, choose **Settings → Coding agent hand-off → Codex → Install…**. Select your Codex config folder (usually `~/.codex`, or your custom `CODEX_HOME`). Focusly merges its entries into `hooks.json`. You can run Install again after an update.

Open `/hooks` in Codex and trust the **Updating Focusly** commands. `UserPromptSubmit` starts the working indicator. `Stop` and `Interrupt` end it. If you are already in the originating app, the floating timer clears the agent row and the tray shows **Idle**. If you switched away, Focusly shows **Codex done** until you return.

If you previously added Focusly’s `notify` line to `config.toml`, remove that line to avoid duplicate completion alerts. Keep any notification command used by another integration.

**Cursor**, in `~/.cursor/hooks.json`:

```json
{
  "version": 1,
  "hooks": {
    "beforeSubmitPrompt": [{ "command": "open -g \"focusly://agent?state=working&name=Cursor&app=${__CFBundleIdentifier}\"" }],
    "stop": [{ "command": "open -g \"focusly://agent?state=done&name=Cursor&app=${__CFBundleIdentifier}\"" }]
  }
}
```

## Build from source

Focusly is a Swift package with no third-party dependencies.

```sh
swift build
swift test
```

## Support

Email support@focusly.roushan.xyz or [open an issue](../../issues).

## License

MIT. Made by Roushan, Inc.
