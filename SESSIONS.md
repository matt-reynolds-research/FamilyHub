# FamilyHub — Session Log

> **What this is.** An append-only handoff log — one short entry per working session so each session
> is *self-contained* and the next one (or the next AI tool) starts by reading the latest entry
> instead of replaying a long chat. This is the antidote to context loss: the conversation is the
> workspace; **this** is the memory.
>
> **How to use it.** Newest entry on top. Each entry: what changed, decisions, what's next, open
> questions. Keep it short — links to the real docs, not a re-transcription.
>
> **To resume FamilyHub in a fresh session, read in order:** `PROJECT_MAP.md` → `AGENTS.md` →
> the top entry here → `DECISIONS.md` tail.

---

## 2026-08-03 (session 3, Cowork) — PRD 02 locked + first Shopping surface mockup

**What changed**
- Locked **PRD 02 — Shopping** after a read-through (Draft→Locked).
- Drafted the first **surface mockup**: `design/shopping-surface-mockup.html` on seed v1.1 tokens — ambient
  home with Shopping in the 3-tile shell (P0-8), focused list view with inline add (P0-5) + check→archive
  (P0-6), empty/error tiles (P0-7).
- **Resolved PRD 02 open design question:** Recently Bought = de-emphasized *and* collapsed (read-only,
  agent-cleared). Logged **D-17**. Updated `PROJECT_MAP.md` (§6/§7 + status line).

**Migration note** — this work was originally done in the mislocated `~/Documents/...` copy (Cowork was
still pointed there; its `.git` deadlocks in the sandbox). Migrated here into canonical per D-16, on branch
`session-3-prd02-lock`, decision renumbered "D-14"→**D-17** to avoid colliding with D-14/15/16.
**Action still needed: re-point Cowork to `~/projects/reynolds-household/FamilyHub`** so future sessions land here.

**What is next**
1. **Re-point Cowork** (Matt) → then this branch can be reviewed/merged normally.
2. Optional: **Home Hub surface mockup** (PRD 01 locked; brief + engaged wireframe exist).
3. **PRD 03 — Assistant Bar (v1, Shopping-only)**, against the now-locked domain.

**Open questions carried forward** — serializer whitespace policy (default byte-exact), deferred to parser
implementation. Recently-Bought display now resolved (D-17).

---

## 2026-08-03 — Repo untangle + salvage audit + PROJECT_MAP reconciled

**What changed**
- Found the git repo Cowork was editing (`~/Documents/Claude/Projects/Reynolds Household`, GitHub
  `reynolds-household`) is **separate from the intended tree** (`~/projects/reynolds-household/`, which
  holds the live assistant runtime and the `FamilyHub` code repo). Consolidated per **D-16**: imported
  the planning docs (PRDs, design, reviews, DECISIONS, SESSIONS) into `~/projects/reynolds-household/FamilyHub/`
  on branch `planning-docs-consolidation` (commits `68945fc`, `1237b5c`, + this).
- Ran a **salvage audit** of the prior Flutter app → [`SALVAGE-AUDIT.md`](SALVAGE-AUDIT.md): carry the
  project/CI/Riverpod patterns/theme-structure/`Agent` bar; adapt models + repo interface; shelve Supabase + tab nav.
- **Reconciled `PROJECT_MAP.md`** to reality (D-14/D-15): tile-shell vision canonical, prior app harvested
  not evolved, Supabase shelved, Phase 0 reframed greenfield → reshape. Corrected the false "nothing built."

**Decisions** — D-14 (tile-shell canonical + salvage), D-15 (shelve Supabase / mirror markdown), D-16 (repo consolidation).

**State**
- Phase 0 planning. Seed ✅ v1.1 · Home Hub PRD ✅ locked · Shopping PRD 📄 draft · prior app audited.
- Canonical repo: `~/projects/reynolds-household/FamilyHub` (branch `planning-docs-consolidation`, unpushed).
  Planning-file backup at `~/reynolds-household-planning-backup-20260803-063536/`.
- ⚠️ The `~/Documents` copy still exists (pending Wave-2 household audit before retirement); its 15 planning
  commits remain local-only there.

**What's next**
1. Re-point Cowork to `~/projects/reynolds-household`; push/PR the `planning-docs-consolidation` branch.
2. Wave-2 audit: reconcile household-level divergence (`family-assistant/`, `AGENTS.md`, lists) before retiring the Documents copy.
3. Resume the build: Phase 0 reshape (tile grid + retheme + markdown repo), toward the Shopping slice.

