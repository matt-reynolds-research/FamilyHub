# External Review Request — FamilyHub Planning Package (pre-build)

> **How to use this:** paste this entire document into GPT and into Gemini as *separate*
> conversations. Both get the identical packet, so their reads are comparable. The four planning
> documents are included in full at the bottom — nothing is withheld.

## Your task

You are an independent senior reviewer — part software architect, part product lead — giving a
candid second opinion on a **pre-build planning package** for a personal software project. I want a
**fair, honest critique, not encouragement.** The author has thick skin and would much rather hear
the hard truths now, before any code exists, than discover them later. Surface weaknesses, risks,
and blind spots at least as directly as strengths. If something is genuinely sound, say so plainly
and briefly — don't pad. If something is wrong, confused, or over/under-engineered, say so clearly
and explain why.

Do **not** assume the plan is good simply because it is detailed or written confidently. Detail is
not correctness. Push on it.

## Context you must evaluate against (this sets the bar — read before judging)

This is a **hobby project**, not a product:

- A Flutter iPad "home hub" (Google Nest Hub-style wall display) for **one family's own use**. Not
  public, not commercial, no users beyond the household.
- The author's stated goals, verbatim in spirit: **experimental over practical** (novelty and
  "let's see if this works" are valid ends in themselves); **a way to stay sharp on current
  AI-assisted development** (prefer real, modern tools and patterns); **but still high-fidelity**
  (experimental ≠ sloppy).
- The author is a **senior UX researcher deliberately learning the engineering craft** — very
  comfortable with AI tools, still green on deep-stack engineering. Evaluate whether the plan is
  *sound, coherent, and a good learning vehicle* — not whether it matches what a staff engineer at
  a large company would ship.
- Working style: **incremental** — plan one phase ahead, build in vertical slices, smallest safe
  reviewable steps, one pull request per change, **mock/seeded data only** (never real family
  data), and "fail loud" during development.

Judge it on its own terms. Do **not** ding it for not being enterprise-scale, multi-user, or
cloud-native — those are explicit non-goals. Equally, do **not** excuse genuine design flaws just
because it's a hobby project.

## What I want you to assess

Work through these, citing the specific document and section where relevant:

1. **Sequencing & scope.** Is the phase/dependency order sound? Is "one phase ahead + vertical
   slices" the right amount of planning here, or is it over- or under-planned? Any ordering that
   will cause pain later?
2. **The design-system seed.** Are the token set, type scale, tile grid, and single reusable-tile
   abstraction reasonable and *complete enough* for a v1 shell? What's missing that will bite
   during the first real build?
3. **The two-mode surface (ambient ⇄ engaged).** Is treating the hub as two swapping layouts sound?
   What are the real risks in the mode-switch architecture, the voice trigger/return model, and
   pushing the voice pieces to the last phase?
4. **The data-layer contract.** JSON mock → typed model → (later) markdown adapter. Is that the
   right abstraction, or premature/insufficient? Does anchoring the mock model to existing markdown
   files help them or trap them?
5. **Unstated assumptions & blind spots.** What is the plan quietly assuming that may not hold?
   (e.g., Flutter as the framework choice, iPad kiosk / always-on realities, on-device vs. cloud
   for the assistant, screen burn-in, the existing backend "world" it plans to mirror.)
6. **The single biggest risk**, and the **one thing you'd change** before any code is written.

## Output format

- **Verdict (2–3 sentences):** is this plan sound to start building from, with caveats?
- **Top strengths** (max 3, brief).
- **Top concerns (ranked):** each with *what*, *why it matters*, *a suggested fix*, and the section
  it applies to.
- **Blind spots / unstated assumptions.**
- **Specific corrections** — any factual or technical errors you spotted.
- Favor the specific and concrete over the general: "Section X assumes Y, which breaks when Z" beats
  "consider thinking about edge cases."

## Fairness note

This exact package is being shown to more than one AI model for independent comparison. Give your
own honest read; don't try to guess or match what another reviewer might say.

---
---

# THE PLANNING PACKAGE

Four documents follow, unedited and in full.


===================================================================
DOCUMENT 1 of 4 — PROJECT_MAP.md
===================================================================

# FamilyHub — PROJECT_MAP.md

> **The north star.** This file is the single source of truth for *what FamilyHub is,
> what exists vs. what's still a placeholder, and the order we build in.* If reality and
> this file disagree, one of them is wrong — fix it in the same step. Everything else
> (PRDs, design system, code) hangs off this.

_Last updated: 2026-08-02 · Status: **Phase 0 — planning (design-system seed v1.0 + Home Hub PRD locked)**_

---

## 1. Vision (the one sentence)

**A primarily headless AI assistant I can hang on the wall and talk to to run my home** —
an always-on iPad "home hub" for the Reynolds household where the conversation *is* the
product and the screen is the ambient, glanceable backup.

The mental model isn't "an app with a chatbot in it." It's **an assistant with a face**.
Voice/conversation is the front door; the tiles (tasks, shopping, mail) are what the
assistant shows you when you glance over, and what you can poke with a finger when talking
isn't convenient.

## 2. What this project is (and isn't)

Carried over from the project instructions so the map stands on its own:

