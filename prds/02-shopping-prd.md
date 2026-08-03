# PRD 02 — Shopping (the first vertical slice)

_FamilyHub · Phase 1 · Status: **Draft (2026-08-02)** · Last updated 2026-08-02_
_Depends on: [PRD 01 — Home Hub](01-home-hub-prd.md) (locked) and the [design-system seed](../design/design-system-seed.md) (v1.1). Blocks: PRD 03 — Assistant Bar (needs one real domain to talk to)._
_See [PROJECT_MAP.md](../PROJECT_MAP.md) §4–§5 for where this sits._

---

## TL;DR

Shopping is **the first real domain** — the slice that proves the whole pipeline works
end-to-end: the seeded data layer → the design-system tile → touch interaction → back to
state. It's deliberately the *most constrained* domain (two flat lists, add + check, no
attribution, no due dates), which is exactly why it goes first (D-03).

This PRD also carries the single highest-risk piece of the project: **the real Dart parser for
`SHOPPING.md`**, promoted out of Phase 5 and into here (D-10). Parsing the human-authored
markdown — with its quantities, strikethroughs, provenance stamps, and archive section — is the
thing most likely to be harder than it looks, so we prove it against the real file now, not at
the end. The parser produces a **lossless** typed model (PRD 01 P0-5): every real form must
round-trip (parse → render → mutate → serialize → restore) with zero information loss.

If you only read the bold text: **build the Shopping tile for real, and settle the markdown
model by making it survive a round-trip against the actual `SHOPPING.md`.**

---

## Problem Statement

PRD 01 built an empty shell — a beautiful stage with placeholder tiles and a stubbed data layer.
Nothing in it touches real household data yet, and no domain has proven that a tile can actually
render, be interacted with, and stay faithful to the household's conventions. Until one domain
goes all the way through, we don't actually know whether the shell is reusable, whether the
data-layer contract holds, or — most importantly — whether we can reliably read and write the
markdown files the household already runs on.

Shopping is the cheapest domain to answer those questions with. It has the least structure of the
three (a to-do task carries a title, em-dash context, attribution, and completion state; a
shopping item is basically "a line, maybe a parenthetical"), so it isolates the *pipeline* risk
from *domain-complexity* risk. Get Shopping right and the shell is validated; get the parser right
and the project's scariest unknown is retired early.

## How Shopping already works (the world we're surfacing)

FamilyHub is a new *surface* over an existing *world* (PROJECT_MAP §3). Shopping today is
[`SHOPPING.md`](../../SHOPPING.md), edited by the shipped text assistant per
[`family-assistant/list-conventions.md`](../../family-assistant/list-conventions.md). The tile
must mirror those conventions exactly, because the same file is read by the 6:30 AM Morning
Briefing and written by text/email commands — if FamilyHub ever diverges from the format, it
breaks the other surfaces. The verified structure:

- **Two active lists**, each an `##` section: **`## Grocery`** (food/kitchen) and
  **`## Household`** (everything else). Each has a short italic intro line and an HTML-comment
  example block.
- **One archive section: `## Recently Bought`** — bought items land here and the *agent* clears
  entries older than ~7 days. This is not a client action (see Write Ownership, P1-4 / L3).
- **Active item forms:**
  - `- [ ] Pasta` — bare item.
  - `- [ ] Milk (2 gallons)` — item + a **trailing parenthetical** note/quantity.
  - `- [ ] Bread — sourdough if they have it` — the example block also shows an em-dash note
    form; the parser must not choke on it even though the live list currently uses parentheticals.
- **Bought item form:** `- [x] ~~Milk~~ (grocery, 2026-04-18)` — checked box, **strikethrough**
  item text, then a parenthetical carrying **source-list provenance** (`grocery` | `household`)
  and a **completion date** (`YYYY-MM-DD`).
- **Ordering is append-to-end:** new items go to the end of their section; bought items move to
  the end of `## Recently Bought` (per `list-conventions.md` GROCERY/SHOP/BOUGHT_* behaviors).
- **Dedup key:** item text = the line minus its trailing parenthetical (so `Milk` and
  `Milk (2 gallons)` are the same item).

> **Build-time rule (unchanged):** Phase 1 develops against a **committed fixture copy** of
> `SHOPPING.md`, never the live household file (AGENTS.md — never test against real family data).
> Live wiring is Phase 5 and needs an explicit go.

## Goals

1. **A real Shopping tile, end-to-end.** It renders live from the data layer in all four tile
   states (summary / empty / error / focused), not placeholder content — the first tile that does.
2. **The lossless `SHOPPING.md` parser exists and is proven.** A Dart parser reads the real file
   into the typed model and serializes back with **zero information loss**, verified by a
   round-trip fixture test covering every real form above. This is the P0-5 contract made concrete.
