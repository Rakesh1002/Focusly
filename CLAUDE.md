# Focusly — Repo Memory

## Current state (May 2026)
- **Pivot A.2 in progress** — repositioning from "Mac Pomodoro" to **"calm focus copilot for ADHD-coded knowledge workers (builders included)"**, Tiimo-archetype.
- Strategy/pivot decision docs: `STRATEGY.md`, `PIVOT_A.md`, plus `~/.claude/plans/status-where-we-are-generic-bunny.md` (current sprint plan).
- Outer repo is a thin wrapper around two child repos (`Focusly_app/`, `focusly_web/`) — both have their own `CLAUDE.md`.

## Layout
- `Focusly_app/` — Mac client. Swift + SwiftUI + AppKit, menu-bar app. Branch `focusly-ai`. Separate repo `Rakesh1002/FocusTimer`.
- `focusly_web/` — marketing site. Next.js 15 + Tailwind 4. On Vercel. Separate repo `Rakesh1002/focusly_web`.
- `screens/` — marketing screenshots, untracked.
- `docs/v2/` — V2 planning notes.

## Active branch
- Outer: `main` (untracked: `PIVOT_A.md`, `STRATEGY.md`, `screens/`).
- `Focusly_app`: **`focusly-ai`** (in-flight pivot work; do not delete).
- `focusly_web`: `main` (deleted DMG artifact only).

## Do-not-push
- `Focusly_app/Docs/notirzation_app_pwd` exists locally (Apple app-specific password shape). The `Docs/` folder is gitignored, so it cannot be committed accidentally — but rotate the password defensively.
- Never `git push --force` to `main` on any of the three repos.

## Sprint goal (14 days, started 2026-05-09)
- MVP: visual day blocks + AI session summary + body-doubling-lite + free tier + Stripe Pro $12/mo.
- Drop always-on voice nudges. Voice is Pro+ V2.
- Backend: new repo `focusly-backend/` (Cloudflare Workers + Hono + D1 + Durable Objects).
- Kill bar: $3K MRR by Day 90.
