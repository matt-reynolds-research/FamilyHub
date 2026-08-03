# FamilyHub / Reynolds Household — Repo Consolidation Plan

_Drafted 2026-08-03 · Status: **awaiting Matt's go on the gating decision** · Nothing has been moved or deleted yet._

## Why this exists

Two divergent trees got created and drifted apart. This plan consolidates into the intended
location (`~/projects/reynolds-household/`) **without losing work and without touching the live
assistant runtime.** It is deliberately sequenced safe → destructive, and the destructive last
step (retiring the Documents copy) does not happen until everything is verified.

## The two trees (as they are today)

**A. Documents copy — where Cowork was mistakenly pointed**
`~/Documents/Claude/Projects/Reynolds Household` — git repo **`reynolds-household`** (branch
`master`), remote `github.com/matt-reynolds-research/reynolds-household.git`.
**15 commits ahead of origin — never pushed.** Holds the recent (Aug-2) FamilyHub **planning**
work and a household-level `family-assistant/` with some dev work (`calendar_client/`,
`applied-changes/`).

**B. Intended tree — where things should live**
`~/projects/reynolds-household/` — **root is NOT git-tracked.** Contains the **live assistant
runtime** (`family-assistant/` with `watcher.log`/`state.json`, updated today), `SHOPPING.md`,
`TASKS.md`, `docs/`, `_archive-2026-07-25/`, and nested inside it:
`~/projects/reynolds-household/FamilyHub/` — git repo **`FamilyHub`** (branch `main`), remote
`github.com/matt-reynolds-research/FamilyHub.git` — the **actual Flutter app**
(`reynolds_family_dashboard/`, `scripts/`, `supabase_migration.sql`, `.github/` CI), plus its own
older orientation docs (`PROJECT_MAP.md` Jul-21, `AGENTS.md` Jul-22, `NEXT-STEPS.md`).

## File-by-file disposition

| Item | In A (Documents) | In B (intended) | Disposition |
|------|------------------|-----------------|-------------|
| `FamilyHub/prds/` (01, 02) | ✅ | ❌ | **Copy over** — net-new, no conflict |
| `FamilyHub/design/` (seed, brief, engaged notes + wireframe) | ✅ | ❌ | **Copy over** — net-new |
| `FamilyHub/reviews/` (scoping-critic packets) | ✅ | ❌ | **Copy over** — net-new |
| `FamilyHub/DECISIONS.md`, `SESSIONS.md` | ✅ | ❌ | **Copy over** — net-new |
| `FamilyHub/PROJECT_MAP.md` | ✅ new north-star | ✅ old build-plan | **Reconcile** (see below) — *decision* |
| `AGENTS.md` | ✅ household/calendar rules (root) | ✅ FamilyHub build rules (in FamilyHub/) | **Reconcile** — *decision* |
| `family-assistant/`, `SHOPPING.md`, `TASKS.md`, `docs/` | ✅ (has calendar_client, applied-changes) | ✅ **LIVE** | **Do not overwrite B.** Audit A for unique dev work (Wave 2) |
| Flutter app, CI, scripts, supabase | ❌ | ✅ | Already home; leave as-is |

## The one gating decision (need Matt)

**Where should the FamilyHub planning docs live, and what is the git structure of the destination
root?** Two clean options:

- **Option 1 — Planning docs go into the `FamilyHub` app repo.** Copy `prds/`, `design/`,
  `reviews/`, `DECISIONS.md`, `SESSIONS.md`, and the reconciled `PROJECT_MAP.md` into
  `~/projects/reynolds-household/FamilyHub/` and commit them to the `FamilyHub` repo (branch
  `main`). Planning + code live together, one repo, one history. *Simplest; recommended.*
- **Option 2 — Make the household root a repo.** Turn `~/projects/reynolds-household/` into the
  `reynolds-household` git repo (it matches that name and scope — family-assistant, lists, docs,
  with `FamilyHub/` nested as its own repo). Planning docs live at the household level. Cleaner
  separation of "household" vs "the app," but more moving parts (nested repos, `.gitignore` for the
  nested one).

This decides where files land and which GitHub repo the planning history attaches to. Everything
else below is mechanical once this is set.

## Reconciliation notes (my proposed defaults, reviewable)

- **PROJECT_MAP.md:** adopt the new north-star as the base, but **fix its factual error** — it says
  "nothing built, no scaffold," which is false (the `FamilyHub` app already has a Flutter scaffold,
  CI, and a Supabase migration). Fold the real "what exists" inventory from the old Jul-21 build-plan
  into §6/§8 so the map matches reality. This is exactly the "if reality and this file disagree, fix
  it" rule the map states about itself.
- **AGENTS.md:** keep both scopes but stop duplicating — household/calendar rules at the household
  level, FamilyHub build rules in the app repo, each linking the other. Final placement follows the
  Option 1/2 choice.

## Safe execution sequence (after the decision)

1. **Backup first (zero-risk):** `git bundle` the Documents `reynolds-household` repo to a single
   file (full history, no remote needed) and stash it outside both trees. Nothing is committed,
   pushed, moved, or deleted by this.
2. **Copy the net-new planning artifacts** into the chosen destination. Copy only — originals stay
   put until the end.
3. **Reconcile** `PROJECT_MAP.md` and `AGENTS.md` per the notes above; you review the diffs.
4. **Commit** in the destination repo. **Push** is a separate, explicit yes (it publishes to GitHub).
5. **Re-point Cowork** to `~/projects/reynolds-household` (also fixes the sandbox git failures — that
   folder isn't in the iCloud-synced `~/Documents` path that breaks the bridge).
6. **Verify** the destination has everything and builds/reads correctly.
7. **Wave 2 — household audit:** compare the Documents `family-assistant/` (`calendar_client/`,
   `applied-changes/`) and `docs/` against the live tree; migrate anything unique. **Only after this
   confirms nothing is stranded** do we retire the Documents copy.
8. ~~**Retire the Documents copy**~~ — **SUPERSEDED by `WAVE-2-AUDIT.md` (2026-08-03): do NOT retire.**
   The audit found DOC is the home of the calendar-maintenance subsystem + household governance files
   (not just misfiled planning); retiring it would strand real work. Keep it; reframe it as the
   household/calendar repo. Only the FamilyHub planning was misfiled, and that consolidation is done.

## What will NOT happen without a further explicit go
- No overwriting the live `~/projects/reynolds-household/family-assistant/`, `SHOPPING.md`, `TASKS.md`.
- No push to any GitHub remote.
- No deletion/retirement of the Documents copy.
