# FamilyHub — Engaged Mode (concept note)

_Companion to [PRD 01 — Home Hub](../prds/01-home-hub-prd.md) and the
[design-system seed](design-system-seed.md). Status: **concept captured — full spec deferred to the
Assistant Bar PRD.** Last updated 2026-08-02._

> **Why this note exists.** The Home Hub is a **two-mode surface**, not one layout. This note
> captures the second mode so the idea isn't lost before the Assistant Bar PRD specs it properly.
> Reference wireframe: [`engaged-mode-wireframe.png`](engaged-mode-wireframe.png).

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
┌─────────────────────────────────────────────────────────────┐
│ [ Top Bar: Household Status ]        [ Time / Date Header ]  │
├───────────────────────────────────────┬─────────────────────┤
│  MAIN CONVERSATIONAL CANVAS            │  SIDEBAR (Glance)   │
│   - Active Voice Waveform              │   - Family Calendar │
│   - STT Live Streaming                 │   - Shared Tasks    │
│   - Dynamic Intent Response Cards      │   - Live Status Hub │
├───────────────────────────────────────┴─────────────────────┤
│ [ Bottom Status: Voice Agent Listening State / System Logs ] │
└─────────────────────────────────────────────────────────────┘
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
  6–10 ft away. The canvas (waveform, response cards) must stay legible at that distance — same
  constraint as Ambient mode, not laptop-sized. Up-close detail only matters when someone walks
  over to touch a response card.
- **Reuses the design-system seed as-is** — same tokens, type scale, surfaces. Engaged mode is a
  new *layout*, not a new visual language. May add 1–2 tokens later (a "listening" accent — the
  new `color.status.*` set may already cover it; a waveform color).
- **🟡 Calendar in the sidebar** — the wireframe shows *Family Calendar*, which is **not** one of
  the three tile domains (Shopping/Tasks/Mail). Decision for the Assistant Bar PRD: is Calendar a
  new domain, or is Engaged mode surfacing the household backend's existing calendar directly?
- **🟡 System Logs in the bottom bar** — great for the "fail loud while building" ethos during
  development; gate it to dev mode so raw logs don't show on a family wall in the shipped surface.

## Where the full spec lives

This note is a **capture**, not a spec. Triggers, the return timeout, the mode state machine, the
sidebar contents, and the voice UI belong to the **Assistant Bar PRD** (Phase 2/3 in the PRD order).
