# Focusly - Validation JTBD

**Date:** 24 May 2026  
**Owner:** [STRATEGY.md](../STRATEGY.md)  
**Purpose:** Narrow the jobs-to-be-done to what can be validated before a full build.

---

## Approved JTBD For Validation

### 1. Task anchoring

> "Keep the thing I meant to do visible while I work."

Validation feature:

- user enters one task before starting,
- task remains visible in a small Mac anchor,
- session can start in under 10 seconds.

This is narrower than a full task initiation coach or LLM task breakdown.

### 2. Drift recovery

> "Bring me back when I wander off."

Validation feature:

- opt-in active app/window heuristic,
- gentle nudge toast,
- no screenshots,
- no keystrokes,
- pause/disable control.

This is the highest-risk and highest-differentiation hypothesis. Interviews must test whether users trust it.

### 3. Re-entry

> "Help me know where to resume later."

Validation feature:

- one short end-session note,
- local history of recent sessions,
- no AI summary required.

---

## Deferred JTBD

These are real problems but not approved for validation build:

| JTBD | Why deferred |
|---|---|
| AI task breakdown | Existing tools like Goblin Tools and many task apps cover pieces of this; validate simple anchoring first |
| Time blindness analytics | Useful, but already served by many timers and focus apps |
| Hyperfocus protection | Could become break enforcement later; not core to first demand test |
| AI voice nudges | Adds cost, taste risk, and implementation complexity before text nudge trust is proven |
| Body doubling | Network/liquidity/safety problem; not a v1 validation feature |
| Coach reporting | B2B product, not proof of B2C demand |
| Calendar intelligence | Apple and existing tools already cover much of this lane |

---

## Interview Evidence To Capture

For each interview, capture:

- last real drift episode,
- task the user meant to do,
- app/site they drifted into,
- recovery mechanism,
- current tool used,
- privacy boundary,
- willingness to pay,
- competitor they would choose instead.

The sprint passes only if task anchoring plus drift recovery is a top-3 weekly pain for at least 70% of interviewees.
