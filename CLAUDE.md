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
- `Sources/Models/` — managers (Timer, Calendar, Sound, Settings, AppSetupManager, FocusMonitor).
- `Sources/Views/` — SwiftUI views (MenuBar, Settings, Onboarding).
- `Sources/Windows/` — `TimeDisplayWindow` (floating timer), `BreakOverlayWindow`, `WindowManager`.
- `Sources/Utilities/` — `ColorTheme`, `KeyboardShortcutManager`, `Notifier`, `AppUserDefaults`.

## Build / test
- `swift build` (clean from repo root)
- `swift test` (unit tests on `TimerManager` and window reconcile, runs in <0.01s)
- CI: `.github/workflows/ci.yml` runs build+test on push to `main` / `focusly-ai*` and PR to main.
- App Store deploy: `.github/workflows/app-store-deploy.yml` triggered on `v*.*.*` tags.

## Do-not-push
- `Docs/notirzation_app_pwd` is an Apple app-specific password sitting on disk. `Docs/` is gitignored — but **rotate** the password defensively in App Store Connect when convenient.

## Conventions
- State management: vanilla `ObservableObject` + `@Published` + `@EnvironmentObject`.
- Storage: `UserDefaults.app` suite (no Core Data / SwiftData / SQLite yet).
- Notifications: `Notifier.send` (swappable in tests; `UNUserNotificationCenter` throws without an app bundle).
- Mock calendar data toggle is now `#if DEBUG`-gated (was a ship risk).

## Out of scope (pivot)
- Cycle/streak/achievement gamification — to be stripped (research: shame-spiral for ADHD users).
- iOS / Watch — V2.
- Always-on voice nudges — Pro+ V2 only, off by default.
- Screenshot OCR — privacy minefield, never.
