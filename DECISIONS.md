# FamilyHub — Decisions Log

> **What this is.** An append-only record of *why* we chose what we chose — the lightweight version
> of an ADR (architecture decision record). `PROJECT_MAP.md` holds *what* and *state*; this holds the
> *reasoning*, so nobody has to re-derive a settled call or re-read a whole session to answer "wait,
> why did we do it this way?"
>
> **How to use it.** Append a new row when a notable decision is made; never rewrite history. If a
> later decision overturns an earlier one, add a **new** entry and mark the old one *Superseded by
> D-NN* — don't delete it. A decision reopens only on new evidence (a measurement, a query, a review
> finding), not a new opinion. Durable *technical rules* also get mirrored into `AGENTS.md`.

Format: **ID · date · decision · why · superseded?**

---

### D-01 · 2026-08-02 · Plan one phase ahead + vertical slices (not all PRDs/prototypes up front)
Building the first slice teaches things that rewrite downstream PRDs; writing them all now guarantees
rework and stale anchors. Cheap breadth (one-line feature roles) now; depth one phase ahead.
→ `PROJECT_MAP.md` §7.

### D-02 · 2026-08-02 · "Prototype" means design mockups, not code
Throwaway visual prototypes (Claude Design) are safe to do broadly; per-feature *code* prototypes
before the shell exists would be built against unvalidated assumptions. → chat 2026-08-02.

### D-03 · 2026-08-02 · First vertical slice = Shopping (over Tasks)
Most constrained CRUD, so it validates the pipeline with the least domain complexity. → `PROJECT_MAP.md` §5, §9.

### D-04 · 2026-08-02 · Design-system seed built by extraction, locked v1.0 (then v1.1)
Harvested named tokens from the existing design brief rather than inventing a component library;
the system grows evidence-driven. → `design/design-system-seed.md`.

### D-05 · 2026-08-02 · Seed taste calls (5)
(a) status colors: **error `#E5726B` + success `#7FC98A`**, no warning (avoids clashing with Mail's
amber accent); (b) type: **hero 52 / number 30px** as defaults, confirmed by an ~8 ft hallway test at
Phase 0 close; (c) grid: **3 columns** (6-col is a later, non-free layout change); (d) surface: add
**`bg.raised #1E2229`** for the Assistant Bar + focused tiles; (e) device: **iPad 10th gen, 1180×820pt**.
→ `design/design-system-seed.md` §8.

### D-06 · 2026-08-02 · Home Hub is a two-mode surface (ambient ⇄ engaged)
More faithful to "conversation is the front door" than a persistent footer bar. Shell owns the mode
concept in Phase 0 (engaged stubbed, P0-8); text engaged = Phase 2; voice = Phase 5. Trigger/return:
**hot word on, silence / close-out word off** (voice events are Phase 5, behind the same interface).
→ `design/engaged-mode-notes.md`, PRD 01 P0-8.

### D-07 · 2026-08-02 · Home Hub PRD locked
First PRD, the shell contract every other feature depends on. → `prds/01-home-hub-prd.md`.

### D-08 · 2026-08-02 · Mock data format = hand-authored JSON; markdown parser deferred to Phase 5
Keep Phase 0 small; the typed model is the contract, so a parser can swap in later.
**⚠️ Superseded by D-10.**

### D-09 · 2026-08-02 · Pre-build review via scoping-critic (verified claims → GPT + Gemini)
Verify load-bearing facts against real files first, then hand one identical packet to two model
families for an outside read. Both returned REVISE; all findings accommodated.
→ `reviews/2026-08-02-scoping-critic-returns.md`.

### D-10 · 2026-08-02 · Data model lossless + parser moves up to Phase 1 (supersedes D-08)
Scoping-critic (C1/C3): the verified `SHOPPING.md`/`TASKS.md` are richer than "sections + states"
(provenance, dates, notes/qty, title+context, archive sections), and deferring the parser stranded the
project's highest risk at the end. Now: typed model is **lossless** (round-trip test); **JSON stub in
Phase 0, real Dart parser against `SHOPPING.md` in Phase 1**. → PRD 01 P0-5.

### D-11 · 2026-08-02 · Post-critic corrections (bundled)
Non-voice synthetic trigger for Phase 0 mode-swap test (C2); P0-1 scoped to app launch/resume, physical
kiosk wake → Phase 5 (L2); iOS safe-area rule under the Assistant Bar (L6); corrected the false "6-col
free split" claim (L1); write-ownership — agent owns the ~7-day clear (L3); concurrent-write arbitration
is a live-wiring precondition (L5); tile glance line is a derived summary (L4).
→ `reviews/2026-08-02-scoping-critic-returns.md` closure table.

### D-13 · 2026-08-02 · PRD 02 (Shopping) drafted + its low-stakes calls (bundled)
First-slice PRD written one phase ahead (per D-01). Bundled decisions logged so they aren't
re-litigated: (a) **tile key number = combined unchecked count** across Grocery+Household — one
number is the tile contract (seed §7) and combined is the most useful glance; per-list split lives
in the glance line/focused view. (b) **Phase 1 add affordance = a minimal in-tile touch field**,
not the Assistant Bar — the map puts add/check in Phase 1 (user-owned) and the assistant in Phase 2.
(c) **Parser source = committed fixture copy of `SHOPPING.md`**, never the live file (AGENTS.md).
(d) **Bought-item note is intentionally dropped on archive**, matching the backend's
`~~text~~ (list, date)` form — flagged *lossless-by-design* (a defined active→archive transform, not
a same-line round-trip) so it isn't later mistaken for a parser bug. → `prds/02-shopping-prd.md`.

