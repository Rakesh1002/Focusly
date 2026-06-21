# Focusly — Architecture

## System overview
Focusly is a local-first native macOS menu-bar app plus a separate marketing/download site. The outer repo (`Rakesh1002/focusly`) is a thin wrapper that pins two git submodules: the Swift Mac client and the Next.js site. Today there is no backend — all app data is stored locally on device. A Cloudflare Workers backend is planned for the Pivot A.2 subscription/sync surface.

```
focusly (wrapper repo)
├── Focusly_app/   (submodule: Rakesh1002/FocusTimer)
│     SwiftUI + AppKit menu-bar app, SPM, UserDefaults storage, EventKit calendar
├── focusly_web/   (submodule: Rakesh1002/focusly_web)
│     Next.js 15 marketing site → Vercel → focusly.unquest.ai
└── (planned) focusly-backend/  Cloudflare Workers + Hono + D1 + Durable Objects
```

## Components
| Component | Responsibility | Tech |
|-----------|----------------|------|
| Mac client | Timer, tasks, statistics, calendar awareness, session journaling, break overlays, menu-bar UI | Swift 5.9, SwiftUI + AppKit, SPM, `.macOS(.v13)`, no third-party deps |
| Marketing site | Positioning, features, pricing, download, privacy/terms, SEO/LLM discoverability | Next.js 15.5, React 19, TypeScript 5, Tailwind 4, framer-motion, Vercel |
| Backend (planned) | Auth, subscriptions (Stripe/Razorpay), AI session summaries, body-doubling-lite, sync | Cloudflare Workers + Hono + D1 + Durable Objects |

## Data model
- **Mac client:** state via vanilla `ObservableObject` + `@Published` + `@EnvironmentObject`. Persistence via a dedicated `UserDefaults.app` suite (no Core Data / SwiftData / SQLite yet). Notifications via `UNUserNotificationCenter` (`TASK_REMINDER` + `task_*` categories). Calendar via EventKit.
- Note: `TaskManager.Task` shadows `Swift.Task` — resolve (rename to `TodoItem`/`FocusTask`) before adopting `async/await`.
- {Document the planned backend schema (users, subscriptions, sessions, summaries) once the Cloudflare D1 design exists.}

## External dependencies
| Service | Used for | Failure mode |
|---------|----------|--------------|
| Apple EventKit / Calendar | Meeting-aware focus suggestions and conflict warnings | Degrades to manual timer; feature partly superseded by macOS Tahoe native Focus modes (see [[thesis]]) |
| Mac App Store / Setapp | Distribution of the Mac client | MAS rejections have gated releases; direct-download DMG is the fallback channel |
| Vercel | Hosting the marketing site | Site down; app keeps working offline (local-first) |
| Stripe / Razorpay (planned) | Subscription billing | No new paid signups; existing local app unaffected |

## Key constraints & trade-offs
- **Local-first / privacy:** v1 stores everything on-device with no telemetry. This is a marketing pillar but constrains cross-device sync, which the subscription pivot needs — hence the planned backend.
- **No Xcode project file:** SPM-only keeps the build scriptable and CI-friendly; trade-off is less GUI tooling.
- **Sandboxing:** sandboxed entitlements for MAS, a non-sandboxed variant for direct download — two build paths to maintain.
- **Platform risk:** macOS Tahoe native Focus modes and Apple Intelligence calendar features erode the original "auto-focus on meetings" wedge; the pivot leans on AI copilot + body-doubling instead (see [[thesis]], `PIVOT_A.md`).
- {Deeper backend architecture (auth model, sync strategy, AI summary pipeline) — to design when the subscription build starts.}

---
**Owner:** Rakesh Roushan · **Last reviewed:** 2026-06-21 · **Review by:** 2026-09-21