3. **Add + check work, user-owned, format-faithful.** A family member can add an item and check
   one off by touch, and the resulting markdown is **byte-compatible** with what the text
   assistant would have written — same section, same append-to-end, same provenance stamp.
4. **The shell is validated by plugging in.** Shopping drops into the Phase 0 grid **without
   modifying the shell's layout or navigation** — the true test that PRD 01 was right (PRD 01
   lagging metric).
5. **Fail loud on bad data.** Malformed or unparseable markdown surfaces a visible dev error and a
   loud tile error state — never a silent fake or a dropped item.

## Non-Goals (Shopping v1)

- **No Assistant Bar control.** "Add milk" by voice/text through the assistant is **PRD 03 /
  Phase 2**. Shopping v1 is touch-only. *(The assistant needs a real domain first — that's this.)*
- **No live file writes.** The tile reads and mutates a **fixture** copy; it does not touch the
  household's real `SHOPPING.md`. *(Live wiring + concurrent-write arbitration is Phase 5, per
  D-11.)*
- **No editing / renaming / reordering / deleting** arbitrary items. The only mutations are
  **add** and **check** (and the model *reads* the agent-cleared archive). *(Matches what the
  backend commands actually do; anything else is scope creep.)*
- **No client-side archive clearing.** Clearing `## Recently Bought` is the agent's ~7-day sweep.
  The client renders whatever state it reads. *(L3 — a client clear is false validation and would
  clash with the backend.)*
- **No new categories** beyond Grocery and Household. *(The file has exactly two active lists.)*
- **No per-item attribution.** Unlike Tasks, `SHOPPING.md` items carry no "added by" annotation;
  we don't invent one. *(Keeps the first slice minimal.)*
- **No quantity math / units parsing.** `(2 gallons)` is an opaque note string, not a structured
  quantity. *(Parse it losslessly; don't interpret it.)*

## User Stories

**Passing by (glance)**
- As a family member walking past, I want to see at a glance how many things we still need to buy,
  so I know whether a store run is worth it without stopping.

**Standing at it (touch)**
- As a family member at the hub, I want to tap the Shopping tile to see the full Grocery and
  Household lists, so I can read exactly what's needed.
- As a family member, I want to add an item by touch, so something I just noticed we're out of
  gets on the list immediately.
- As a family member, I want to check an item off when I've bought it, so it moves to Recently
  Bought and stops showing as needed — the same way `BOUGHT GROCERY:` behaves.

**Consistency with the rest of the house**
- As the household, I want an item added or checked at the hub to look identical in `SHOPPING.md`
  to one added by text, so the Morning Briefing and the text assistant stay correct.

**Edge / empty / error**
- As a family member, I want an all-caught-up list to say so warmly, so an empty list reads as
  "done," not "broken."
- As the builder, I want an unparseable line to fail loudly in development, so I catch a
  format-contract break immediately instead of silently losing an item.

## Requirements

### Must-Have — P0 (Shopping isn't real without these)

**P0-1 — The typed Shopping model is lossless**
- [ ] A typed model represents the file: an ordered list of **sections** (Grocery, Household,
      Recently Bought), each carrying its **intro prose** and **example/comment block** verbatim,
      and an ordered list of **items**.
- [ ] An **active item** carries: raw title, optional trailing **note/quantity** string, and its
      section. A **bought item** additionally carries: **source-list provenance**
      (`grocery`|`household`), **completion date**, and the strikethrough form.
- [ ] Non-item content (section intros, HTML-comment example blocks, blank-line rhythm, the file
      preamble/header) is preserved, not dropped — the model round-trips the **whole file**, not
      just the bullets.
- [ ] **Acceptance = round-trip fidelity:** for a fixture set covering every real form (bare item,
      parenthetical note, em-dash note, bought item with provenance+date, empty section, the
      comment blocks, the preamble), `parse(text)` → `serialize(model)` is **byte-identical** for
      the unmutated case, and **semantically lossless** (only the intended line changes) after a
      single add or check. *(This is PRD 01 P0-5's round-trip test, realized for Shopping.)*

**P0-2 — The Dart parser reads the real `SHOPPING.md` structure**
- [ ] Parses the two active sections, the archive section, both active item forms (bare +
      parenthetical) and the em-dash note form, and the bought-item form
      (`- [x] ~~text~~ (list, date)`).
- [ ] Uses the backend's **dedup key** (line minus trailing parenthetical) so the model agrees
      with `list-conventions.md` on what "the same item" means.
- [ ] **Fails loud** on a line it can't classify inside a known section (raises in dev; never
      silently skips). Unknown top-level content outside known sections is preserved verbatim, not
      reinterpreted.
- [ ] Reads from the **committed fixture**, behind the same data-layer interface PRD 01 defined, so
      the JSON stub and this parser are interchangeable sources of the same model.

**P0-3 — Summary tile (the glance state)**
- [ ] Renders via the seed's reusable tile (§7): Shopping icon + "Shopping" title in
      `color.accent.shopping` (`teal.400`), **one key number** in `type.number`, one derived glance
      line in `type.body`/`text.secondary`.
- [ ] **The key number = total unchecked items across Grocery + Household** (e.g. `3` / "to buy").
      Rationale in Decisions; combined count is the single most glanceable "is a store run worth
      it" signal.
- [ ] **The glance line is a derived summary** (L4), e.g. `Grocery 2 · Household 1`, never a raw
      markdown line. Truncates gracefully.

**P0-4 — Focused tile (tap to open the full list)**
- [ ] Tapping the tile opens the focused view (`bg.raised`, per seed §7) showing **Grocery** and
      **Household** as labeled sections with their unchecked items as `type.body` rows, each with a
      checkable control sized for touch-without-precise-aim (PRD 01 P0-7).
- [ ] `## Recently Bought` is shown **secondary and de-emphasized** (or collapsed) — visible for
      "did we already get that?" but clearly not part of the active list. Read-only; never
      client-cleared.
- [ ] An obvious **back** affordance returns to ambient home (PRD 01 P0-7).

**P0-5 — Add (user-owned)**
- [ ] From the focused view, a family member can add an item to a chosen section via a minimal
      touch affordance (an inline "+ add" field per section — **not** the Assistant Bar, which is
      Phase 2).
- [ ] Add writes `- [ ] <item>` (or `- [ ] <item> (<note>)`) appended to the **end** of the target
      section, matching `list-conventions.md` GROCERY/SHOP exactly.
- [ ] **Dedup:** if an unchecked item with the same dedup key exists in that section, it is not
      duplicated; the UI says so calmly (mirrors `Already on the grocery list:`), and the file is
      unchanged.

**P0-6 — Check / mark bought (user-owned)**
- [ ] Checking an active item moves it to the **end of `## Recently Bought`** as
      `- [x] ~~<item text>~~ (<grocery|household>, <YYYY-MM-DD>)`, with **today's date** and the
      correct source-list provenance — byte-compatible with `BOUGHT_GROCERY`/`BOUGHT_SHOP`.
- [ ] The item's trailing parenthetical note is dropped from the archived line (the backend's
      bought form keeps only `~~text~~ (list, date)`), matching the shipped behavior. *(Verify
      against `list-conventions.md` BOUGHT_*; this is the one place a note is intentionally not
      carried — confirm it's lossless-by-design, not a bug.)*
- [ ] Checking is **not** destructive deletion; nothing leaves the file, it relocates to the
      archive (which only the agent later clears).

**P0-7 — Empty & error states (fail-loud made visual)**
- [ ] **Empty:** both active lists empty → the seed's empty state ("You're all caught up,"
      `text.muted`), never a blank or broken-looking tile.
