# Claude Design prompt — FamilyHub Home Hub (shell)

_Build-ready prompt to hand to Claude Design. Distills the locked
[design-system seed v1.1](design-system-seed.md), [PRD 01](../prds/01-home-hub-prd.md), and the concrete
[`home-hub-surface-mockup.html`](home-hub-surface-mockup.html) into one self-contained paste. The mockup is
the source of truth for layout; this asks Claude Design to bring it to polished, buildable frames.
Companion to the original [design brief](claude-design-brief--home-hub.md). Last updated 2026-08-04._

> **How to use.** Paste everything between the rulers below into Claude Design. It's self-contained —
> Claude Design can't open our files, so the tokens and seed data are inlined. One dial to set first:
> the **fidelity line** near the top (keep it as-is to honor the mockup faithfully; swap the bracketed
> alternative to invite more visual exploration).

---

Design the **Home Hub** — the always-on home screen for **FamilyHub**, a wall-mounted iPad "home hub"
for a family (think Google Nest Hub, but Claude-flavored). It's a **primarily headless assistant with a
face**: you mostly *talk* to it, and the screen is the calm, glanceable backup. This screen is the
**frame, not a feature** — an empty, beautiful, working shell that domain tiles (Shopping, Tasks, Mail)
plug into later. Design the stage, not the play.

