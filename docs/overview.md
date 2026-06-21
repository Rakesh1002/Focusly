# Focusly — Overview

> **One-liner:** A native Mac (and planned iOS) focus app — repositioning from "Pomodoro timer" to a calm focus copilot for ADHD-coded knowledge workers and AI-native builders.

The single cold-start doc. A teammate should read this and know what this is, how to
run it, and the decisions that shaped it — in under 30 minutes.

## What & why
- **Problem:** ADHD-coded knowledge workers and AI-native builders context-switch constantly and ship a fraction of what they planned. Rigid Pomodoro timers break flow and trigger shame-spiral gamification rather than helping.
- **Who it's for:** ADHD-aware knowledge workers (builders included) who lose the thread mid-session. See the wedge decision in `PIVOT_A.md` (root) and the customer/market definition in [[market]].
- **What we're building:** A Mac menu-bar focus anchor that nudges you back when you drift, with calendar awareness, tasks, and session journaling. Pivot A.2 strips gamification and adds AI session summaries and body-doubling-lite, moving from a one-time $7.99 purchase to a subscription (Free / Pro / Pro+).
- **Stage:** active
- **Status right now:** v1 (Pomodoro) ships as a direct-download DMG and is in the Mac App Store resubmission cycle. Pivot A.2 work is in flight on the `focusly-ai` branch of the Mac app submodule. Marketing site is live at focusly.unquest.ai.

## How to run it
This outer repo is a thin wrapper around two git submodules (`Focusly_app/`, `focusly_web/`), each with its own repo and `CLAUDE.md`. There is no root `package.json`.

```bash
# Mac client (Swift + SwiftUI + AppKit, SPM, no third-party deps)
cd Focusly_app
swift build          # build
swift run            # run
swift test           # 5 unit tests on TimerManager
./Scripts/build_and_run.sh   # build + launch helper

# Marketing site (Next.js 15 + React 19 + Tailwind 4)
cd focusly_web
npm install
npm run dev          # Turbopack dev server
npm run build        # production build
npm run lint && npm run format
```

- **Prod URL:** https://focusly.unquest.ai (marketing site, on Vercel)
- **Repo:** https://github.com/Rakesh1002/focusly (outer wrapper) · `Rakesh1002/FocusTimer` (Mac app) · `Rakesh1002/focusly_web` (site)
- **Deploy:** Mac app via GitHub Actions (`app-store-deploy.yml` on `v*.*.*` tags) + 22 shell scripts in `Focusly_app/Scripts/`; site via Vercel.

## Where things are
| Area | Location |
|------|----------|
| Mac client (Swift) | `Focusly_app/Sources/` (Models, Views, Windows, Utilities) — submodule |
| Marketing site (Next.js) | `focusly_web/src/` — submodule |
| Strategy & decisions | `docs/strategy/`, `PIVOT_A.md` (root) |
| Product docs | `docs/product/` |
| GTM | `docs/gtm/` |
| Tests | `Focusly_app/Tests/` |

## Top 5 decisions to know
1. Soft-kill the "Mac Pomodoro" positioning; harvest v1 cashflow and pivot the codebase — see [[thesis]].
2. Narrow the wedge from broad "ADHD knowledge workers" to AI-native solo builders ("Cluely, but for shipping") — see `PIVOT_A.md`.
3. Drop cycle/streak/achievement gamification (shame-spiral risk for ADHD users) — Pivot A.2.
4. Move from $7.99 one-time to subscription tiers (Free / Pro $12 / Pro+ $19); always-on voice is Pro+ V2 only.
5. Backend (when needed) is a new Cloudflare Workers + Hono + D1 + Durable Objects repo, not bolted onto the Mac app.

## Key links
- **Strategy:** [[thesis]] · **Market/ICP:** [[market]] · **Roadmap:** [[roadmap]] · **GTM:** [[go-to-market]]
- **Wedge decision:** `PIVOT_A.md` (root) · **Validation:** [[validation-sprint]]

---
**Owner:** Rakesh Roushan · **Last reviewed:** 2026-06-21 · **Review by:** 2026-09-21
