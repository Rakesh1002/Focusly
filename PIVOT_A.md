# Pivot A — The Wedge Decision

**Author:** Rakesh Roushan · **Date:** 27 April 2026
**Builds on:** [STRATEGY.md](./STRATEGY.md)
**Question this doc answers:** *Is "AI focus copilot for ADHD knowledge workers" the right wedge, or should we pick a different one?*

---

## TL;DR — narrow the wedge

**"ADHD knowledge workers" is too broad to be a wedge.** It's a target audience description, not a wedge. Two reasons it fails as a wedge for *you specifically*:

1. **The category is venture-funded.** Inflow has raised $14.3M ([TechCrunch 2023](https://techcrunch.com/2023/01/11/inflow-a-platform-for-managing-adhd-through-cbt-raises-11m/)), Tiimo just won Apple iPhone App of the Year 2025 ([Tiimo overview](https://aiinsightsnews.net/tiimo/)), Goblin Tools is free + $1.99 mobile and viral ([Goblin Tools](https://psychelicht.com/en/goblin-tools-review-magic-todo/)). You as a solo founder fighting a CBT-credentialed venture-backed app on "best ADHD productivity app" SEO is structurally a loser.
2. **You have zero unfair distribution advantage in the ADHD creator world.** You're not Jessica McCabe. You're a solo founder in Bangalore building 30 things. Cold-starting r/ADHD + ADHD TikTok takes 6+ months minimum, and Apple's App Store reviews health/medical-positioned apps with extra scrutiny ([Dash SDK](https://blog.dashsdk.com/app-store-requirements-for-health-apps/), [Apple Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)) — meaning ADHD-positioned apps face higher rejection risk on a Mac App Store you've already been rejected from twice.

**Recommended wedge — narrower, sharper, fits you:**

> **Focusly = "Cluely, but for shipping instead of cheating."**
>
> An AI focus copilot for **AI-native solo builders** — indie hackers, AI engineers, founders, devs who use Cursor / Claude Code / Windsurf — who context-switch every 8 minutes and ship 30% of what they planned today. Always-on, screen-aware, voice-nudging, journals your sessions, integrates with your calendar.

Same product spec as the broader ADHD pivot. Sharper buyer. **You can reach this buyer.**

ADHD becomes a *content angle* — viral hooks like *"this is what 4 hours in Cursor looks like to your brain"* — not the positioning. This sidesteps Inflow / Tiimo / Goblin Tools entirely. They sell to a different buyer.

---

## Why this wedge, not the broader ADHD wedge

### The buyer (specifically)

Not "ADHD knowledge workers." That's 15M+ people across every job, geography, and income bracket. **Pick the 50,000 who:**

- Use Cursor, Claude Code, or Windsurf for 4+ hours/day ([Cursor crossed 1M DAU March 2026](https://learn.ryzlabs.com/ai-coding-assistants/cursor-vs-github-copilot-which-ai-coding-assistant-rules-them-all-in-2026); Cursor users log 65% more hours than VS Code users — strong WTP signal)
- Pay $20/mo for Cursor + $20/mo for Claude + $20/mo for v0/Lovable already
- Live on X build-in-public, HN, r/SideProject, indie hacker Discords
- Self-identify as ADHD-coded *culturally* (memes about hyperfocus + dopamine + "I have 12 tabs open") without needing a clinical label
- Mac-first (Cursor is Electron but the buyer cohort over-indexes Mac)
- Annual revenue/income $30K–$300K — they buy SaaS reflexively when it earns its keep

This buyer exists. They're your tribe. You build in this tribe.

### Your unfair advantage on this wedge

| Asset | Why it matters here |
|---|---|
| **You ARE the buyer** | Solo founder, 30 parallel ventures = textbook focus-failure target. Your dogfooding *is* the marketing story. |
| **AudioPod's audio/voice infra** | The killer feature is *voice nudging* — generated, low-latency, on-brand. AudioPod gives you ML pipelines, TTS routing, and voice-quality intuition that takes others 6 months to build. |
| **Cloudflare Agents Week 2026 fluency** | Body-doubling-lite via Durable Objects, Workflows for session→summary→tasks pipeline, Workers AI for cheap nudge text. You can ship the multi-user agent layer in days, not weeks. |
| **Build-in-public on X** | Founder-led X content grows 3x faster than silent founders ([OpenTweet](https://opentweet.io/blog/build-in-public-twitter-guide-saas-founders)). 300–800 followers by month 3 if consistent. You already operate in this loop. |
| **Bangalore + global indie hacker network** | India dev Twitter (heavy overlap with the buyer) is under-served by Western founders. Free distribution lever. |
| **Existing Focusly Swift codebase** | 80% reuse on Mac client. 4-week MVP ceiling is real. |

### What you'd give up by picking ADHD-broad instead

- **Distribution cost:** 6+ months to credibly enter ADHD creator network from a cold start, vs ~30 days to enter AI-builder network where you already exist.
- **Content authenticity risk:** "ADHD productivity tips" content from a non-clinician founder reads ick. "Here's why I broke my Cursor focus 14 times today and what fixed it" from a builder reads honest.
- **Apple risk:** ADHD-positioned apps may get pushed into Health category and face stricter review per Apple's [App Store Review Guidelines § 1.4 Physical Harm + § 5.1.1 Privacy](https://developer.apple.com/app-store/review/guidelines/). You've already been rejected twice on plain Focusly.
- **Competitive overlap:** Inflow ($14.3M raised, [CBI](https://www.cbinsights.com/company/inflow-1/financials)), Tiimo ($70/yr Apple App of the Year 2025), Goblin Tools (free + viral) — three well-funded or virally distributed apps occupying the ADHD-app head term.
- **Buyer LTV math:** ADHD app buyer LTV ~12 months on average (high churn). AI-builder buyer LTV ~24+ months (sticky tools, multi-tenant employer eventually pays).

### What you'd give up by picking the AI-builder wedge

- **TAM is smaller.** Maybe 50K reachable buyers globally with $20/mo WTP. ADHD-broad is 5–10x bigger.
- **More vulnerable to "another shipping copilot."** Cluely-clones are proliferating — search shows free open-source Cluely alternatives already on GitHub ([MindWhisperAI](https://github.com/SaimNadeemdev/MindWhisperAI-Cluely-Free-Alternative), [Natively](https://github.com/Natively-AI-assistant/natively-cluely-ai-assistant)). The category is loud and fast.
- **Content burns hotter, shorter.** X build-in-public has a half-life. ADHD content compounds longer.

**Net trade is worth it.** A wedge you can win is worth more than a market you can't reach.

---

## Phase A — the math, recomputed for the narrowed wedge

### TAM / SAM / SOM

- **TAM (paid AI-coding tool users globally):** Cursor 1M DAU + Copilot ~15M users + Windsurf, Cline, Aider, etc. Round to **20M paid AI-coding tool users**. ([RyzLabs Cursor v Copilot 2026](https://learn.ryzlabs.com/ai-coding-assistants/cursor-vs-github-copilot-which-ai-coding-assistant-rules-them-all-in-2026))
- **SAM (subset who'd pay for an *ancillary* productivity AI tool, English-speaking, Mac, $20/mo WTP):** ~10% = **2M**. Filter further to "uses 2+ productivity SaaS tools today" ~25% = **500K**.
- **SOM (reachable in 24 months by you, solo, with X + HN + niche distribution, no paid ads):** 1–2% of SAM = **5,000–10,000 paying users**.

At $19/mo × 5,300 paying = **$100K MRR**. The wedge math actually closes.

For comparison: **ADHD-broad** SOM for solo founder is harder to estimate but Inflow at $14.3M raised and aggressive paid acquisition has ~100K downloads ([CBI](https://www.cbinsights.com/company/inflow-1/financials)). You won't beat their conversion machine on cold-start.

### Pricing

| Tier | Price | What's in it |
|---|---|---|
| Free | $0 | 3 sessions/day, basic timer + tasks, no voice nudge, no body-doubling, no AI summaries |
| **Pro** | **$19/mo** or **$190/yr** | Unlimited sessions, AI voice nudges, AI session summaries, calendar awareness, full stats, journaling |
| Team (V2, post-PMF) | $39/seat/mo | Pro + shared focus rooms, admin dashboard, SSO |

Annual = 17% off vs monthly. Standard. Don't over-engineer pricing v1.

**Why $19, not $9 or $29:**
- $9 attracts churners and is below the "this is a real tool" threshold for this buyer.
- $29 is fine but the round-trip from Cursor ($20) and Claude ($20) anchors $19 as comfortable.
- Buyer has 3 productivity subs already; one more at $19/mo is below the friction line.

---

## Phase B — the v1 product spec (what you actually build)

### The 4-week MVP

Cut everything that isn't this:

1. **Menu-bar timer** — already shipped in Focusly Swift codebase. Reuse.
2. **Screen-aware drift detection** — every 5 minutes, capture active app + window title (no screenshots, no OCR, no privacy minefield). Heuristic: if active app changes from "code editor / terminal / browser-with-docs-domain" to "browser-with-twitter/youtube/reddit" for >2 min, flag drift.
3. **Voice nudge** — drift flagged → call API: Anthropic Claude Sonnet 4.6 generates a 2-sentence nudge personalized to the user's stated goal for the session. OpenAI TTS / ElevenLabs renders it. Plays through speaker (or Mac AirPods if connected). User can hit a hotkey to silence for the session.
4. **Goal capture** — at session start, "what are you working on?" — text input, single line. Used to personalize nudges and the post-session summary.
5. **Session summary** — at session end, LLM generates: *what you worked on (inferred from app/window history) + actual minutes focused vs drifted + one suggested next action.*
6. **Calendar awareness** — already shipped in Focusly. Hook into existing Calendar code: "your standup is in 7 min, want to wrap?"
7. **Stripe checkout + Clerk auth** — $19/mo Pro gate.

Cut from MVP:
- **No body-doubling.** Ship V1.
- **No iOS / Watch.** Ship V2.
- **No team features.** Ship V2 if there's pull.
- **No screenshot OCR.** Privacy story is critical for this buyer; don't blow it. Active-window heuristic is enough.

### V1 (weeks 5–10) — the differentiator drops

- **Body-doubling-lite via Cloudflare Durable Objects.** Anonymous opt-in match for the duration of one session. No video, no audio. Just a presence indicator: *"Anil in Bangalore is also locked in for the next 47 min."* Builds emotional accountability without UGC moderation overhead.
- **Smart goal continuity** — at next session start, prompt: *"Last time you said you'd ship the Stripe webhook. You drifted 22 min into Twitter. Continue?"* This is the addictive feedback loop.
- **Cursor / Claude Code / VS Code deep integration** — read the active file path + git branch. Now the nudge can say *"You've been on `auth.ts` for 3 hours, that PR is from 2 days ago — push or move on."* This is the moat.

### V2 (weeks 11–16)

- iOS companion (read-only stats, start session, silence nudges)
- Watch complication for live session timer
- Team rooms — share a focus room with your co-founder, see who's locked in

### What is the actual moat?

Not the timer. Not the AI. **The personalized continuity loop.** Every session it gets sharper because it knows your repo, your patterns, your drift triggers. Three months in, switching costs are real. That's the moat — *not* the nudge quality, which any frontier-LLM customer can clone.

---

## Phase C — distribution, day by day

### The non-negotiable cadence

| Channel | Cadence | Asset |
|---|---|---|
| **X / Twitter** | 1 thread/wk + 4 single posts/wk + 10 replies/day to peer builders | Build-log thread weekly: *"Week N of Focusly AI — what shipped, what broke, what users said"* |
| **Hacker News** | 1 Show HN at launch + 2 more (each major version) + comment helpfully on focus/productivity/AI tooling threads daily | *"Show HN: I built an AI focus copilot for the Cursor crowd"* |
| **Indie Hackers** | Weekly milestone post (revenue update from month 2 onwards) | "$0 → $X MRR — what's working" |
| **Reddit** | r/SideProject Saturday, r/IndieDev launch posts, r/ADHD as cultural-content cross-post (not promo) | Helpful comments, not drive-by promo |
| **YouTube Shorts / TikTok** | 3 shorts/wk after week 4 | "POV: you opened Cursor 4 hours ago and have 200 lines and 40 tabs" |
| **Substack / blog** | 1 long-form/2wk on focusly.unquest.ai/blog | *"Why I built a focus copilot after my 3rd 14-hour day producing nothing"* |

**Distribution daily routine (90 min/day):**
- 30 min — write/post 1 X content piece + reply to 10 builder threads
- 30 min — community presence (1 HN comment + 1 Reddit comment + 1 indie hackers comment)
- 30 min — content production for the week (one thread + one short)

**90 days of this is how you go from cold to 1,000 X followers + 100 paying users.**

### Creator partnerships — the 5 names to actually reach out to

Don't cold-DM Pieter Levels. Earn into his radius. The realistic 5:

1. **Marc Lou** ([@marc_louvion](https://twitter.com/marc_louvion)) — runs a builder community, reviews indie tools. Trade: free lifetime + 30% recurring affiliate.
2. **Theo (t3.gg)** — opinionated AI/dev YouTuber. Will roast bad tools, will hype good ones. Risk/reward.
3. **Kris Krug / similar mid-tier solo SaaS builders on X** with 5–30K followers — 5–8 of them. Lifetime Pro for an honest tweet thread.
4. **Indie Hackers podcast / Build in Public podcast / Lenny's** — long shot but a real podcast credit compounds for 12 months.
5. **One Cursor / Windsurf community partner** — early-access to their power users via newsletter swap. 

**Don't do paid ads.** AI/dev/productivity CPMs on Meta and X are >$50, CACs 4-6x sustainable.

---

## Phase D — should we pick a different wedge entirely?

I genuinely considered four alternatives. Here's the honest scoring:

| Wedge | TAM | Your distribution access | WTP | Differentiation defensibility | App Store risk | Verdict |
|---|---|---|---|---|---|---|
| **AI focus copilot for builders** (recommended) | Medium (50K reachable) | **High** (your tribe) | High ($19/mo) | Medium (Cluely-class threat) | Low | **PICK** |
| ADHD knowledge workers (broad) | High | Low (ADHD creators are gatekept) | Medium ($10/mo anchor) | Low (Inflow + Tiimo + Goblin Tools own head) | High (medical scrutiny) | Pass |
| Students / exam prep | Very high | Very low | Very low (free expectation) | Low (Forest, Pomofocus dominate) | Low | Pass |
| Freelancer time-tracker + invoicing (Pivot B from STRATEGY.md) | Medium | Medium (India fintech network) | High ($19/mo) | Medium (Rize, Timing, Toggl) | Low | **Strong runner-up** |
| AuDHD / neurodivergent professionals niche | Small (high engagement) | Medium (smaller creator pool) | High ($25/mo for niche) | High (specialist) | Medium | Worth keeping in pocket as Pivot A.2 |

**The real choice is between Wedge 1 (builders) and Wedge 4 (freelancer time-tracker).** Both have closing math, both have your unfair advantages.

**Why pick builders over freelancer time-tracker:**
- Your tribe today vs your tribe in theory. You don't run a freelancer-services business; you build products. Your X audience is builders, not freelancers.
- Voice nudging + AI co-pilot framing matches AudioPod's tech stack better than invoicing/billing.
- The freelancer time-tracker is a *market opportunity* (real); the builder focus-copilot is a *founder/product fit* opportunity.
- Founder-product fit beats market opportunity at this stage. Solo founders ship what they personally need — twice as fast and twice as well.

**When to switch to the freelancer wedge:** if 60 days into Pivot A you have <100 waitlist signups and Indian dev Twitter isn't picking it up, the audience-product fit is wrong. Then you rotate the codebase to Pivot B (freelancer time tracker + invoicing) — same Calendar + Tasks + Stats infra applies.

---

## Phase E — what would make this a "no, kill" decision

This isn't permanent. Re-evaluate at these checkpoints:

### Day 30 — alpha checkpoint
**Kill if:**
- MVP doesn't actually run end-to-end on your own machine for 5 consecutive workdays. (Solo dogfood test — if *you* can't use it, no one will.)
- < 50 waitlist signups despite 30 days of daily X content.
- Closed-alpha users (5 friends) say "it's annoying" or "I muted the nudge after day 2." Fundamental UX is wrong.

### Day 60 — pricing/conversion checkpoint
**Kill if:**
- < 5 paying customers despite waitlist of 200+.
- Trial-to-paid conversion < 8%. (Industry average for this category is 12–18%; you should be above.)
- Cluely or a copycat ships a "focus mode" feature in the same window. The window can close fast.

### Day 90 — go/no-go on $5K MRR
**Kill if:**
- < $5K MRR.
- < 250 active weekly users.
- Content engine producing < 5K total content views/week (means audience isn't compounding).
- You personally aren't using the product 4+ days a week (founder-product fit broke).

**Pivot if killed:**
- First fallback: Pivot A.2 — narrow further to "AuDHD knowledge workers in tech" (the niche-and-deep version).
- Second fallback: Pivot B from STRATEGY.md — freelancer time-tracker + invoicing.
- Third fallback: harvest the codebase as $5–10K/yr cashflow asset and redirect attention.

### The single assumption that, if wrong, kills everything

> **AI-builder solo founders / indie hackers will pay $19/mo for an always-on AI focus copilot when they already pay $20/mo for Cursor and have built-in macOS Focus modes for free.**

If that's wrong, the whole wedge is wrong. You'll know in 60 days, not 90.

---

## Phase F — the 14-day sprint plan

Concrete deliverables. Each item has an output.

### Week 1 (ending May 4)

- **Mon–Tue:** Branch the Focusly Swift codebase to `focusly-ai`. Strip out: cycle tracking, multi-screen, achievement system, break activities. Keep: timer, tasks, calendar integration, stats, journaling. **Output: trimmed Mac app builds and runs.**
- **Wed:** Stand up Cloudflare Workers + Hono backend with three endpoints: `POST /sessions/start`, `POST /sessions/drift`, `POST /sessions/end`. Clerk auth. D1 schema for users + sessions. **Output: backend deployed, accepting authenticated requests.**
- **Thu:** Wire active-app detection in Swift (NSWorkspace) → POST drift events to backend every 5 min. **Output: drift events logged in D1.**
- **Fri:** Anthropic Claude Sonnet 4.6 + OpenAI TTS pipeline in a Worker. POST drift event → return audio URL. **Output: voice nudge MP3 returned in <2s.**
- **Sat:** focusly.unquest.ai → swap hero to *"Cluely, but for shipping. AI focus copilot for builders. Coming soon."* + waitlist email capture (Resend or Loops). **Output: live waitlist page.**
- **Sun:** First X build-in-public thread: *"I'm pivoting Focusly. Here's why ADHD-broad is wrong and what I'm building instead."* Cross-post to Indie Hackers. **Output: thread shipped, baseline follower count recorded.**

### Week 2 (ending May 11)

- **Mon–Tue:** Mac app integrates voice nudge: drift → API call → play MP3. Goal capture at session start. Mute hotkey. **Output: end-to-end nudge working on your machine.**
- **Wed:** Session summary endpoint — at session end, LLM summarizes from drift events + goal text. **Output: summary visible in Mac app post-session.**
- **Thu:** Stripe checkout for Pro $19/mo via a hosted page. Lock voice-nudge feature behind paid flag. **Output: someone you don't know personally can pay $19/mo and get nudges.**
- **Fri:** First 5 alpha users invited (warm network). Onboarding deck (3-screen Loom). **Output: 5 active alpha installs.**
- **Sat:** Show HN draft + 3 X content pieces queued for next week. **Output: HN post draft + content backlog.**
- **Sun:** Weekly retro post on X. Numbers public. **Output: thread shipped.**

### Day 14 deliverable

- Mac app with voice nudge end-to-end
- Backend deployed on Cloudflare Workers + D1
- Stripe + Clerk gating Pro
- 5 alpha users actively in flow
- Public waitlist with > 50 signups
- 2 X threads shipped, baseline audience growth visible

### Day 30 (post-sprint) target

- 1 paying customer who isn't a friend
- 200+ waitlist signups
- 4 weeks of consistent X build-in-public output
- Show HN published

---

## What I'd be wrong about (and want you to push back on)

1. **The framing.** "Cluely for shipping, not cheating" is a useful hook but Cluely's reputation is mixed — some of your buyer cohort will read it as a negative reference. Alt framing: *"The AI accountability copilot for solo founders."* Pick the one that resonates with your actual X voice.
2. **Voice nudges might be too invasive.** Some users will hate audio. Mitigation: ship a silent-mode (text-banner-only) variant on day 1; voice is opt-in. But voice is the differentiator — most builders try it, hate the bad ones, love the good ones. The bet is your ear (AudioPod) gets the nudge tone right.
3. **Active-app heuristic might miss too many drift signals** (e.g., looking at code in Cursor *is* drift if you're avoiding the actual hard task). Mitigation: V1 adds a manual "I'm stuck" button that explicitly invites a nudge. By V2, you have screenshot OCR opt-in for power users who want deeper detection.
4. **Cursor or Claude Code could ship a "focus mode" in their app and eat the wedge.** Real risk. Probability ~15% in the next 12 months. Mitigation: become the *cross-tool* layer — work whether the user's in Cursor, Xcode, Notion, or Figma. That's not Cursor's roadmap.
5. **The ADHD content angle could feel exploitative if not handled with care.** The line: *make ADHD-flavored content because it's culturally true for the audience, but never claim therapeutic benefit, never use medical terminology, never imply the app treats anything.* Your X content should sound like a builder talking to builders, not a wellness brand.

---

## Decision asked of you, today

Pick one of three, this week:

- **(A) Ship the narrowed wedge above.** Builder-positioned. 14-day sprint. $5K MRR by Day 90 or kill.
- **(B) Stay broader (ADHD knowledge workers).** Higher TAM, harder distribution, App Store risk. I think this is the wrong call but if you have ADHD-creator relationships I don't know about, it's defensible.
- **(C) Switch to Pivot B (freelancer time-tracker + invoicing).** If your real edge is Indian dev / freelancer audience and you don't want to fight Cluely-class category noise, this is sharper.

If you don't decide by end of this week, default to (A) and start the 14-day sprint. The cost of a wrong wedge is 90 days; the cost of indecision is everything.

---

## Sources

- [Inflow $11M Series A (TechCrunch 2023)](https://techcrunch.com/2023/01/11/inflow-a-platform-for-managing-adhd-through-cbt-raises-11m/)
- [Inflow $2.3M Seed (TechCrunch 2022)](https://techcrunch.com/2022/01/17/inflow-a-science-based-app-for-adhd-raises-2-3m-seed-led-by-hoxton-ventures/)
- [Inflow CB Insights financials](https://www.cbinsights.com/company/inflow-1/financials)
- [Tiimo Apple App of the Year 2025 review](https://aiinsightsnews.net/tiimo/)
- [Goblin Tools review](https://psychelicht.com/en/goblin-tools-review-magic-todo/)
- [Cluely Wikipedia](https://en.wikipedia.org/wiki/Cluely)
- [Cluely Tracxn profile (funding)](https://tracxn.com/d/companies/cluely/__Ju-PhvKyO8Kv2MD9Esgxhmh_EB15mxqSDhhJ2zxBqN0)
- [Cluely PitchBook profile](https://pitchbook.com/profiles/company/802998-10)
- [Cursor v Copilot v Windsurf 2026 (RyzLabs)](https://learn.ryzlabs.com/ai-coding-assistants/cursor-vs-github-copilot-which-ai-coding-assistant-rules-them-all-in-2026)
- [Cursor 3 launch April 2026](https://devtoolpicks.com/blog/cursor-3-agents-window-review-2026)
- [Apple App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Apple App Store Health App Requirements (Dash SDK)](https://blog.dashsdk.com/app-store-requirements-for-health-apps/)
- [Build in Public on X — solo founder guide (OpenTweet)](https://opentweet.io/blog/build-in-public-twitter-guide-saas-founders)
- [How to Grow on X 2026 (Social Rails)](https://socialrails.com/blog/how-to-grow-on-twitter-x-complete-guide)
- [Solo Founder's Guide to Launching SaaS 2026 (Two Cents Software)](https://www.twocents.software/blog/solo-founders-guide-to-launching-saas/)
- [MindWhisperAI free Cluely alternative (GitHub)](https://github.com/SaimNadeemdev/MindWhisperAI-Cluely-Free-Alternative)
- [Natively open-source Cluely alternative (GitHub)](https://github.com/Natively-AI-assistant/natively-cluely-ai-assistant)
