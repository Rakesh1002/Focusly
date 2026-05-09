# Focusly_app — Repo Memory

## What this is
Native Mac menu-bar focus app (SwiftUI + AppKit). Currently shipping as `Focusly` (Pomodoro) on direct-download DMG; MAS in resubmit cycle.

## Current pivot — Pivot A.2 (2026-05-09)
Branch **`focusly-ai`** is the active pivot branch. Reposition to "calm focus copilot for ADHD-coded knowledge workers (builders included)" — Tiimo-archetype. Sprint plan at `~/.claude/plans/status-where-we-are-generic-bunny.md`.

## Stack
- Swift 5.9, SwiftUI + AppKit, `.macOS(.v13)`. SPM package, no Xcode project file. **No third-party Swift deps.**
- Bundle id `unquest.focusly`, team `933FJ3W655`.
- Sandboxed (`Focusly.entitlements`) for MAS; non-sandboxed variant (`Focusly.developerid.entitlements`) for direct-download.
- Build/dist via 22 shell scripts in `Scripts/` and GitHub Actions.

## Layout
- `Sources/Models/` — managers (Timer, Task, Statistics, Calendar, Session, Notification, Sound, BreakActivities, Settings, Preset, AppSetup, AppCleanup, **FocusMonitor (new for pivot)**).
- `Sources/Views/` — SwiftUI views (MenuBar, Tasks, Statistics, Calendar, Settings, Onboarding, SessionJournal, etc).
- `Sources/Windows/` — `TimeDisplayWindow` (floating timer), `BreakOverlayWindow`, `WindowManager`.
- `Sources/Utilities/` — `ColorTheme`, `GlassStyle` (glass-morphism), `KeyboardShortcutManager`, `PermissionManager`, `AppUserDefaults`.

## Build / test
- `swift build` (clean from repo root)
- `swift test` (5 unit tests on `TimerManager`, runs in <0.01s)
- CI: `.github/workflows/ci.yml` runs build+test on push to `main` / `focusly-ai*` and PR to main.
- App Store deploy: `.github/workflows/app-store-deploy.yml` triggered on `v*.*.*` tags.

## Do-not-push
- `Docs/notirzation_app_pwd` is an Apple app-specific password sitting on disk. `Docs/` is gitignored — but **rotate** the password defensively in App Store Connect when convenient.

## Conventions
- State management: vanilla `ObservableObject` + `@Published` + `@EnvironmentObject`.
- Storage: `UserDefaults.app` suite (no Core Data / SwiftData / SQLite yet).
- Notifications: `UNUserNotificationCenter` with `TASK_REMINDER` + `task_*` categories.
- Mock calendar data toggle is now `#if DEBUG`-gated (was a ship risk).
- `TaskManager.Task` shadows `Swift.Task` — note before adopting `async/await`; consider rename to `TodoItem` / `FocusTask`.

## Out of scope (pivot)
- Cycle/streak/achievement gamification — to be stripped (research: shame-spiral for ADHD users).
- iOS / Watch — V2.
- Always-on voice nudges — Pro+ V2 only, off by default.
- Screenshot OCR — privacy minefield, never.