**Fidelity:** I have a concrete reference layout already and want you to render it into polished,
production-quality frames — **honor the structure, tokens, and states below faithfully.** [Alternative if
I want exploration instead: "treat the tokens and constraints as fixed, but feel free to push the
composition, warmth, and character further than a literal reading."]

## The one constraint that drives everything
It's read from **6–10 feet away, on a wall, often in a dim room.** That's *why* the type is large, the
contrast is high, and the theme is dark. When in doubt, optimize for "legible across the room," never
"tidy on a laptop 18 inches away."

## Canvas
iPad 10th generation, **landscape, 1180×820 pt** (design at 1180×820). Dark-first ambient theme.
Landscape only. Lay out within iOS safe areas — the iPad has no home button, so a bottom home-indicator
gesture strip sits under the pinned bottom bar; keep touch targets and text clear of it.

## Design tokens (use these exactly — this is a locked system, not a starting point)

**Color — dark theme**
- Page background `#0D0F12` · Tile surface `#15181D` · Raised surface (focused tile / bars) `#1E2229`
- Hairlines / dividers `#333842`
- Text: primary `#E7E9EE` · secondary `#9AA0AB` · muted/hint `#6F757F`
- Domain accents (one per tile, used only for meaning — the icon + the one key number, never decoration):
  Shopping = teal `#5DCAA5` · Tasks = blue `#7F9FF0` · Mail & Packages = amber `#EFB45A`
- Status: error `#E5726B` (muted coral — visible, not screaming) · success `#7FC98A` (leafy green)
- Depth is done with **surface steps** (page → tile → raised), **no drop shadows** — steps read better
  across a room. A 1px `#333842` hairline is the only edge fallback.

**Type — glanceable-first, two weights only (400 regular, 500 medium), sentence case everywhere**
- Hero (clock, any single hero number): **52 / 500**
- Key summary number (a tile's one number): **30 / 500**
- Body (list items in a focused view): 16 / 400
- Label (tile titles, section labels): 14 / 500
- Caption (timestamps, up-close detail): 13 / 400
- No all-caps except a subtle wordmark. Line-height ≈ 1.2 hero/number, ≈ 1.4 body.

**Spacing (base 4px):** 4 · 8 · 12 (default tile padding) · 16 (gaps between tiles) · 20 (screen margin) ·
32 (major zone breaks). Airy over dense — whitespace is a feature on a wall.

**Radii:** tiles 12 · outer screen/device 18 · the bottom Assistant Bar is a full pill (999).

## Layout anatomy — the ambient home (three stacked zones, 20px margin all around)
```
HEADER (~15%)      clock + date (left)          ·    wordmark + weather (right)
   — 32px —
TILE ROW (~55%)    [ Shopping ]  [ Tasks ]  [ Mail & Packages ]
                   3 equal columns, 16px gap. A domain "plugs in" by claiming a column.
   — 32px —
ASSISTANT BAR      full-width rounded pill, pinned to the bottom — the mic/input "front door".
(~15%)             ALWAYS present and visually prominent (not a footer). Reserved even while stubbed.
```
Each domain tile shares one anatomy: **icon + title** (row 1), **one big key number** in the domain
accent (row 2), **what the number means** (row 3, secondary text), and **one glanceable detail line**
(row 4, a short *derived summary* — never a raw list, never full-width text that truncates mid-word at
8 ft). Tiles **summarize**; they never show a full list on the home screen.

## Frames to produce
1. **Ambient home** — the layout above. The hero deliverable. Calm, spacious, minimal, a little warmth.
2. **Assistant Bar — three states** (the bottom pill, shown clearly):
   - *Idle:* mic + prompt text ("Ask me anything — 'add milk…'").
   - *Listening:* active mic (accent ring) + a soft waveform + "Listening…".
   - *Reply:* a success confirmation, e.g. a green check + "**Added milk** to the grocery list".
3. **Home → focused tile** — tapping any tile expands it onto the raised surface (`#1E2229`) with an
   obvious way back ("‹ Home"). Keep this **generic/domain-agnostic** — it's the shell's focus container;
   what fills it is a domain's job. Touch targets big enough to hit without precise aim.
4. **Engaged mode (the conversational takeover)** — when the hub is addressed, the whole surface becomes
   the conversation. Main **conversational canvas** on the left (a short you/hub exchange, plus one
   "intent response card" — e.g. a compact Shopping summary chip the assistant surfaces), and a right
   **glance sidebar** where the three domains demote to small number+label rows. A slim bottom status
   line ("hub is listening · returns on silence"). This is the vision's "conversation *is* the product"
   made literal — design it as the *same feature* as the resting bar, expanded to full canvas, using the
   same tokens (it's a new **layout**, not a new visual language).

## Seed data (use this so screens feel true, not lorem-ipsum)
- Header: **7:14 · Monday, August 3 · 68° clear** · wordmark "FAMILYHUB".
- Shopping: **3 to buy** — glance "Grocery 2 · Household 1".
- Tasks: **4 to do** — glance "Skylight Frame decision".
- Mail & Packages: **2 arriving today** — glance "Package · out for delivery".
- Engaged-mode exchange: you → "Add milk and paper towels"; hub → "Done — milk to grocery, paper towels
  to household." Sidebar then reads Shopping 5, Tasks 4, Mail 2.

## Guardrails — what NOT to design (this is v1 of the *shell*)
- **No deep domain functionality** — tiles summarize; the focused view is a generic container. No editing
  flows, filters, or settings.
- **No working assistant intelligence** — the bar's three states are a visual/interaction shell only. No
  chat threads, no model-output design.
- **Voice is later** — in Engaged mode, the waveform / live-transcription is a *Phase 5* visual; don't
  build the screen around voice being live. Text-first.
- **Don't over-commit two open items:** a *Family Calendar* and dev *System Logs* appear in the engaged
  wireframe but aren't decided — if you show them, keep them clearly muted/secondary (a "pending"
  placeholder), not a committed domain.
- **No accounts, multi-user, or per-person views** — one shared household surface.
- **No live-data / connected-account UI** — it reads seeded data; no auth or sync screens.
- **Don't over-decorate.** On a wall seen from across a room, "too cluttered" is the usual miss. If in
  doubt, quieter and lighter.

## What I'd love back
The 4 frames above, honoring the tokens exactly, at 1180×820 landscape. Where you tighten or extend a
token (e.g. a dedicated "listening/waveform" accent for engaged mode — we don't have one yet), call it
out explicitly so I can fold it back into the design system.