### D-12 · 2026-08-02 · Tracking workflow adopted
Five files, each one job — `PROJECT_MAP.md` (state), `AGENTS.md` (rules), PRDs/`design/`/`reviews/`
(detail), `DECISIONS.md` (why), `SESSIONS.md` (handoff) — plus a 4-beat ritual (start: read map + AGENTS
+ last session entry; commit early + update the status table in the same commit; log decisions here as
made; end: write a session recap). → `SESSIONS.md`.

### D-14 · 2026-08-03 · Tile-shell vision is canonical; salvage the prior app (don't evolve it)
A prior Flutter app (`reynolds_family_dashboard`) exists as a 5-tab dashboard on a Supabase backend —
a different, earlier product conception. Chosen: the two-mode tile shell + markdown-mirror vision
(PRDs/seed, scoping-critic'd) is canonical; the prior app is **harvested for reusable parts**, not
extended. Why: its most-built piece (the Supabase data layer) points the wrong way for a
conversation-first, markdown-mirroring wall hub, while its scaffold/patterns/`Agent` bar are reusable —
net cheaper and cleaner than either greenfield or evolve. → `SALVAGE-AUDIT.md`, `PROJECT_MAP.md` §5–§6a.

### D-15 · 2026-08-03 · Shelve Supabase; mirror the markdown world
The data layer mirrors `SHOPPING.md`/`TASKS.md` (§3), not a separate Postgres. A second datastore
writing household state duplicates the markdown world and would collide with the existing automations
(the L5 live-wiring concurrency hazard). `supabase_flutter` + repository/service/`supabase_migration.sql`
are shelved; removal is part of the Phase-0 reshape, flagged (not silent cleanup). → `PROJECT_MAP.md` §3, §8.

### D-16 · 2026-08-03 · Repo consolidation — FamilyHub repo is canonical
Planning work had been landing in a mislocated `~/Documents/Claude/Projects/Reynolds Household` git repo
(`reynolds-household`), separate from the intended `~/projects/reynolds-household/` tree and its
`FamilyHub` code repo. Consolidated: planning docs imported into `~/projects/reynolds-household/FamilyHub/`
(GitHub `FamilyHub`, branch `planning-docs-consolidation`); the Documents copy is pending retirement after
a household-level audit (Wave 2). Cowork to be re-pointed to `~/projects`. The `~/Documents` path also
broke the Cowork sandbox's git (iCloud eviction); `~/projects` avoids it. → `CONSOLIDATION-PLAN.md`.


### D-17 · 2026-08-03 · PRD 02 locked + first Shopping surface mockup (Recently-Bought display resolved)
Read-through of PRD 02 held up (internally consistent; grounded in the seed tokens and
`family-assistant/list-conventions.md`; remaining opens are deliberately downstream), so it is **locked**.
Drafted the first **surface mockup** (`design/shopping-surface-mockup.html`) on seed v1.1 tokens: ambient
home with Shopping in the 3-tile shell (P0-8), focused list view with inline add (P0-5) + check→archive
(P0-6), and empty/error tiles (P0-7). **Resolved PRD 02 open design question — Recently Bought =
de-emphasized *and* collapsed** (muted, struck-through summary under a disclosure caret, read-only /
agent-cleared), reinforcing L3 (client never clears). Fallback if too buried at 8 ft:
de-emphasized-but-always-expanded (one-line change). *(Authored in the mislocated Documents copy as
"D-14"; renumbered to D-17 on migration into canonical — see D-16.)*
→ `prds/02-shopping-prd.md`, `design/shopping-surface-mockup.html`.

### D-18 · 2026-08-03 · Home Hub build scope (shell-first) + typeface (Helvetica Neue)
The finalized Claude Design (imported byte-exact into `design/`) evolved — Matt-driven, over 3 turns —
into a **voice presence-sphere** assistant with live audio-reactive states (listening/speaking/
confirmed/failed/resting). That's Phase-5-forward vs. PRD 01's text-first Phase 0. **Scope call for the
first build: the static Phase-0 shell first** — ambient home (`1a`) + generic focus container (`1c`):
header, 3-tile grid, Assistant Bar pill — with the **sphere / engaged mode / voice deferred to a later
layer**. Why: keeps the roadmap's small-steps order (shell before domains before assistant) and doesn't
pull Phase-5 work forward, while the sphere direction is *banked* (new tokens minted so it's ready).
**Typeface: Inter → Helvetica Neue** (Matt's call — wall legibility; a system face on iPad, so no bundled
asset). New tokens `#6C7BF0`/`#9B7BF0`/`#08090B` folded into **seed v1.2**.
→ `design/claude-design-import--home-hub.md`, `reynolds_family_dashboard/lib/theme/hub_tokens.dart`,
`reynolds_family_dashboard/lib/features/home_hub/`.
