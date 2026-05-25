# Focusly - Strategy Memo

**Author:** Rakesh Roushan  
**Date:** 24 May 2026  
**Status:** No-Go as written; conditional Go only after validation sprint  
**Repo reality:** In this workspace, `Focusly_app/` and `focusly_web/` are empty directories. Existing Swift/Next.js code claims are not verifiable here.  
**Brand:** Sub-product of UnQuest

---

## TL;DR

**Decision: No-Go on the full ADHD-Mac pivot as written.**

The underlying problem is real: late-diagnosed ADHD adults and ADHD-coded Mac knowledge workers struggle with task initiation, time blindness, drift, hyperfocus, and re-entry. However, the May 23 strategy overstated three things:

1. **Moat:** The "unclaimed Mac ADHD copilot" lane is not empty.
2. **Feasibility:** The repo does not contain the cited app/site code, so "95% reuse" and a 6-week implementation plan are unverified.
3. **GTM math:** The path to $100K MRR relies on aggressive channel assumptions that have not been validated.

**Approved path:** Run a 2-week validation sprint before committing to a full product pivot.

Focusly should be repositioned as a narrow hypothesis:

> **A native Mac focus anchor with drift-aware nudges for ADHD-aware knowledge work.**

Not: a broad ADHD copilot, coaching platform, body-doubling network, CBT product, or full multi-channel app business.

---

## What Changed

### 1. Repo reality invalidates the build plan

The current workspace has empty `Focusly_app/` and `focusly_web/` directories. The prior docs referenced concrete Swift/SwiftUI, AppKit, Next.js, tests, workflows, and deployment scripts, but those files are not present here.

**Implication:** The roadmap must start with a codebase verification gate. If the real code exists elsewhere, import or link it before estimating. If it does not, treat Focusly as greenfield.

### 2. The competitive lane is more crowded than claimed

Current web search shows direct and adjacent Mac ADHD/focus products:

