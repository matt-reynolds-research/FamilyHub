# PRD 01 — Home Hub (the shell)

_FamilyHub · Phase 0 · Status: **Locked (rev. 2026-08-02, post scoping-critic)** · Last updated 2026-08-02_
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

**P0-1 — Ambient home on launch/resume**
Given FamilyHub is running, when the app launches or resumes from background, then the ambient home
view is shown immediately with no login, launch, or intermediate screen. *Scope note (post-critic):*
Phase 0 validates this at the **app level** (simulator / on-device app lifecycle). The **physical
always-on wake** — the iPad never sleeping, waking instantly on the wall — depends on the
kiosk/keep-awake mechanism, which is a **Phase 5** decision (see Decisions & Open Questions); it is
not part of Phase 0's definition of done.

**P0-2 — Landscape, wall-oriented layout**
Given the hub is wall-mounted in landscape, when the home view renders, then the layout fills the
screen edge-to-edge **within the iOS safe areas** and is designed for landscape as the primary (and,
for v1, only) orientation. *(The iPad 10th gen has no home button; a bottom home-indicator gesture
strip sits under the pinned Assistant Bar and must not be occluded — post-critic L6.)*

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
- [ ] The typed model is **lossless against the real files** (post-critic C1) — it carries every
      field the verified `TASKS.md` / `SHOPPING.md` structure encodes, not just "sections + a
      checked bool": section, item title, **optional note/quantity** (`Milk (2 gallons)`),
      **completion date**, **source-list provenance** (`~~Milk~~ (grocery, 2026-04-18)`), the task
      **title + em-dash context** split, and the **terminal archive sections** (Recently Bought /
      Done). Acceptance test is a **round-trip fixture**: every real form parses → renders →
      mutates → serializes → restores with no information loss.
- [ ] **Data source, phased (revised post-critic C3):** Phase 0 uses a hand-authored JSON *stub* to
      stand the shell up; **Phase 1 builds the real Dart parser against `SHOPPING.md`** — the
      highest-risk piece (parsing the human-authored markdown conventions) is proven early, not
      deferred to Phase 5. The typed model is the stable contract; JSON stub and markdown parser are
      interchangeable sources behind it. *(This is the mock **data** format; unrelated to the
      design-system "seed".)*
- [ ] **Write ownership (post-critic L3):** the client owns *user* actions (add, check).
      **Archive-clearing is agent-owned** (the ~7-day sweep) — the client reads a cleared state; it
      never implements a destructive client-side clear. Concurrent writes with the existing backend
      automations are a live-wiring precondition (see Decisions & Open Questions).
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
**Phase 0 acceptance uses a non-voice synthetic trigger** (post-critic C2) — a dev/debug affordance
(e.g. a tap on the stubbed Assistant Bar) plus a timer event — to prove the shell switches
ambient→engaged without a layout rebuild and returns to ambient on timeout. The real hot-word /
silence / close-out **voice** events (Phase 5) must plug into the *same* state-machine interface
without shell changes; that interface — not the voice — is what P0-8 locks. Voice remains a Phase 0
non-goal.

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
- App launch/resume → ambient home visible with **no manual step**, every time (target: 10/10
  launches/resumes, app-level). *Physical always-on wake is validated in Phase 5, not here (post-critic L2).*
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
- **[engineering] Concurrent writes with backend automations (post-critic L5).** Once FamilyHub
  writes the live files (Phase 5), it shares them with existing automations (10 PM sweep, email-in
  handler). Needs a write-arbitration/locking approach before any live wiring. *(Phase 5
  precondition; mock/stub-only until then, so no conflict during Phase 0–4.)*
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

## Rejected ideas (post scoping-critic — don't re-propose without new evidence)

- **Data model = sections + a checked boolean.** Rejected: the verified files carry provenance,
  dates, notes/quantity, and title/context; a thin model loses them and breaks the future markdown
  adapter (critic C1). The typed model is lossless instead (P0-5).
- **Defer the markdown parser entirely to Phase 5.** Rejected: it strands the project's highest
  technical risk at the very end (critic C3). The parser moves up to Phase 1 against `SHOPPING.md`.
- **Client-side destructive "clear."** Rejected: clearing is the agent's ~7-day sweep; a client
  clear is false validation and clashes with the backend (critic L3). Client reads a cleared state.
- **6 columns lets a 4th domain slot in for free.** Rejected as false: three equal tiles fill all
  six half-columns; a 4th domain needs a real layout rule (critic L1). Corrected in the seed.

### Suggested next artifacts
1. ✅ **Design-system seed** — [locked v1.1](../design/design-system-seed.md).
2. **PRD 02 — Shopping** — the first vertical slice that proves the shell (now also home of the
   real `SHOPPING.md` parser). *(Next up.)*
