# Claude Design brief — FamilyHub Home Hub (shell)

_Companion to [PRD 01 — Home Hub](../prds/01-home-hub-prd.md). Purpose: hand this to Claude
Design to generate the ambient home view and its core states. Everything here is v1 of the
shell — the frame, not the features._

---

## ✂️ Paste this into Claude Design first

> Design the home screen for **FamilyHub**, an always-on, wall-mounted iPad "home hub" for a
> family (think Google Nest Hub, but Claude-flavored). It's a **primarily headless assistant
> with a face**: you mostly talk to it, and the screen is the calm, glanceable backup.
>
> Canvas: **iPad landscape, 4:3 (e.g. 1180×820), viewed from ~6–10 feet away.** Dark-first
> ambient theme. Everything must be legible across a room, so type is large and contrast is high.
>
> Design an **ambient home screen** with three zones: (1) a top status header with a large
> clock, date, and weather; (2) a row of **three domain tiles** — Shopping, Tasks, and Mail &
> Packages — each showing a glanceable *summary* (a big number + one line of detail), not a full
> list; (3) a persistent **Assistant Bar** pinned along the bottom — a rounded input/mic pill
> that invites talking to the hub. Calm, spacious, minimal. No clutter, no chrome-for-its-sake.
>
> Then design these additional states as separate frames: a **focused tile view** (Shopping
> expanded to its full list), a **tile empty state**, a **tile error / no-data state** (this is
> deliberately loud, not hidden), and the **Assistant Bar in three states** (idle, listening,
> showing a reply). Use the palette, type scale, and seed data below.

---

## Context (so the design has a soul, not just boxes)

FamilyHub is a hobby project for the Reynolds family — experimental, but high-fidelity. The
long-term vision is a device on the wall you *talk to* to run the home. So the conversation is
the star; the tiles are what it shows you when you glance over or want to tap. Design for a
household (two adults, a toddler, a cat), not an enterprise dashboard. Warm, unfussy, a little
bit of character.

## Canvas & viewing conditions

- **Device:** iPad, **landscape**, 4:3 aspect (design at ~1180×820; exact model TBD).
- **Distance:** wall-mounted, read from **6–10 feet** — this is the single biggest constraint.
  Primary info should be legible at a glance; secondary detail can be smaller for up-close.
- **Theme:** **dark-first ambient** (calmer on a wall, better at night). A light variant is a
  nice-to-have, not required for v1.
- **Orientation:** landscape only for v1 (don't rely on layouts that break in portrait later).

## Visual direction & starting tokens

These come from an early sketch — treat them as a **starting point to refine**, not gospel.
Please propose a tightened, named token set as part of the output.

**Color (dark theme)**
- Page background: near-black, `#0D0F12`
- Tile surface: `#15181D` (one step up from the page)
- Primary text: `#E7E9EE` · Secondary text: `#9AA0AB` · Muted/hint: `#6F757F`
- Hairlines / dividers: `#333842`
- **Domain accent colors** (each domain gets one, used sparingly for its icon + key number):
  - Shopping → teal `#5DCAA5`
  - Tasks → blue `#7F9FF0`
  - Mail & Packages → amber `#EFB45A`
- Keep accents for meaning (which domain, status), not decoration. One accent per tile.

**Type scale (glanceable-first)**
- Clock / hero number: ~48–56px, weight 500
- Tile summary number: ~28–32px, weight 500
- Tile title / labels: ~13–15px
- Body / list items: ~14–16px
- Two weights only: 400 regular, 500 medium. Sentence case everywhere. No all-caps except a
  subtle wordmark.

**Shape & spacing**
- Tile radius ~12px; outer device/screen radius ~16–20px; the Assistant Bar is a full pill
  (~999px radius).
- Generous padding and gaps (~12–20px). Airy, not dense. Whitespace is a feature on a wall.

## Layout anatomy (the ambient home)

```
┌───────────────────────────────────────────────┐
│  7:24                              FAMILYHUB    │  ← header: clock+date (L), wordmark+weather (R)
│  Wednesday, July 22                 ☁ 64° SF    │
│                                                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐       │
│  │ Shopping │  │  Tasks   │  │  Mail &  │       │  ← three domain tiles
│  │    1     │  │    1     │  │ packages │       │     each: icon + title, big number,
│  │ to buy   │  │ to-do    │  │    2     │       │     one glanceable line of detail
│  │ ▢ Pasta  │  │ ▢ Skyli… │  │ 📦 Diap… │       │
│  └──────────┘  └──────────┘  └──────────┘       │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ 🎤  Ask me anything — "add milk…"        │   │  ← persistent Assistant Bar (pinned bottom)
│  └─────────────────────────────────────────┘   │
└───────────────────────────────────────────────┘
```

The Assistant Bar is **always present** and visually prominent — it's the front door, not a
footer afterthought.

## Screens / frames to produce

1. **Ambient home** — the layout above. The hero deliverable.
2. **Focused tile view — Shopping** — tap a tile → it expands to show the full list (Grocery +
   Household sections, checkable items). Shows the glance→detail transition the shell needs.
3. **Tile empty state** — e.g. Tasks with nothing due. Friendly and intentional ("You're all
   caught up"), never looks broken or blank.
4. **Tile error / no-data state** — deliberately **visible and honest** (a clear "couldn't load
   shopping" state), because the app's rule is to fail loud in development, never fake data.
5. **Assistant Bar — three states:** idle (prompt text), listening (active mic / waveform), and
   showing a short reply (e.g. "Added milk to the grocery list").

## Seed data to use (real household content)

Use this so the screens feel true, not lorem-ipsum:

- **Shopping → Grocery:** Pasta. **Household:** (empty). *(Sections + a "Recently bought" area
  exist in the real data model.)*
- **Tasks → Family:** "Skylight Frame decision" (buy vs. DIY). Other sections: Open, Waiting on,
  Someday — mostly empty right now.
- **Mail & Packages:** a couple of inbound deliveries (e.g. "Diapers — arriving today"). This
  domain is a placeholder concept; keep it plausible and light.
- **Header:** 7:24, Wednesday July 22, 64° San Francisco.

## Guardrails — what NOT to design (v1 of the shell)

- **No deep domain functionality.** Tiles summarize; the focused view lists. No editing flows,
  filters, or settings — those belong to each domain's own PRD later.
- **No working assistant intelligence.** The Assistant Bar is a visual/interaction shell only
  (idle/listening/reply states). No conversation threads or model output design.
- **No accounts, multi-user, or per-person views.** One shared household surface.
- **No live-data or connected-account UI.** It reads seeded data; don't design auth or sync.
- **Don't over-decorate.** If in doubt, quieter and lighter. "Too cluttered" is the usual miss
  on a wall display seen from across the room.

## What we'd love back from Claude Design

- The ambient home + the 4 supporting frames above.
- A **tightened, named token set** (colors, type scale, spacing, radii) we can lift into the
  design-system seed.
- A **reusable tile spec** (how any domain tile is structured) so Shopping/Tasks/Mail and future
  tiles stay consistent.
