# Wave-2 — Household divergence audit

_2026-08-03 · Read-only compare of `~/Documents/Claude/Projects/Reynolds Household` (the `reynolds-household` git repo, "DOC") vs. `~/projects/reynolds-household` (the live tree, "PROJ"), excluding `FamilyHub/` (already consolidated) and `.git`._

## Headline: **do not retire the Documents copy.**

The consolidation assumed DOC was a misplaced copy holding only FamilyHub planning. That's wrong. DOC is the **home of a whole calendar-maintenance workstream plus the household governance files**, and PROJ does not contain them. Retiring DOC would strand real, recent work. Only the FamilyHub *planning* docs were genuinely misfiled — and those are now consolidated into the `FamilyHub` repo (done). Nothing further should be deleted.

## What is UNIQUE to the Documents copy (would be lost if retired)

**1. The calendar-maintenance subsystem** — substantial, recent (Jul 30–Aug 2), and referenced by `AGENTS.md` as sources of truth:
- `family-assistant/calendar_client/` — a **20-file Python package** (auth, client, conflicts, dedup, normalize, adoption, shadow-run… + unit tests).
- `family-assistant/applied-changes/` (12 files), `family-assistant/shadow-reports/` (23 files), `family-assistant/deleted-events/` — the run history / audit trail.
- `family-assistant/calendar-conventions.md` (the authority `AGENTS.md` names), `docs/calendar-maintenance-scoping.md`, `docs/critic-packet.md`, `docs/critic-returns.md`.
- `family-assistant/com.reynolds.family-assistant.plist` (launchd job), `family-assistant/list-threads.py`, `family-assistant/watcher-launchd-err.log`.

**2. Household governance / misc files** (DOC root, absent from PROJ root):
- `AGENTS.md` (the household + calendar rules — distinct from `FamilyHub/AGENTS.md`), `PROJECT_INSTRUCTIONS.md`, `SKILL.md`, `README.md`, `Reynolds_Family_Budget_Q1_2026.xlsx`, `gmail-filter-archive-flood.xml`, `family-todo-text-capture.PROPOSED.md`.

**3. A live secret** — `family-assistant/.secrets/familyhub-sa.json` (Google service-account key). Status: **not git-tracked** (correctly gitignored, mode `600`) — no leak. PROJ has no copy. If DOC is ever removed, the key is reissuable per `AGENTS.md` (it's non-expiring by design); don't copy it around, reissue if needed.

## What is UNIQUE to the live tree (PROJ has, DOC doesn't)

The **actually-running** assistant: `family-assistant/tools/` (Swift `famcal` + `ekprobe` binaries + `build.sh`), `family-assistant/voice.log`, `family-assistant/SETUP.md`, `docs/calendar-cleanup-2026-07-25.md`, a `check_triggers.py.bak`. PROJ is where the watcher/automations run — so it is **not** a superset of DOC; each tree has unique content.

## Shared but diverged

`SHOPPING.md` and `TASKS.md` differ between the trees (PROJ is the live-runtime home, so treat PROJ's as canonical for the running household — confirm before relying on either for the PRD-02 fixture). `watcher.log` / `state.json` exist in both and diverge (runtime state).

## Interpretation

There are really **two workstreams** wearing similar names:
- **FamilyHub** (the iPad app + its planning) → canonical in the `FamilyHub` repo / `~/projects/reynolds-household/FamilyHub/`. Consolidation **complete**.
- **The household assistant + calendar-maintenance** → lives in the DOC `reynolds-household` repo (dev) and the PROJ live tree (runtime). This is a *separate effort*, explicitly out of FamilyHub's map (PROJECT_MAP §3), and it is **not** finished consolidating — the calendar_client dev work (DOC) and the running tools (PROJ) are split across the two trees.

## Recommendations (no action taken — these are for Matt)

1. **Keep the Documents `reynolds-household` repo.** Reframe it as the household + calendar-maintenance repo, not a stale copy. This **supersedes step 8 ("retire the Documents copy") of `CONSOLIDATION-PLAN.md`** — do not retire it.
2. **FamilyHub duplication:** the `FamilyHub/` planning docs now exist in both the DOC repo and the canonical `FamilyHub` repo. The `FamilyHub` repo is canonical; optionally delete `FamilyHub/` from the DOC repo later to prevent drift *(low priority, flagged — not done)*.
3. **Calendar-maintenance is its own consolidation problem.** The dev package (DOC) and the running tools (PROJ) are split. Reconciling them touches shipped assistant behavior and should be scoped as its own effort, with its own careful plan — not folded into the FamilyHub work.
4. **Sandbox-git breakage:** re-pointing Cowork to `~/projects` fixes it for *FamilyHub*. If you also want Cowork to work on the calendar/household repo without the iCloud git failures, that DOC repo should be relocated out of `~/Documents` too — a separate step.
5. **Secret:** leave `familyhub-sa.json` as-is (safe). Reissue rather than copy if the calendar_client is ever run from another tree.
