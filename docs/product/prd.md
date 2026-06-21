# Focusly — PRD

> **Scope:** Pivot A.2 MVP — the validation-gated subscription product. This PRD frames the product; deeper specs live in [[jtbd]], [[roadmap]], [[design]], [[user-journey]], and [[validation-sprint]].

## Goal
Move Focusly from a one-time $7.99 Pomodoro timer to a subscription focus copilot that ADHD-coded knowledge workers and AI-native builders keep using and pay for. Target outcome: validated demand and a path to $3K MRR by Day 90 (kill bar in `CLAUDE.md`).

## Users & jobs
For ADHD-aware knowledge workers (builders included) who lose the thread mid-session and ship a fraction of what they planned. Primary positioning under test: "A Mac focus anchor that nudges you back when you drift." See [[market]] (ICP) and [[jtbd]] for the jobs-to-be-done.

## Requirements
### Must have
- [ ] Visual day blocks for the current session/plan
- [ ] Drift detection + gentle nudge back to the task
- [ ] AI session summary at end of a focus block
- [ ] Body-doubling-lite
- [ ] Free tier + paid Pro tier (subscription billing)

### Should have
- [ ] Calendar-aware focus suggestions (degrading gracefully as macOS native Focus modes overlap)
- [ ] Session journaling and review
- [ ] Pro+ tier ($19) with always-on voice nudges (off by default, V2)

### Non-goals
- Cycle/streak/achievement gamification — explicitly stripped (shame-spiral risk for ADHD users)
- iOS / Apple Watch apps — V2
- Always-on voice nudges in the base tier — Pro+ V2 only
- Screenshot OCR — privacy minefield, never

## Success metrics
- Validation gates in [[validation-sprint]] pass (demand signal before full build)
- {Define activation + week-2 retention targets for the MVP}
- $3K MRR by Day 90 (kill bar)

## Open questions
- Final price ladder (Free / Pro $12 / Pro+ $19) — confirm against willingness-to-pay from validation
- How much of the calendar wedge survives macOS Tahoe + Apple Intelligence — see [[thesis]]
- {Backend scope for MVP: how much sync vs. local-only at launch}

---
**Owner:** Rakesh Roushan · **Last reviewed:** 2026-06-21 · **Review by:** 2026-09-21