**Open questions carried forward** — assistant brains ($/model; `Agent` uses Gemini); live-backend concurrency
(Phase 5); Recently-Bought display + serializer whitespace (parser time).

---

## 2026-08-02 (session 2) — PRD 02 (Shopping) drafted

**What changed**
- Wrote **PRD 02 — Shopping** (`prds/02-shopping-prd.md`, draft) — the first vertical slice. It owns
  the real **`SHOPPING.md` parser + lossless typed model** (per D-10) and specs the four tile states,
  touch **add/check**, and byte-compatibility with the shipped text assistant
  (`family-assistant/list-conventions.md`).
- Verified the PRD against sources: every real markdown form (bare, parenthetical note, em-dash note,
  bought `~~text~~ (list, date)`, empty section, comment blocks, preamble) is covered by the P0-1
  round-trip fixture; add/check output matches `list-conventions.md` GROCERY/SHOP/BOUGHT_* exactly.
- Updated `PROJECT_MAP.md` (§6 Shopping tile → *PRD draft*; §7 #2 marked drafted; status line) and
  logged **D-13** (the PRD's bundled low-stakes calls).

**Decisions** — D-13. Headline: combined unchecked count on the tile; Phase-1 add is a plain touch
field (not the assistant); parser reads a committed fixture; bought-item note-drop is lossless-by-design.

**State**
- Phase 0 planning. Seed ✅ v1.1 · Home Hub PRD ✅ locked · **Shopping PRD 📄 draft** · nothing built.
- ⚠️ **Git note:** the bash sandbox mount was bus-erroring / deadlocking on `.git` this session, so the
  session's changes may be **uncommitted**. Verify `git status`/`git log` in an interactive shell and
  commit if needed (files themselves are intact — the errors were mount-level, not repo corruption).

**What's next**
1. Lock PRD 02 (a read-through is all that's pending) → then the **Shopping design mockup** (Claude Design).
2. Then **PRD 03 — Assistant Bar (v1, Shopping-only)**, written against this concrete domain.
3. Still blocking the scaffold (not the PRDs): **repo location** decision (`PROJECT_MAP.md` §9.1).

**Open questions carried forward** — same as session 1, plus: Recently-Bought display (collapsed vs.
de-emphasized) and serializer whitespace policy (default byte-exact), both resolved at parser/mockup time.

---

## 2026-08-02 — Phase 0 planning: seed + Home Hub PRD locked, external review passed

**What changed**
- Built and locked the **design-system seed** (`design/design-system-seed.md`, v1.1) — named tokens
  (color/type/spacing/radii), the 3-zone tile grid, one reusable tile with four states.
- Locked **PRD 01 — Home Hub** (`prds/01-home-hub-prd.md`), including the new **two-mode
  (ambient ⇄ engaged)** model (P0-8) + `design/engaged-mode-notes.md` + wireframe.
- Ran the **scoping-critic** pass: verified claims against real files/specs, got GPT + Gemini reads
  (both **REVISE**), accommodated all 9 findings. Full record in
  `reviews/2026-08-02-scoping-critic-returns.md`.
- Stood up this tracking workflow: `DECISIONS.md` + `SESSIONS.md`.

**Decisions** — see `DECISIONS.md` D-01 … D-12. Headline ones: one-phase-ahead planning (D-01),
Shopping first (D-03), two-mode surface (D-06), and the big post-review change — **data model is
lossless and the markdown parser moves up to Phase 1** (D-10, supersedes D-08).

**State**
- Phase 0 planning. Seed ✅ v1.1 · Home Hub PRD ✅ locked · nothing built yet (no code, no scaffold).
- Git: all FamilyHub work committed (latest: `c9f7f28`, plus the workflow commit).

**What's next**
1. **PRD 02 — Shopping** — the first vertical slice; now also owns the real `SHOPPING.md` parser and
   the lossless model (per D-10). *Recommended next artifact.*
2. Then: Home Hub + Shopping **design mockups** (Claude Design).
3. Blocking the scaffold (not the PRDs): **repo location** decision (`PROJECT_MAP.md` §9.1) — where the
   Flutter code repo lives, fresh git repo or not. Matt's call.

**Open questions carried forward**
- Mount + viewing distance (final type-size tuning; measured once the wall spot is chosen).
- Always-on / kiosk mechanism (Phase 5).
- Calendar in engaged mode: new domain or surface the backend calendar? (Assistant Bar PRD.)
- Live-backend concurrency arbitration (Phase 5 precondition, per D-11).
