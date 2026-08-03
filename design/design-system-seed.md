# FamilyHub — Design-System Seed (v0)

_Companion to [PRD 01 — Home Hub](../prds/01-home-hub-prd.md) and its
[Claude Design brief](claude-design-brief--home-hub.md). Status: **v1.1** — 5 taste calls resolved
(§8) + scoping-critic revisions (§10). Last updated 2026-08-02._

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
- **Growth path:** **✅ Decision 3 (resolved):** 3 columns for v1. *Correction (post-critic L1):* a
  6-column base does **not** let a fourth domain slot in for free — three equal tiles already fill
  all six half-columns, so a 4th domain needs an explicit layout rule (a second tile row, a
  narrower-tile re-flow, or paging), which is a real design change, not a free split. A 6-col base
  still helps *within* a row (e.g. a double-wide/hero tile spanning 4 of 6), and that much is
  additive. The open Calendar domain is the concrete trigger. Documented, not built.
- **Safe areas (post-critic L6):** the grid lays out within iOS safe areas. The iPad 10th gen has no
  home button — a bottom home-indicator gesture strip sits under the Assistant Bar band; keep the
  bar's touch targets and text clear of it. "Edge-to-edge" is a background/visual claim, not license
  to place controls under the indicator.
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

**The glance line (row 4) is a *derived summary*, not the raw record (post-critic L4).** For a task
like `**Skylight Frame decision** — deliberating buy vs. DIY`, the tile shows a short derived label
(e.g. the title only), truncated gracefully — never the full formatted string. The complete title +
em-dash context renders in the **focused** view, where there's room. Rendering the raw string in the
glance line would strip its formatting and truncate mid-context at 8 ft.

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

## 10. Post-critic revisions (2026-08-02)

From the scoping-critic pass (GPT + Gemini) on the planning package:

- **§6 grid growth claim corrected (L1):** a 4th domain is *not* a free 6-column split; it needs a
  real layout rule. The additive part is limited to wide/hero spans within a row.
- **§6 safe-area rule added (L6):** layout respects iOS safe areas; keep Assistant Bar controls
  clear of the bottom home-indicator strip (iPad 10th gen has no home button).
- **§7 glance line clarified (L4):** row 4 is a derived summary, not the raw formatted record; full
  title + context live in the focused view.

_The data-model fidelity finding (C1) and the phased-parser decision (C3) live in PRD 01 P0-5, since
they're data-layer contract, not visual tokens._
