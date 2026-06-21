# Focusly - 2-Week Validation Sprint

**Date:** 24 May 2026  
**Owner:** [STRATEGY.md](../STRATEGY.md)  
**Decision:** Conditional Go only if validation gates pass

---

## Goal

Decide whether Focusly should become a **native Mac focus anchor with drift-aware nudges for ADHD-aware knowledge workers**.

This sprint validates demand, trust, differentiation, and implementation reality before any full v2 build.

---

## Success Gates

Proceed to a narrow MVP only if all three gates are resolved:

| Gate | Pass condition | Fail condition |
|---|---|---|
| Codebase reality | Real app code is located, imported, and builds; or greenfield is explicitly accepted | Code remains missing/stale and no greenfield decision is made |
| Customer demand | 200 qualified waitlist signups or 20 paid/beta commitments | Low-intent traffic, generic signups, or fewer than 20 committed users |
| Problem specificity | Interviews confirm task anchoring + drift nudges are painful and trusted enough | Users prefer existing tools, reject monitoring, or do not see this as urgent |

If the sprint fails, do not build the ADHD-Mac pivot. Keep the AI-builder wedge in [../PIVOT_A.md](../PIVOT_A.md) as Pivot 2.

---

## Hypothesis

Late-diagnosed ADHD and ADHD-aware Mac knowledge workers will commit to a lightweight Mac app that:

- captures the task before a session,
- keeps the task/timer visible while they work,
- detects obvious drift using active app/window heuristics,
- nudges them back without blocking or shaming,
- preserves a short re-entry note for later.

The validation positioning is:

> **Native Mac focus anchor with drift-aware nudges.**

Avoid broader claims such as "ADHD copilot," "treatment," "coaching," "clinically validated," or "body doubling network."

---

## Week 1

### Day 1 - Codebase verification

- Confirm whether the real `Focusly_app/` and `focusly_web/` source code exists outside this workspace.
- If it exists, import or link it and run the smallest build/test command.
- If it does not exist, document Focusly as greenfield and remove all code-reuse estimates from planning.
- Output: a short codebase status note with build result, missing dependencies, and the realistic starting point.

### Day 2 - Competitive reset

Audit the real competitive set:

- Focana
- Focusmo
- Focura
- Focarium
- Nudge
- Tiimo
- Focus Bear
- Focusmate
- Llama Life

Output: one table with product, platform, pricing, key feature overlap, and the specific gap Focusly might still exploit.

### Day 3 - Fake-door landing page spec

Create copy and wireframe for a single validation landing page:

- headline: "A Mac focus anchor that nudges you back when you drift"
- audience line: "For ADHD-aware knowledge workers who lose the thread mid-session"
- three feature blocks: task anchor, drift-aware nudge, re-entry note
- privacy block: "No screenshots. No keystrokes. Active app/window only. Opt-in."
- CTA A: "Join the beta"
- CTA B: "Reserve early access" with an optional refundable paid intent path

Do not build a full marketing site, blog, pricing page, coach page, or App Store assets.

### Days 4-5 - Interview recruiting

Recruit 10 target users:

- 7 late-diagnosed ADHD or ADHD-aware Mac knowledge workers,
- 2 founder/operator types who self-identify with ADHD-coded drift,
- 1 ADHD coach only as an advisor, not as a buyer validation proxy.

Screen for:

- Mac as primary work device,
- knowledge work 20+ hours/week,
- recent pain with task initiation, drift, or re-entry,
- current or past use of focus/productivity tools.

---

## Week 2

### Days 6-8 - Interviews

Use the same interview script for all users:

1. Walk me through the last time you lost a work session.
2. What were you trying to do before you drifted?
3. What did you use to recover?
4. What tools have you tried and stopped using?
5. Would an always-visible Mac task anchor help or annoy you?
6. Would active app/window drift detection feel acceptable if opt-in?
7. What exact data would you refuse to share?
8. Would you pay for this? If yes, monthly, annual, or lifetime?
9. Which competitor would you choose instead?
10. What would make you uninstall in the first day?

Record exact objections and willingness-to-pay language.

### Days 9-10 - Prototype decision

Build only if the codebase gate is clear.

Prototype options:

- **If existing app code builds:** implement or mock task capture, visible timer/task anchor, and drift toast.
- **If greenfield:** create a minimal native Mac prototype or high-fidelity clickable demo. Do not build billing, AI voice, body doubling, coach features, iOS, Watch, or full analytics.

Prototype acceptance:

- starts a session in under 10 seconds,
- keeps task visible,
- can trigger a manual or heuristic "drift" nudge,
- captures one re-entry note at the end.

### Days 11-12 - Fake-door traffic

Drive traffic from low-cost, high-intent channels:

- 10 personal outreach messages to qualified Mac ADHD users,
- 3 founder posts on X/LinkedIn,
- 3 thoughtful Reddit comments where allowed,
- 1 demo clip posted to a relevant non-spam channel,
- direct outreach to 3 micro-creators for feedback, not promotion.

Do not depend on r/ADHD promotional posting during validation.

### Days 13-14 - Decision review

Score the sprint:

| Metric | Go threshold |
|---|---:|
| Qualified waitlist signups | 200 |
| Paid/beta commitments | 20 |
| Completed interviews | 10 |
| Users accepting drift detection | 70% of interviewees |
| Users naming this as top-3 weekly pain | 70% of interviewees |
| Users preferring Focusly concept over direct competitors | 50% of interviewees |

Decision:

- **Go:** Build narrow MVP only.
- **Iterate:** Revise positioning and run one more 2-week validation cycle.
- **No-Go:** Stop ADHD-Mac and move to Pivot 2.

---

## Narrow MVP If Gates Pass

Only these features are approved:

- native Mac task capture,
- always-visible task/timer anchor,
- drift-aware nudge based on active app/window rules,
- privacy-first permissions and controls,
- simple session re-entry note,
- basic local history.

Still deferred:

- AI voice,
- body doubling,
- coach dashboard,
- iOS and Watch,
- Setapp/MAS submission,
- SEO content engine,
- creator affiliate program,
- complex subscriptions.

---
**Owner:** Rakesh Roushan · **Last reviewed:** 2026-06-21 · **Review by:** 2026-09-21
