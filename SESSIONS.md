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

## 2026-08-04 (session 5, Cowork) — Home Hub design import + first Flutter shell

**What changed**
- **Imported the finalized Home Hub design** from Claude Design, byte-exact, into `design/`:
  `FamilyHub Home Hub.dc.html` (50,978 B) + `support.js` (69,150 B — the generic dc-runtime; the sphere
  logic is a `<script>` inside the `.dc.html`). Retrieval was non-trivial (auth-gated project): pulled via
  the browser's authenticated session through a `get_page_text` → host-file → Desktop Commander decode
  pipeline. Wrote `design/claude-design-import--home-hub.md` (8 frames across 3 turns; token table; drift review).
- **Drift flagged + decided (D-18).** The design evolved (Matt-driven) into a voice **presence-sphere**
  assistant — Phase-5-forward. Scope call: **build the Phase-0 static shell first**, defer sphere/engaged/voice.
  Typeface **Inter → Helvetica Neue**.
- **Built the first Flutter increment** (analyzer-clean on new code; widget-tested):
  `lib/theme/hub_tokens.dart` (seed **v1.2**: dark tokens + Helvetica Neue + new `#6C7BF0`/`#9B7BF0`/`#08090B`)
  and `lib/features/home_hub/` (ambient home: header w/ live clock, 3-tile seeded grid matching frame `1a`,
  Assistant Bar pill, generic focus container). Repointed `app.dart` to the new dark shell.
  `test/ambient_home_screen_test.dart` passes (render + tile→focus→back).
- Seed doc → **v1.2** (font + new tokens folded back). `PROJECT_MAP` §6 Home Hub → "shell scaffolded".

**Commits / not pushed** — `docs/import-home-hub-design` branch: `221e344` (design import) + a follow-up
commit for the shell increment. **Not pushed** — consistent with the repo's standing "committed, not
pushed" posture; pushing / opening a PR is a separate explicit yes.

**What is next**
1. **Push/PR decision** for the accumulated branches (`session-3-prd02-lock`, `docs/import-home-hub-design`).
2. **Phase-0 prune follow-up:** remove the prior 5-tab shell + Supabase (`supabase_flutter`, service/repo/
   `supabase_migration.sql`), retire the light `AppColors`/`AppTheme`, resolve the `.env` asset friction.
3. **Phase 1** — real `SHOPPING.md` parser + Shopping tile behind the shell.

**Open** — the presence sphere / engaged mode is *banked* (tokens minted), not built; it's a Phase-2/5 layer.

---

## 2026-08-04 (session 4, Cowork) — Home Hub (shell) surface mockup

**What changed**
- Drafted the **Home Hub surface mockup**: `design/home-hub-surface-mockup.html`, on seed v1.1 tokens
  (same verbatim token block as the Shopping mockup, so the two surfaces match by construction).
- Deliberately scoped to picture the **shell itself**, not a domain — the piece the Shopping mockup
  couldn't show. Four frames, each mapped to a PRD 01 P0: canonical ambient home + header (P0-1/2/3/4),
  **Assistant Bar three states** idle/listening/reply (P0-6), **generic home⇄focus** nav (P0-7), and the
  **ambient⇄engaged mode takeover** (P0-8). Tile empty/error states are *not* re-drawn — they already
  live in the Shopping mockup; a pointer is left instead of a duplicate (avoids drift).
- **Engaged mode drawn text-first** (Phase 2), with the voice waveform / live-transcription strip tagged
  **Phase 5** so nothing implies voice in Phase 0. The two engaged-mode open flags from the wireframe —
  **Calendar** (not one of the 3 tile domains) and dev **System Logs** — are surfaced *muted / "pending
  domain decision"* and *dev-only*, flagged not committed (they belong to the Assistant Bar PRD).
- Updated `PROJECT_MAP.md` (§6 Home Hub status → "PRD locked · mockup drafted" + top status line).
- Wrote a **build-ready Claude Design prompt**: `design/claude-design-prompt--home-hub-shell.md` — a
  self-contained paste (seed tokens + seed data inlined) asking for the 4 frames, with a **fidelity dial**
  (render-faithfully vs. explore) and the two open flags (Calendar/System-Logs) held loose. Matt is taking
  this to Claude Design and starting to build the Phase-0 shell from its output.