- [ ] **Error / no-data:** unparseable file or a data-layer failure → the seed's loud error state
      ("Couldn't load shopping," `color.status.error`) in dev; never a silent fake.

**P0-8 — Plugs into the shell unchanged**
- [ ] Shopping is added by **declaring its tile and claiming a grid column** (PRD 01 P0-3); no
      edits to the shell's layout, navigation, or the Assistant Bar band are required. If any are,
      that's a PRD 01 defect to fix in the shell, not a Shopping workaround.

### Nice-to-Have — P1 (fast follow, not blocking)

- **P1-1 — Section counts on the tile back / focused header:** small per-section counts
  (`Grocery 2`, `Household 1`) rendered in the focused header, not just the derived glance line.
- **P1-2 — Undo-check window:** a brief "Undo" after checking, since the mutation is local and
  reversible pre-serialize. *(Cheap safety net; not required for the slice.)*
- **P1-3 — Note/quantity visible in the focused row:** show `(2 gallons)` as a muted suffix on the
  focused item row (it's already in the model; this is display only).

### Future Considerations — P2 (design so as not to preclude)

- **P2-1 — Assistant Bar adds/checks Shopping** (PRD 03 / Phase 2) — the model + mutation
  functions here must be callable by the assistant, not locked inside the tile's widgets.
- **P2-2 — Live `SHOPPING.md` read/write** (Phase 5) behind the same data-layer interface, with
  the concurrent-write arbitration precondition (D-11) resolved first.
- **P2-3 — Cross-list smarts** (e.g. "you buy milk every week") — explicitly out; no history model
  in v1.

## Success Metrics

Lightweight, definition-of-done flavored (family MVP).

**Leading (verify at Phase 1 close)**
- **Round-trip fidelity: 100%** on the fixture set — every real form parses and serializes with no
  information loss (the headline gate; if this fails, the slice fails).
- **Format compatibility: add/check output is byte-compatible** with the equivalent
  `list-conventions.md` command output, checked by diffing against hand-written expected files.
- **Fail-loud: 100%** — every malformed fixture produces a visible dev error, never a dropped item.
- **Shell untouched:** Shopping integrated with **zero** changes to PRD 01's shell layout/nav
  (PRD 01's own lagging metric, proven here).
- Summary number legible at **~8 ft** (reuses the seed's hallway test).

**Lagging (over the next phases)**
- Phase 2's Assistant Bar can add/check Shopping by calling the **same** model functions, with no
  rewrite of the domain logic — proof the mutation layer was factored right.

## Decisions & Open Questions

**Decided (2026-08-02, at draft — low-stakes, reversible; logged so they're not re-litigated):**
- **[product] Tile key number = combined unchecked count** across Grocery + Household. One number
  is the tile contract (seed §7); the combined "how much do we still need" is the most useful
  single glance signal. Per-list split lives in the glance line and focused view.
- **[product] Add affordance in Phase 1 = a minimal in-tile touch field**, not the Assistant Bar.
  The map puts add/check in Phase 1 (user-owned) and the assistant in Phase 2, so add needs a
  touch path now. Kept intentionally plain so the assistant, not the tile, becomes the nice way to
  add later.
- **[engineering] Parser source = committed fixture copy of `SHOPPING.md`**, not the live file
  (AGENTS.md). The fixture set is expanded to cover every real form for the round-trip test.
- **[engineering] Bought-item note is intentionally dropped on archive**, matching the backend's
  `~~text~~ (list, date)` form. Flagged as *lossless-by-design* (the active→archive transition is
  a defined transform, not a round-trip of the same line) — called out in P0-6 so it isn't later
  mistaken for a parser bug.

**Still open (flag before building the relevant part):**
- **[product] Recently Bought in the focused view — collapsed or just de-emphasized?** Leaning
  de-emphasized-and-visible; final call is a design-mockup question, not a blocker. *(Resolve in
  the Shopping mockup.)*
- **[engineering] Serializer whitespace policy.** The round-trip must preserve the file's blank-line
  rhythm and comment blocks; whether we round-trip byte-exact or normalize to a canonical form
  needs one decision, made when the parser is written. Byte-exact is the safer default given the
  file is shared with other tools. *(Decide at parser implementation; default = byte-exact.)*
- **[product] Does checking an item with a note ever need to keep the note?** Backend drops it; if
  the family ever wants "returned the 2-gallon milk" traceability, revisit. *(Not now — matches
  shipped behavior.)*

## Timeline Considerations

- **This is Phase 1** — the first build after the Phase 0 shell; it depends on PRD 01 being
  implemented (the shell + data-layer interface) and on the design-system seed (tile + tokens).
- **Hard dependency order within the slice:** (a) parser + lossless model + round-trip test
  against the fixture, then (b) summary/focused tile rendering, then (c) add, then (d) check.
  Prove the model before building UI on top of it.
- **Blocks PRD 03 (Assistant Bar):** the assistant is written *against* this domain, so the model
  and its add/check functions should be factored to be callable outside the widget tree (P2-1).
- **No external deadline** (hobby project). Recommended companion artifact: the **Shopping design
  mockup** (Claude Design), honoring the seed tokens, drawn after this PRD locks.

---

## Rejected ideas (don't re-propose without new evidence)

- **Model Shopping as `{section, text, checked}` and move on.** Rejected: it's the thin model the
  scoping-critic already killed for the whole project (C1). It loses note/quantity, provenance, and
  the completion date, and would desync FamilyHub's writes from the file the Morning Briefing reads.
- **Let the tile clear Recently Bought.** Rejected: clearing is the agent's ~7-day sweep (L3); a
  client clear is false validation and races the backend. The tile only reads the archived state.
- **Add via the Assistant Bar in Phase 1.** Rejected as out of phase: the assistant is Phase 2 and
  needs a working domain to control first. Phase 1 add is a plain touch field.
- **Interpret quantities (`2 gallons` → qty:2, unit:gal).** Rejected: no consumer needs structured
  quantity in v1; parse it as an opaque note and stay lossless without over-modeling.
- **Write the live `SHOPPING.md` directly for a "real" feel.** Rejected: violates the seed/fixture
  rule and the Phase 5 concurrent-write precondition (D-11). Fixture only until an explicit go.

### Suggested next artifacts
1. **Shopping design mockup** (Claude Design) — honoring the seed tokens; resolves the open
   focused-view questions visually.
2. **PRD 03 — Assistant Bar (v1, Shopping-only)** — written after this locks, so it specs against a
   concrete domain and its add/check functions.