- **Experimental over practical.** It doesn't have to be useful. Novelty and "let's see if
  this works" are valid goals. When a choice is low-stakes, take the more interesting path.
- **A way to stay sharp on AI development.** Prefer current, real-world tools and patterns.
  Notable technical decisions get a short written *what & why* so the pipeline keeps teaching.
- **Still high fidelity.** Experimental ≠ sloppy. Clean, quality work inside the experiment.
- **Not a public product.** Family MVP / playground. Favor simple working solutions over
  enterprise complexity. Never build against real family data or live accounts — **seed/mock
  data only** during development.

## 3. How FamilyHub relates to the assistant we already run

This matters, because we are **not** starting from zero on the *backend*. The household
already has a working assistant (see the Cowork project `README.md`):

- **Data lives as markdown** — `TASKS.md` and `SHOPPING.md` are the current source of truth,
  with defined sections and states.
- **Input channels already exist** — Cowork, email commands (`ADD:`, `GROCERY:`, `SHOP:`…),
  and iMessage (`@claude …`, voice memos), all landing in the household inbox.
- **Automations already run** — 6:30 AM Morning Briefing, 10 PM calendar sweep, an email-in
  task handler, a mail watcher.

**So FamilyHub is a new *surface* over an existing *world*, not a new system.** Its domain
models should mirror the conventions those files already use (same sections, same states,
same command vocabulary) so the wall display and the text/email assistant stay in sync.

> **Build-time rule:** FamilyHub develops against **seeded mock data shaped like** those
> files — not the live files. Wiring the hub to the real household backend is a deliberate,
> later phase (see Roadmap Phase 5 and Open Decisions), not something we do casually.

**The backend world evolves on its own track.** Work that changes the *world* rather than the
*surface* is scoped outside this map and doesn't enter the PRD order in §7 — e.g. automated
calendar maintenance ([`../docs/calendar-maintenance-scoping.md`](../docs/calendar-maintenance-scoping.md),
draft). FamilyHub consumes whatever that world produces; it isn't blocked by it.

## 4. The five features — and their *roles*

The features aren't five peers. They play three different structural roles, and that's what
determines build order:

| # | Feature | Role | Plain-English job |
|---|---------|------|-------------------|
| 5 | **Home Hub** | **Foundation (the shell)** | The always-on frame: the grid, the ambient/wall idle state, navigation, and the data layer everything else renders into. |
| 1 | **AI Conversational Assistant Bar** | **Spine (primary interaction)** | The persistent way you talk to the hub. Depends on the shell existing and on having at least one domain to act on. Grows one domain at a time. |
| 2 | **Tasks / Todo** | Data domain | Read + touch surface over the household to-do list (mirrors `TASKS.md`). |
| 3 | **Shopping (Grocery + Household)** | Data domain | Read + touch surface over the shopping lists (mirrors `SHOPPING.md`). |
| 4 | **Mail & Packages** | Data domain (integration-heavy) | Glanceable view of household mail + package/delivery status. Most external-integration risk; likely read-mostly first. |

**Why this framing:** you can't design a "system" for domains you haven't defined, and the
assistant has nothing to talk about until at least one domain exists. So the shell and one
real domain come first; the assistant proves itself against that domain; then the rest fan out.

## 5. Roadmap — dependency order, not excitement order

Build in the order things *stand on each other*, and always ship one complete vertical slice
before going wide. Each phase should be the smallest safe, reviewable piece.

- **Phase 0 — Foundation & guardrails** *(placeholder)*
  Flutter iPad project scaffold, `PROJECT_MAP.md` (this file) + `AGENTS.md` kept in sync,
  the **design-system seed** (tokens: color, type scale, spacing, the tile grid + 2–3
  primitives — *not* a full component library), a mock/seeded data layer, and the empty
  Home Hub shell (grid + ambient idle state + navigation). Fail-loud on missing data.

- **Phase 1 — First vertical slice: Shopping** *(placeholder)*
  Pick the simplest domain and build it end-to-end as a real tile: read seeded data, render,
  add/check/clear, respect the `SHOPPING.md` sections + "Recently Bought" behavior. This
  validates the whole pipeline (data → design system → tile → interaction). *Tasks is an
  equally valid slice; Shopping chosen for being the most constrained CRUD.*

- **Phase 2 — Assistant Bar v1 (wired to Shopping)** *(placeholder)*
  The persistent bar, controlling exactly one domain: "add milk," "what's on the list,"
  "we got the eggs." Proves the headless/conversational loop against real state before we
  scale it. Text first; voice is later polish.

- **Phase 3 — Tasks / Todo domain** *(placeholder)*
  Second domain tile + assistant integration. Reuses Phase 1–2 patterns; confirms the shell
  and assistant generalize beyond one domain ("test the opposite too").

- **Phase 4 — Mail & Packages** *(placeholder)*
  The integration-heavy domain. Start read-mostly (glanceable status). External accounts are
  a security/privacy decision point — pause and confirm before wiring anything live.

- **Phase 5 — Ambient / wall mode + live backend** *(placeholder)*
  The "hang it on the wall" polish: always-on glanceable idle states, voice input, and the
  deliberate decision about connecting to the real household backend vs. staying on seeded data.

## 6. Feature inventory — built vs. placeholder

Everything is a placeholder today; this table is what we'll keep honest as we go.