- [Focana](https://focana.app/) - Mac ADHD/busy-brain focus app, always-visible task/timer, focus check-ins, $10/mo or lifetime.
- [Focusmo](https://focusmo.app/pricing) - ADHD-positioned Mac menubar focus app with blocking, analytics, calendar/reminders, $39/yr or lifetime.
- [Focura](https://apps.apple.com/us/app/focura-adhd-focus-timer/id6764702091?mt=12) - Mac App Store ADHD focus timer with session naming, reflection, re-entry notes, local-first positioning.
- [Focarium](https://www.focarium.com/) - Mac/Windows work memory plus soft-nudge focus mode, app/window/domain capture, $39/yr.
- [Nudge](https://nudgefocus.app/) - Mac focus app with allowed apps, blocked sites, presets, analytics, and 10,000+ claimed installs.

**Implication:** The wedge cannot be "no one owns Mac ADHD focus." The defensible wedge must be narrower: **native Mac, low-friction task anchoring, privacy-first drift nudges, and proof that this combination converts.**

### 3. Source corrections

- Tiimo's Apple App Store Award win is real: Apple named Tiimo iPhone App of the Year 2025 ([Apple Newsroom](https://www.apple.com/newsroom/2025/12/apple-unveils-the-winners-of-the-2025-app-store-awards/)).
- Tiimo's App Store listing now claims **3M+ downloads worldwide** and includes Mac support, so framing it as only "500K users" and purely mobile-first is stale ([Tiimo App Store](https://apps.apple.com/us/app/tiimo-ai-planner-to-do/id1480220328?platform=mac)).
- Setapp single-app distribution pays **85%** developer revenue share, not 90% ([Setapp docs](https://docs.setapp.com/docs/single-app-distribution-revenue)).
- CDC adult ADHD numbers remain valid: 15.5M U.S. adults with current ADHD diagnosis, 55.9% diagnosed in adulthood ([CDC MMWR](https://www.cdc.gov/mmwr/volumes/73/wr/mm7340a1.htm), [CDC NCHS DB 543](https://www.cdc.gov/nchs/products/databriefs/db543.htm)).

### 4. Market size is real, but not decision-grade enough

The docs correctly identify a large ADHD adult market. The unsupported leap is converting that into:

- 3M reachable Mac-using ADHD adults,
- 15,000 paying users in 24 months,
- $100K MRR as a base-case target.

Those numbers should be kept as upside scenarios only. They are not proof of a venture path.

---

## Decision

### No-Go

Do **not** start the full v2 build:

- no body-doubling network,
- no coach dashboard,
- no iOS or Watch,
- no Setapp/MAS submission sprint,
- no 10-post blog launch,
- no $100K MRR operating plan,
- no claim that the lane is empty,
- no claim that code reuse is 95% until the actual code is present and builds.

### Conditional Go

Proceed only with a 2-week validation sprint described in [docs/VALIDATION_SPRINT.md](./docs/VALIDATION_SPRINT.md).

The sprint is approved if it produces one of these outcomes:

- **Demand signal:** 200 qualified waitlist signups from the target audience, or
- **Commitment signal:** 20 paid/beta commitments from late-diagnosed ADHD or ADHD-aware Mac knowledge workers, and
- **Build signal:** the actual app code exists and builds, or a greenfield prototype path is explicitly accepted.

If those gates pass, build a narrow MVP. If not, do not continue the ADHD-Mac pivot; keep the AI-builder wedge in [PIVOT_A.md](./PIVOT_A.md) alive as Pivot 2.

---

## Approved Validation Hypothesis

**Audience:** Late-diagnosed ADHD and ADHD-aware Mac knowledge workers, especially PMs, designers, engineers, founders, consultants, writers, and academics.

**Problem:** They lose work sessions at three points:

1. starting the task,
2. drifting away mid-session,
3. returning later without context.

**Product promise:** A native Mac focus anchor that keeps the current task visible and nudges the user back when drift is detected.

**Prototype scope:**

- task capture before a session,
- always-visible timer/task anchor,
- drift nudge based on active app/window heuristics,
- simple post-session note or re-entry prompt.

**Out of scope until validation passes:**

- AI voice,
- body doubling,
- coach B2B,
- iOS/Watch,
- complex paywall,
- full App Store/Setapp submission,
- broad ADHD content engine.

---

## Risk Register

| Risk | Severity | Decision impact |
|---|---:|---|
| Real app code is missing or stale | High | Forces greenfield plan; invalidates reuse estimate |
| Existing Mac ADHD competitors already cover enough of the wedge | High | Requires sharper differentiation or No-Go |
| ADHD positioning creates App Store review/privacy scrutiny | Medium | Keep launch copy productivity-first and non-medical |
| Users dislike drift monitoring | High | Validation must test privacy language and opt-in design |
| Short-form/Reddit channels underperform | Medium | Do not count them as base-case revenue channels |
| $9.99/mo is too high against $29-$99 lifetime competitors | Medium | Test paid commitment before building subscription infra |

---

## Decision History

### April 27, 2026

Broad Pomodoro positioning was correctly marked weak. Two pivots were considered: ADHD focus copilot and freelancer time-tracker.

### April 27, 2026 - Builder Pivot

[PIVOT_A.md](./PIVOT_A.md) narrowed the idea to "Cluely for shipping" for AI-native solo builders. This remains the fallback if ADHD-Mac validation fails.

### May 23, 2026

The docs committed to late-diagnosed ADHD adults on Mac and proposed a broad 6-week v2 build. That decision is now superseded.

### May 24, 2026 - Current Decision

The ADHD-Mac thesis is downgraded from committed pivot to validation hypothesis. Proceed with a 2-week validation sprint only.

---

## Supporting Docs

- [docs/VALIDATION_SPRINT.md](./docs/VALIDATION_SPRINT.md) - canonical 2-week validation plan
- [docs/PRODUCT_ROADMAP.md](./docs/PRODUCT_ROADMAP.md) - roadmap gated by validation
- [docs/GTM.md](./docs/GTM.md) - validation GTM, not a 24-month MRR plan
- [docs/ICP.md](./docs/ICP.md) - target interview audience
- [docs/JTBD.md](./docs/JTBD.md) - narrowed jobs-to-be-done
- [docs/USER_JOURNEY.md](./docs/USER_JOURNEY.md) - validation journey
- [docs/SCREENS.md](./docs/SCREENS.md) - fake-door and prototype surfaces
