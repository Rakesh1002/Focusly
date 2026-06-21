# Focusly - Product Roadmap

**Date:** 24 May 2026  
**Owner:** [STRATEGY.md](../STRATEGY.md)  
**References:** [VALIDATION_SPRINT.md](./VALIDATION_SPRINT.md), [JTBD.md](./JTBD.md), [SCREENS.md](./SCREENS.md)  
**Purpose:** Replace the 6-week full v2 build with a validation-gated roadmap.

---

## Current Decision

The previous roadmap assumed:

- an existing Swift/SwiftUI app,
- an existing Next.js marketing site,
- roughly 95% code reuse,
- a 6-week v2 build,
- MAS + Setapp + Stripe launch,
- body doubling and coach B2B as near-term releases.

Those assumptions are not approved. In this workspace, `Focusly_app/` and `focusly_web/` are empty, so the implementation plan must begin with codebase verification.

---

## Phase 0 - Validation Sprint (Weeks 1-2)

**Goal:** Decide whether to build anything beyond a narrow prototype.

Canonical plan: [VALIDATION_SPRINT.md](./VALIDATION_SPRINT.md)

### Workstreams

| Workstream | Output |
|---|---|
| Codebase verification | Buildable existing app, or explicit greenfield decision |
| Competitive reset | Updated table for Focana, Focusmo, Focura, Focarium, Nudge, Tiimo, Focus Bear, Focusmate, Llama Life |
| Customer discovery | 10 interviews with target Mac knowledge workers |
| Fake-door demand test | Landing page or mockup with waitlist/paid-intent CTA |
| Prototype | Task capture + visible anchor + drift nudge only, if feasible |

### Go criteria

- 200 qualified waitlist signups, or
- 20 paid/beta commitments,
- 10 completed interviews,
- 70% interview acceptance of opt-in active app/window drift detection,
- codebase status resolved.

---

## Phase 1 - Narrow MVP (Only If Phase 0 Passes)

**Positioning:** Native Mac focus anchor with drift-aware nudges.

### Approved scope

| Feature | Requirement |
|---|---|
| Task capture | User names the current task before starting |
| Always-visible anchor | Task and timer remain visible while working |
| Drift nudge | Opt-in active app/window heuristic triggers a gentle toast |
| Privacy controls | Clear permission copy, pause, disable, delete local history |
| Re-entry note | End-session note captures where to resume |
| Local history | Minimal local list of recent sessions |

### Explicitly deferred

- AI voice nudges,
- LLM task breakdown,
- body doubling,
- coach dashboard,
- iOS or Watch,
- Stripe/StoreKit subscription infrastructure,
- Setapp or MAS submission,
- long-form SEO/blog program,
- creator affiliate program.

### Engineering acceptance

- Session starts in under 10 seconds.
- Idle CPU remains negligible for a menu-bar utility.
- Drift detection stores no screenshots, keystrokes, or page contents.
- User can pause or disable drift detection during a session.
- App works without account creation.

---

## Phase 2 - Monetization Test (After MVP Usage)

Only after real MVP usage should pricing be tested.

Recommended tests:

- $29-$79 lifetime, because several competitors use lifetime pricing.
- $5-$10 monthly only if users strongly prefer subscription.
- Optional paid beta deposit before building recurring billing.

Do not build Stripe, StoreKit, or Setapp flows until users have demonstrated willingness to pay.

---

## Phase 3 - Expansion Candidates

These remain hypotheses, not roadmap commitments:

| Candidate | Evidence required before build |
|---|---|
| AI voice nudge | Users like text nudges but ask for audio |
| LLM task breakdown | Users fail at task capture even with simple UX |
| Body doubling | Users explicitly rank accountability above drift recovery |
| Coach B2B | Coaches refer active beta users without a dashboard |
| iOS/Watch | Existing Mac users ask for cross-device continuity |
| Builder mode | ADHD-Mac validates but founder/operator segment converts better |

---

## Hard Cuts Until Further Notice

- No medical or treatment claims.
- No screenshots or OCR.
- No keystroke logging.
- No anonymous matching or social features.
- No B2B coach product.
- No "100K MRR" roadmap commitments.
- No App Store/Setapp launch sprint before product demand is validated.

---
**Owner:** Rakesh Roushan · **Last reviewed:** 2026-06-21 · **Review by:** 2026-09-21