| Feature | Status | Notes |
|---------|--------|-------|
| Home Hub (shell) | 📄 PRD locked | Phase 0 — [`prds/01-home-hub-prd.md`](prds/01-home-hub-prd.md). Two-mode surface (ambient ⇄ engaged); engaged stubbed. Not yet built. |
| Design-system seed | ✅ v1.0 locked | Phase 0 — [`design/design-system-seed.md`](design/design-system-seed.md); tokens + tile grid + reusable tile. 5 taste calls resolved. Target device: iPad 10th gen. |
| Shopping tile | ⬜ Placeholder | Phase 1 — first vertical slice |
| Assistant Bar | ⬜ Placeholder | Phase 2 (v1, Shopping only) → grows each phase |
| Tasks / Todo tile | ⬜ Placeholder | Phase 3 |
| Mail & Packages tile | ⬜ Placeholder | Phase 4 |
| Ambient/wall mode | ⬜ Placeholder | Phase 5 |
| Live backend wiring | ⬜ Placeholder | Phase 5 — needs an explicit go |

## 7. PRD writing order

PRDs get written **one phase ahead of the build**, in the same dependency order — not all at
once up front (you'd guess wrong on half of them). Recommended sequence:

1. **Home Hub** (the shell) — defines the frame, grid, ambient states, and the data-layer
   contract every other feature depends on. Write this first. → **✅ Locked:
   [`prds/01-home-hub-prd.md`](prds/01-home-hub-prd.md).**
2. **Shopping** — the first vertical slice; forces the data model + component decisions.
3. **Assistant Bar** — written after Shopping so it has a concrete domain to specify against.
4. **Tasks / Todo** — mostly mirrors Shopping; fast to write once patterns exist.
5. **Mail & Packages** — last; most external unknowns, best specified once the shell is proven.

The **design-system seed comes before PRD #2**: a minimal token set exists first so every
PRD and every Claude Design output speaks the same visual vocabulary. The system then *grows*
as each PRD surfaces a component it needs — evidence-driven, not speculative.

## 8. Tech stack — authority

The **authority on stack + versions is `pubspec.yaml` / `pubspec.lock`** once the project is
scaffolded (Phase 0). Trust those over any prose here. Intended direction: **Flutter, iPad
target, headless/ambient-first.** Nothing is pinned until Phase 0 creates the project.

## 9. Open decisions — need Matt before/at these points

Not blocking the map, but flag-and-confirm before the relevant phase:

1. **Repo location for the Flutter app.** This planning doc lives in the Cowork folder so you
   can see it. The actual FamilyHub *code* repo isn't created yet — where should it live, and
   is it a fresh git repo? *(Blocks Phase 0 scaffold.)*
2. **First vertical slice: Shopping vs. Tasks.** Map assumes Shopping. Easy to flip. *(Blocks Phase 1.)*
3. **Live backend, eventually.** Do we want FamilyHub to eventually read/write the real
   `TASKS.md`/`SHOPPING.md` + calendar, or stay a standalone seeded demo? Shapes the data
   layer's design even though wiring is Phase 5. *(Informs Phase 0, decided by Phase 5.)*
4. **Assistant Bar brains.** On-device vs. calling out to a model, and which — a cost +
   privacy decision. *(Blocks Phase 2. Anything that spends money pauses for you.)*

## 10. How to keep this file alive

- Update the **status table (§6)** and the **phase markers (§5)** in the *same commit* as the
  change they describe.
- Log notable technical decisions with a one-line *what & why* (mirror into `AGENTS.md`).
- Work the phases in order unless Matt says otherwise.
- Commit early after any working change or new doc, so we can always roll back.


===================================================================
DOCUMENT 2 of 4 — design-system-seed.md
===================================================================

# FamilyHub — Design-System Seed (v0)

_Companion to [PRD 01 — Home Hub](../prds/01-home-hub-prd.md) and its
[Claude Design brief](claude-design-brief--home-hub.md). Status: **v1.0 locked** — all 5 taste
calls resolved (see §8). Last updated 2026-08-01._

> **What this is.** The *seed*, not a component library. It's the small set of foundational
> decisions — color, type, spacing, radii, the tile grid, and one reusable tile — that
> everything else composes from. It exists *before* the Shopping PRD so every PRD and every
> Claude Design output speaks the same visual language.
>
> **How it grows.** Evidence-driven. We add a token or component only when a real screen needs
> it — we don't invent 200 tokens up front and guess wrong. This file is harvested from real UI
> as we build, not designed in a vacuum. (See PROJECT_MAP §7.)
>
> **Where it came from.** The raw values below started from the loose starter tokens in the
> design brief ("from an early sketch"). This seed cleans them up, names them, and fills the gaps.
> The five taste calls that were genuinely Matt's to make are now resolved and logged in §8.

---

## 0. The constraint that drives everything

Before any token: **FamilyHub is read from 6–10 feet away, on a wall, often in a dim room.**
That single fact is *why* the type is large, the contrast is high, and the theme is dark. Every
number below traces back to it. When in doubt, optimize for "legible across the room," not
"looks tidy on my laptop 18 inches away."

Secondary constraint: **iPad 10th generation, landscape** — logical canvas **1180×820 points**
(2360×1640 px at 264 ppi, 2× scale). All spacing/grid math assumes this canvas; the earlier
placeholder was already correct for this device. Target glance distance: **~8 ft nominal**
(design for the farthest common glance) until the wall spot is measured — see §7.

---

## 1. Naming convention

Tokens are named **semantically** (by *role*), not by raw value — `color.text.primary`, not
`color.grey200`. Semantic names mean we can retune the palette later without renaming everything
downstream. Raw values live in one place (the "raw palette"); semantic tokens point at them.

```
raw palette      →   semantic token        →   used by
#E7E9EE          →   color.text.primary    →   tile numbers, clock, headlines
```

When we scaffold Flutter, these become a single `tokens.dart` (a set of `const` values) that
feeds `ThemeData`. Naming them now means the Dart file is a mechanical translation later, not a
new round of decisions.

---

## 2. Color

### 2a. Raw palette (dark theme)

| Raw name        | Hex       | Swatch note                    |
|-----------------|-----------|--------------------------------|
| `ink.900`       | `#0D0F12` | near-black, the page           |
| `ink.800`       | `#15181D` | one step up — tile surface     |
| `ink.700`       | `#1E2229` | focused / raised surface       |
| `line.600`      | `#333842` | hairlines / dividers           |
| `text.100`      | `#E7E9EE` | primary text                   |
| `text.300`      | `#9AA0AB` | secondary text                 |
| `text.500`      | `#6F757F` | muted / hint                   |
| `teal.400`      | `#5DCAA5` | Shopping accent                |
| `blue.400`      | `#7F9FF0` | Tasks accent                   |
| `amber.400`     | `#EFB45A` | Mail & Packages accent         |
| `red.400`       | `#E5726B` | status: error / no-data        |
| `green.400`     | `#7FC98A` | status: success                |

### 2b. Semantic tokens (what the UI actually references)

| Token                  | → raw        | Job                                             |
|------------------------|--------------|-------------------------------------------------|
| `color.bg.page`        | `ink.900`    | the whole screen background                     |
| `color.bg.tile`        | `ink.800`    | default tile surface                            |
| `color.bg.raised`      | `ink.700`    | focused tile / assistant bar                    |
| `color.line`           | `line.600`   | dividers, tile hairline borders                 |
| `color.text.primary`   | `text.100`   | numbers, clock, headlines                       |
| `color.text.secondary` | `text.300`   | supporting labels, one-line detail              |
| `color.text.muted`     | `text.500`   | hints, placeholder, empty-state copy            |
| `color.accent.shopping`| `teal.400`   | Shopping icon + its one key number              |
| `color.accent.tasks`   | `blue.400`   | Tasks icon + its one key number                 |
| `color.accent.mail`    | `amber.400`  | Mail icon + its one key number                  |
| `color.status.error`   | `red.400`    | fail-loud error / no-data tile state            |
| `color.status.success` | `green.400`  | assistant confirmations ("Added milk")          |

**Accent rule:** one accent per tile, used only for *meaning* (which domain / a status), never
decoration. The bulk of every screen is ink + text tokens; color is the exception that carries
information.

**✅ Decision 1 — status colors (resolved).** Added `color.status.error` (`#E5726B`, muted
coral-red — visible for fail-loud, not screaming) and `color.status.success` (`#7FC98A`, kept
warmer/leafier so it stays clearly distinct from Shopping's teal). No dedicated **warning** color:
amber is already Mail's accent, so we don't overload it until something genuinely needs a warning.

---

## 3. Type scale

Two weights only — **400 regular, 500 medium**. Sentence case everywhere; no all-caps except a
subtle wordmark. Sizes are tuned for distance, so the scale is "top-heavy" (big hero, then a
quick drop to small) rather than a gentle even ramp.

| Token              | Size / weight   | Used for                                   |
|--------------------|-----------------|--------------------------------------------|
| `type.hero`        | 52 / 500        | clock, any single hero number              |
| `type.number`      | 30 / 500        | a tile's key summary number ("1 to buy")   |
| `type.body`        | 16 / 400        | list items in a focused tile               |
| `type.label`       | 14 / 500        | tile titles ("Shopping"), section labels   |
| `type.caption`     | 13 / 400        | timestamps, up-close secondary detail      |

Notes for later: `type.hero` at 52px sits high in the brief's range (48–56). `type.number` at 30
sits mid-range (28–32). These are the two that matter most at distance. **✅ Decision 2
(resolved):** ship 52/30 as the working defaults, then validate with a ~8 ft hallway test on the
iPad (10th gen) at Phase 0 close and tune from evidence — legibility at distance is empirical, not
settleable on a laptop. Rough guide: `type.hero` ≈ 7mm cap height (comfortable up close, glanceable
to ~8–10 ft); `type.number` ≈ 4mm (glanceable to ~5–8 ft). Line-height ≈ 1.2 hero/number, ≈ 1.4 body.

---

## 4. Spacing scale

A single base unit keeps rhythm consistent and makes the grid math clean. Base = **4px**; the
scale is the useful multiples, named by size so PRDs can say "gap: `space.4`" unambiguously.

| Token       | px  | Typical use                              |
|-------------|-----|------------------------------------------|
| `space.1`   | 4   | icon-to-label nudge                      |
| `space.2`   | 8   | tight internal padding                   |
| `space.3`   | 12  | default tile inner padding               |
| `space.4`   | 16  | gaps between tiles                       |
| `space.5`   | 20  | generous section padding / screen margin |
| `space.6`   | 32  | big vertical separation (header ↔ tile row) |

Airy over dense — whitespace is a feature on a wall. The brief calls for 12–20px padding/gaps;
`space.3`–`space.5` cover the everyday range, with `space.6` reserved for the major zone breaks.

---

## 5. Radii & surface

| Token          | px     | Used for                                  |
|----------------|--------|-------------------------------------------|
| `radius.tile`  | 12     | domain tiles, focused tile                |
| `radius.screen`| 18     | outer screen/device inset                 |
| `radius.pill`  | 999    | the Assistant Bar (full pill)             |

No drop shadows in v0 — on a dark ambient wall display, **surface steps** (`bg.page` → `bg.tile`
→ `bg.raised`) do the depth work that shadows do in light UIs, and they read better from across a
room. A 1px `color.line` hairline is the fallback if a tile edge needs more definition.

---

## 6. The tile grid

The layout contract PRD 01 (P0-3) leans on. Three zones, top to bottom, on the 1180×820 canvas:

```
┌─ space.5 margin all around ─────────────────────────────┐
│  HEADER          clock/date (L) · wordmark/weather (R)   │  ~15% height
│                                                          │
│  ── space.6 ──                                           │
│                                                          │
│  TILE ROW        [ tile ]  [ tile ]  [ tile ]            │  ~55% height
│                  3 columns, equal width, gap space.4     │
│                                                          │
│  ── space.6 ──                                           │
│                                                          │
│  ASSISTANT BAR   full-width pill, pinned                 │  ~15% height
└──────────────────────────────────────────────────────────┘
```

- **Columns:** 3 equal columns for v1 (one per domain: Shopping, Tasks, Mail). A domain "plugs
  in" by claiming a column — no bespoke positioning, satisfying P0-3.
- **Growth path:** **✅ Decision 3 (resolved):** 3 columns for v1. A 6-column base is an
  *additive* split later (each column halves into two) if a wide/hero tile or a fourth domain
  appears — the existing tiles keep their positions, so it's not a rewrite. Documented, not built.
- **Assistant Bar** is *always* present and reserves its band even while stubbed (P0-6), so the
  layout never gets re-cut when Phase 2 switches it on.

---

## 7. The reusable tile (the one component the seed defines)

Every domain tile shares one anatomy, so Shopping/Tasks/Mail and future tiles stay consistent.
This is the seed's single "component" — everything else is tokens.

```
┌─ radius.tile, bg.tile, padding space.3 ──────┐
│  ◈ icon (accent)      Shopping   ← type.label │   row 1: icon + domain title
│                                               │
│   1                   ← type.number, accent   │   row 2: the ONE key number
│   to buy              ← type.label, text.sec  │   row 3: what the number means
│                                               │
│  ▢ Pasta              ← type.body, text.sec   │   row 4: one glanceable detail line
└───────────────────────────────────────────────┘
```

Tile states the shell must support (all four are in the design brief):

- **Summary (default):** icon + title + one number + one detail line. Never a full list.
- **Empty:** friendly + intentional — "You're all caught up," `text.muted`. Never looks broken.
- **Error / no-data:** deliberately **loud and honest** — a visible "Couldn't load shopping"
  using `color.status.error`. This is the fail-loud rule made visual; never fake or blank.
- **Focused:** tap → the tile expands to its full list (sections + items). Uses `bg.raised`.

The tile does **not** know about domain logic — it's a shell that renders whatever the data layer
hands it. That's what keeps it reusable across every domain (PRD 01 non-goal: no domain logic in
the shell).

---

## 8. Decisions log (all resolved 2026-08-01)

The five taste calls, and what we chose. Each reopens only on new evidence, not a new opinion.

1. **Status colors** → **Added error `#E5726B` + success `#7FC98A`; no warning.** Warning skipped
   to avoid clashing with Mail's amber accent. (§2)
2. **Hero/number sizes** → **Ship 52 / 30px as working defaults.** Validate with a ~8 ft hallway
   test on the iPad 10th gen at Phase 0 close; tune from evidence. (§3)
3. **Grid columns** → **3 columns for v1.** 6-col is an additive split later, not a rewrite. (§6)
4. **`bg.raised` surface** → **Yes — `#1E2229`.** Shadow-free depth for the Assistant Bar and
   focused tiles. (§2)
5. **Device / canvas** → **iPad 10th generation, 1180×820 pt landscape.** Placeholder was already
   correct. Nominal ~8 ft glance distance until the wall mount is chosen and measured. (§0)

---

## 9. What this unlocks

With v0 agreed, the **Shopping PRD** (PRD 02) can specify against real named tokens ("the count
uses `type.number` in `color.accent.shopping`") instead of reinventing values — and the Claude
Design mockups get a token set to honor, so what comes back is consistent with the shell by
construction, not by luck.


===================================================================
DOCUMENT 3 of 4 — 01-home-hub-prd.md
===================================================================

# PRD 01 — Home Hub (the shell)

_FamilyHub · Phase 0 · Status: **Locked** · Last updated 2026-08-02_
_Depends on: the [design-system seed](../design/design-system-seed.md) (v1.0 locked). Blocks: every other PRD._
_See [PROJECT_MAP.md](../PROJECT_MAP.md) §4–§5 for where this sits._

---

## TL;DR

The Home Hub is **the frame, not a feature**. It's the always-on surface that boots when the
wall iPad wakes, holds the domain tiles (Shopping, Tasks, Mail), reserves the slot for the
Assistant Bar, and defines the one data-layer contract every domain reads through. This PRD
deliberately builds **an empty, beautiful, working shell** — no domain logic — so that
Shopping (Phase 1) has somewhere to plug in and doesn't have to reinvent layout, navigation,
or data access.

If you only read the bold text: we're building the *stage*, not the *play*.

---

## Problem Statement

The vision is a headless assistant hanging on the wall — but an assistant with a face needs a
face to live in. Today there's no surface at all: no always-on view, no place for tiles, no
shared way to read household data, no home for the Assistant Bar. Without a defined shell,
every subsequent feature would independently invent its own layout, navigation, and data
access, and they'd drift apart immediately. The shell is the cheapest thing to get right early
and the most expensive to retrofit late.

## Goals

1. **Boots to an always-on ambient home.** When the iPad wakes, FamilyHub is already there —
   a calm, glanceable home view, no login, no launch step.
2. **Glanceable across the room.** Core information is legible at wall-mounting distance
   (roughly 6–10 feet), not just at arm's length. This is a distinct design constraint from a
   normal touch app and drives the type scale and contrast in the design-system seed.
3. **A tile grid domains plug into.** A defined layout system so Shopping/Tasks/Mail are
   drop-in, consistently sized and placed, with zero per-domain layout code.
4. **One data-layer contract, fail-loud.** A single seeded/mock data source every tile reads
   through, that surfaces missing/unknown data as a visible error *during development* (never
   silently faked), and is shaped to mirror the existing `TASKS.md` / `SHOPPING.md` conventions.
5. **A reserved Assistant Bar slot.** A persistent region for the assistant is present from
   day one (stubbed, non-functional) so Phase 2 has a home and the layout never has to be
   re-cut to make room for it.

## Non-Goals (v1 of the shell)

- **No domain logic.** No real Shopping, Tasks, or Mail behavior — those are their own PRDs.
  Tiles in Phase 0 render seeded placeholder content only. *(Keeps the shell truly reusable.)*
- **No assistant intelligence.** The Assistant Bar slot is a visual placeholder; no input
  handling, no model calls. *(That's Phase 2, and it spends money — a separate decision.)*
- **No live backend.** No reading/writing the real household files, calendar, or inbox.
  Seeded data only. *(Wiring live data is Phase 5 and needs an explicit go.)*
- **No voice.** No microphone, wake word, or transcription. *(Phase 5 polish.)*
- **No accounts / multi-user / per-person state.** It's one shared household surface.
  *(Unneeded complexity for a family MVP.)*
- **No settings/admin screens.** Configuration is code/seed-file for now. *(Premature.)*

## User Stories

Grouped by how someone actually meets a wall display.

**Passing by (glance, no touch)**
- As a family member walking past, I want to read today's most important household info from
  across the room so that I stay oriented without stopping or touching anything.
- As a family member, I want the hub to always be showing *something* calm and current so that
  a blank or asleep screen never makes it feel broken.

**Standing at it (touch)**
- As a family member at the hub, I want to tap a tile to focus it so that I can see more detail
  than the glanceable summary shows.
- As a family member in a focused view, I want an obvious way back to the home view so that I'm
  never stuck or lost.
- As a family member, I want the Assistant Bar to be visibly present (even before it works) so
  that it's clear this thing is meant to be talked to.

**Edge / empty / error**
- As a family member, I want a tile with no data to show a clear, friendly empty state so that
  "nothing here" reads as intentional, not broken.
- As the builder, I want missing or malformed seed data to surface as a loud, obvious error in
  development so that I catch data-contract breaks immediately instead of shipping fakes.

## Requirements

### Must-Have — P0 (the shell isn't real without these)

**P0-1 — Always-on home view on wake**
Given the iPad is powered and FamilyHub is running, when the display wakes, then the ambient
home view is shown immediately with no login, launch, or intermediate screen.

**P0-2 — Landscape, wall-oriented layout**
Given the hub is wall-mounted in landscape, when the home view renders, then the layout fills
the screen edge-to-edge and is designed for landscape as the primary (and, for v1, only)
orientation.

**P0-3 — Tile grid system**
- [ ] A defined grid places tiles in consistent positions and sizes.
- [ ] A domain can be added to the grid without writing layout code beyond declaring its tile.
- [ ] The Phase 0 grid renders at least one placeholder domain tile plus the Assistant Bar slot.
Given the grid is defined, when a new domain tile is declared, then it appears in a consistent
slot without bespoke positioning.

**P0-4 — Glanceable typography & contrast**
Given a family member roughly 6–10 ft away, when they look at a tile's primary content, then
the headline-level information is legible at that distance. Primary content uses the design-system
seed's `type.hero` (52px) and `type.number` (30px) on the high-contrast dark palette; the exact
sizes are the working defaults, confirmed by the ~8 ft hallway test at Phase 0 close (see Success
Metrics). Target device: iPad 10th gen, 1180×820pt.

**P0-5 — Data-layer contract with fail-loud behavior**
- [ ] All tiles read household data through a single data-access layer, not ad-hoc per tile.
- [ ] The layer is backed by seeded/mock data shaped to mirror `TASKS.md` / `SHOPPING.md`
      (sections + item states), so domains map cleanly later.
- [ ] **Mock format: hand-authored JSON** mirroring the markdown sections/states (decided). The
      typed model is the contract, not the file format — so a markdown adapter can replace the
      JSON source later (Phase 5) without touching any tile. *(This is the mock **data** format;
      unrelated to the design-system "seed".)*
- [ ] Missing/malformed data surfaces a visible error in development, never a silent fake.
Given a tile requests data that is missing or malformed, when the app is in development mode,
then a clear error state is shown rather than empty or invented content.

**P0-6 — Reserved Assistant Bar slot**
Given the home view, when it renders, then a persistent Assistant Bar region is present in a
fixed position (visually styled, functionally stubbed), such that enabling it later requires no
layout change.

**P0-7 — Home ⇄ focus navigation**
Given a placeholder tile, when a family member taps it, then a focused view for that tile opens;
and when they trigger "back," then they return to the ambient home view. Navigation is
touch-first and reachable without precise aim.

**P0-8 — Surface owns a mode concept (ambient ⇄ engaged)**
The Home Hub is a **two-mode surface**: *ambient* (the tile grid, the default at-rest state) and
*engaged* (a conversational takeover when the hub is addressed — see
[engaged-mode-notes.md](../design/engaged-mode-notes.md)). Given the shell, when it runs, then it
tracks which mode it is in and treats ambient as the default it always returns to; *engaged mode is
stubbed in Phase 0* (no conversation, no voice). This is a P0 because retrofitting a whole-surface
mode swap after the shell is built is expensive; owning the concept now (even stubbed) keeps it cheap.
Given engaged mode is triggered (a hot word, per the notes), when triggered, then the shell can
switch modes without a layout rebuild; and on silence/close-out word, it returns to ambient.

### Nice-to-Have — P1 (fast follow, not blocking)

- **P1-1 — Ambient/idle refinement:** a gentle time-of-day treatment (e.g. dimmer, calmer
  palette in the evening) so the wall display isn't harsh at night.
- **P1-2 — Clock / date / at-a-glance header:** a persistent header showing time and date —
  genuinely useful on a wall and cheap to add.
- **P1-3 — Graceful loading states:** skeleton/placeholder shimmer for tiles while seed data
  loads, so first paint never flashes empty.

### Future Considerations — P2 (design so as not to preclude)

- **P2-1 — Portrait orientation** support (don't hard-code assumptions that break it).
- **P2-2 — Live backend data source** swapped in behind the same data-layer contract (Phase 5).
- **P2-3 — Engaged mode: the Assistant taking over the full surface** (voice-forward). Now a
  first-class **ambient ⇄ engaged** model, not just "the bar expands" — the shell owns the mode
  concept in Phase 0 (P0-8), a *text* engaged mode arrives in Phase 2, and the *voice* pieces
  (waveform, live STT, hot-word listening) in Phase 5. Full spec lives in the Assistant Bar PRD;
  concept + wireframe in [engaged-mode-notes.md](../design/engaged-mode-notes.md).
- **P2-4 — Multiple hubs / rooms** reading the same household state.

## Success Metrics

This is a family MVP, so metrics are lightweight and mostly a **definition-of-done** plus a few
qualitative checks — not analytics dashboards.

**Leading (verify at Phase 0 close)**
- Cold wake → ambient home visible with **no manual step**, every time (target: 10/10 wakes).
- A new placeholder tile can be added in **under ~15 min** of work using only the grid +
  data-layer APIs (proxy for "the shell is actually reusable").
- Malformed seed data produces a **visible dev error 100% of the time** (fail-loud verified).
- Primary tile content readable at **~8 ft** in a real hallway test (qualitative pass/fail).

**Lagging (over the next phases)**
- Shopping (Phase 1) plugs in **without modifying the shell's layout or navigation** — the true
  test that Phase 0 was right.
- No shell rework required when the Assistant Bar is switched on in Phase 2.

## Decisions & Open Questions

**Decided (2026-08-02, at lock):**
- **[hardware] Target device** → **iPad 10th gen, 1180×820pt landscape.** Sets the grid dimensions
  and the type target (P0-4). *(The mount + exact viewing distance stay open — see below.)*
- **[design] Default theme** → **dark-first**, per the design-system seed. (Ties to P1-1.)
- **[design] Mock data format** → **hand-authored JSON mirroring the markdown sections** (P0-5).
  The typed model is the contract; a markdown adapter can replace the source later.
- **[product] Hero glanceable info** → **clock + date + weather header**, per the design brief.
  (Affects P1-2.)

**Still open:**
- **[hardware] Mount + viewing distance.** Which wall mount, and how far the usual glance is.
  Only affects final pixel-tuning of the two big type sizes, not structure. *(Non-blocking;
  measured once the wall spot is chosen, revisit at the Phase 5 wall install.)*
- **[engineering] Always-on approach.** Guided Access / kiosk mode, a keep-awake setting, or
  screen-saver integration? Affects P0-1 and battery/burn-in. *(Not blocking the simulator build;
  decided before a real wall install — Phase 5.)*
- **[product] Calendar in engaged mode.** The engaged-mode sidebar shows a Family Calendar, which
  isn't one of the three tile domains — new domain, or surfacing the backend calendar? *(Deferred
  to the Assistant Bar PRD; see [engaged-mode-notes.md](../design/engaged-mode-notes.md).)*

## Timeline Considerations

- **This is Phase 0** — it precedes and blocks everything else, so it's first regardless.
- **Hard dependency:** the **design-system seed** (tokens: color, type scale, spacing, grid)
  should be drafted alongside or just before this, because P0-3 and P0-4 reference it directly.
- **No external deadlines** (hobby project). Phasing within the shell if useful: (a) grid +
  ambient home + navigation against a stub data source, then (b) the fail-loud data-layer
  contract + Assistant Bar slot.

---

### Suggested next artifacts
1. ✅ **Design-system seed** — [locked v1.0](../design/design-system-seed.md).
2. **PRD 02 — Shopping** — the first vertical slice that proves the shell. *(Next up.)*


===================================================================
DOCUMENT 4 of 4 — engaged-mode-notes.md
===================================================================



# FamilyHub — Engaged Mode (concept note)

_Companion to [PRD 01 — Home Hub](../prds/01-home-hub-prd.md) and the
[design-system seed](design-system-seed.md). Status: **concept captured — full spec deferred to the
Assistant Bar PRD.** Last updated 2026-08-02._

> **Why this note exists.** The Home Hub is a **two-mode surface**, not one layout. This note
> captures the second mode so the idea isn't lost before the Assistant Bar PRD specs it properly.
> Reference wireframe: `engaged-mode-wireframe.png`.

---

## The two modes

- **Ambient mode (at rest)** — the tile grid from PRD 01 + the design-system seed. Calm,
  glanceable, read from across the room. This is the default the surface always returns to.
- **Engaged mode (when addressed)** — a conversational takeover. The whole surface becomes the
  conversation; the domains demote to a glance sidebar. This is the vision's "conversation *is*
  the product" made literal, rather than a persistent bar in a footer.

The resting Assistant Bar and Engaged mode are **the same feature in two states** — the bar is the
entry point; being addressed expands it into the full canvas. They should be designed as one thing.

## Engaged-mode layout (from the wireframe)

```
+-------------------------------------------------------------+
| [ Top Bar: Household Status ]        [ Time / Date Header ] |
+---------------------------------------+---------------------+
|  MAIN CONVERSATIONAL CANVAS           |  SIDEBAR (Glance)   |
|   - Active Voice Waveform             |   - Family Calendar |
|   - STT Live Streaming                |   - Shared Tasks    |
|   - Dynamic Intent Response Cards     |   - Live Status Hub |
+---------------------------------------+---------------------+
| [ Bottom Status: Voice Agent Listening State / System Logs ]|
+-------------------------------------------------------------+
```

## Trigger & return (decided 2026-08-02)

- **Trigger:** fully voice-activated. A **hot word** switches the surface into Engaged mode.
- **Return:** **silence** (a timeout) or a spoken **close-out word** returns it to Ambient mode.
- No touch is required to enter or leave Engaged mode; touch is a convenience, not the path.

## Phasing — this spans three roadmap phases

| Piece | Phase | Notes |
|-------|-------|-------|
| The **mode concept** — shell knows "which mode am I in" | **Phase 0** | Engaged mode stubbed; the shell must not preclude the swap (PRD 01 P2-3 / new P0 note). |
| **Text** engaged mode (typed conversation) | **Phase 2** | Assistant Bar v1, wired to Shopping. |
| **Voice** pieces — waveform, live STT, hot-word listening state | **Phase 5** | The voice-forward end state drawn in the wireframe. |

## Constraints & open flags

- **Engaged mode is not "up close."** Because entry is by voice, you'll often address it from
  6-10 ft away. The canvas (waveform, response cards) must stay legible at that distance — same
  constraint as Ambient mode, not laptop-sized. Up-close detail only matters when someone walks
  over to touch a response card.
- **Reuses the design-system seed as-is** — same tokens, type scale, surfaces. Engaged mode is a
  new *layout*, not a new visual language. May add 1-2 tokens later (a "listening" accent — the
  new color.status.* set may already cover it; a waveform color).
- **[open] Calendar in the sidebar** — the wireframe shows *Family Calendar*, which is **not** one
  of the three tile domains (Shopping/Tasks/Mail). Decision for the Assistant Bar PRD: is Calendar
  a new domain, or is Engaged mode surfacing the household backend's existing calendar directly?
- **[open] System Logs in the bottom bar** — great for the "fail loud while building" ethos during
  development; gate it to dev mode so raw logs don't show on a family wall in the shipped surface.

## Where the full spec lives

This note is a **capture**, not a spec. Triggers, the return timeout, the mode state machine, the
sidebar contents, and the voice UI belong to the **Assistant Bar PRD** (Phase 2/3 in the PRD order).
