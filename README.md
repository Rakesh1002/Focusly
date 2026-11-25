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

- **Floating timer.** Your task, the countdown and the time of day in one small glass pill above your other windows. Drag it anywhere; every display remembers where you put it. Hide it with ⌥⌘B without quitting.
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

`state` is `working`, `waiting` or `done`. `app` is the bundle ID of the app to return to, which the hooks below fill in from `__CFBundleIdentifier`. The same snippets are in the app under Settings, then Coding agent hand-off, with a Copy button and Send a test.

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

**Codex**, at the top of `~/.codex/config.toml`, above any `[section]`:

```toml
notify = ["bash", "-lc", "open -g \"focusly://agent?state=done&name=Codex&project=${PWD##*/}&app=${__CFBundleIdentifier}\""]
```

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