**Session checkpoint (2026-08-04 close):** clean stop. Working tree clean; three commits on
`session-3-prd02-lock` (`81c265c` mockup + doc updates, `1f4cc13` Claude Design prompt) on top of the
session-3 checkpoint. Nothing pushed. *Sandbox git note: this `~/projects` copy has a lock-cleanup quirk —
the sandbox can't `unlink` inside `.git`, so `index.lock`/`HEAD.lock` must be `mv`'d aside before a commit
(git writes via rename, which works). Distinct from the iCloud EDEADLK on the Documents copy. If a commit
says "another git process is running," move the stale `.lock` aside and retry.*

**Why now (design ordering)** — Matt's steer was "don't let design get skipped, but at the correct time."
The Shopping surface was mocked before the *shell* it sits in had its own full mockup; drawing the Home
Hub mockup back-fills the foundation and lets the Shopping tile be checked against the real grid. Reversible
planning work — no code, no publishing.

**Decisions** — no new numbered decision. One design stance worth noting (candidate for the Assistant Bar
PRD, not locked here): engaged-mode glance sidebar shows the **demoted three domains**; Calendar stays a
muted placeholder until the "new domain vs. surface backend calendar" question is decided.

**What is next**
1. **Still the standing open loop:** branch `session-3-prd02-lock` (now also carrying this mockup +
   doc updates) is committed but **not pushed**. Decide its fate — merge to `main` or open a PR
   (pushing is an explicit, separate yes). `main` still untouched.
2. **Build the Phase-0 shell** from the Claude Design output (Matt driving) — reshape the prior tab
   shell into the tile grid + ambient⇄engaged mode per PROJECT_MAP §5 Phase 0.
3. Optional: **PRD 03 — Assistant Bar (v1, Shopping-only)**, now with a locked domain and two surface
   mockups to spec against.

**Open questions carried forward** — engaged-mode Calendar/System-Logs (deferred to Assistant Bar PRD);
listening/waveform accent token (reused `accent.tasks` as a stand-in in the mockup; mint a real token when
the voice UI is built — seed §10 anticipates it). Serializer whitespace policy still deferred to the parser.

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
still pointed there; its `.git` deadlocks in the sandbox, iCloud EDEADLK). Migrated here into canonical per
D-16, on branch **`session-3-prd02-lock`** (committed, **not pushed**; `main` untouched), decision renumbered
"D-14"→**D-17** to avoid colliding with D-14/15/16.

**Cowork folder situation (resolved as far as it can be):** the `~/projects/reynolds-household` folder is now
a connected *context* folder and git works there. BUT the old `~/Documents/...Reynolds Household` folder is the
Cowork project's **anchor** and **cannot be disconnected** — so the plan to "remove the old folder" isn't
possible. Mitigations in place: (a) all FamilyHub work now targets `~/projects/...` explicitly; (b) the Cowork
project **Instructions** were given a new `## Repo & working folder` section pointing future sessions here
(pasted by Matt; not independently verified — the Instructions box syncs server-side and isn't readable from
the sandbox). **So: trust `~/projects/reynolds-household/FamilyHub` as canonical; never write FamilyHub work to
the Documents copy.** The Documents copy still legitimately owns the calendar-maintenance subsystem.

**Session checkpoint (2026-08-03 eve):** stopping here to resume fresh. Open loop = the unpushed branch below.

**What is next**
1. **Decide the branch's fate:** review `session-3-prd02-lock` and either merge to `main` or open a PR
   (pushing is an explicit, separate yes). Nothing published yet.
2. Optional: **Home Hub surface mockup** (PRD 01 locked; brief + engaged wireframe exist).
3. **PRD 03 — Assistant Bar (v1, Shopping-only)**, against the now-locked domain.

**Open questions carried forward** — serializer whitespace policy (default byte-exact), deferred to parser
implementation. Recently-Bought display now resolved (D-17). Cowork Instructions edit unverified (low-stakes).

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
