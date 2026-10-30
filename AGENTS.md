# AGENTS.md — FamilyHub

> **North star: PRD 00.** FamilyHub is the Surfaces track of the one Reynolds household plan,
> `docs/PRD-00-household-north-star.md` in `reynolds-household-world` (ledger D81). **Before planning
> or building, read PRD 00 (its Surfaces track and Order sections) and the OPEN list of the drift
> ledger** (`docs/active/planning/2026-10-09-HOUSEHOLD-AWARE-drift-ledger.md`); in the household
> folder they are at `../docs/`. In a clone without that folder, fetch them, e.g.
> `gh api repos/matt-reynolds-research/reynolds-household-world/contents/docs/PRD-00-household-north-star.md -H 'Accept: application/vnd.github.raw'`. **If you can't read them, stop and say so.** Decisions are D-numbers in that ledger;
> this repo's `DECISIONS.md` and `SESSIONS.md` are frozen history.

Durable rules for any AI tool working in this repo (Claude, Gemini/Antigravity, etc.).
Read this first every session. It's the portable companion to the Cowork project
instructions — if you're building here, these are the rules that apply.

## What this is
FamilyHub is a **hobby project**: a Flutter iPad "home hub" (Nest Hub-style) built for and
finetuned to the Reynolds family. It's a place to experiment and stay sharp on AI-assisted
development — what gets built doesn't have to be practical — but still aim for clean,
high-fidelity work. What exists and the feature detail is
**`PROJECT_MAP.md`**; the plan and order are PRD 00 (above).

## System boundaries — is this FamilyHub, or the Family Assistant? (read first)
There is **one World** and there are **faces** on it (PRD 00 v2, D81). The World is
**Reynolds-World** (the Supabase world model: people, modes, the event log, policies,
collisions) plus the **family calendar**, which the PC reads and writes through `gcal`
(Google's API replaced `famcal` in H1). The markdown lists are no longer the World:
lists are Sara's, and Phase 3 is paused (D75). **FamilyHub is a *surface*** — the iPad
display, Phase 5 ("the family's day"). Surfaces read the world and the calendar and
never keep their own copy; how FamilyHub reads the calendar is Phase 5's first
decision. The **Family Assistant** (`../family-assistant/`, the headless iMessage
brain, hosted on the Linux PC) is a *different layer*. FamilyHub's "Assistant Bar"
(FH2, Aug 2026 seeded prototype — history) is a face onto that brain, never a new one.

**The routing test — before you build, ask:**
- Changes the **World** (data, calendar, automations, the assistant's brain/behavior)
  → **`../family-assistant/`**, not here.
- Changes a **Surface** (how something looks/feels on the iPad) → **here, `FamilyHub/`.**

Full picture: **`../SYSTEM-MAP.md`**. (Example: the Aug-2026 "Hawaii" trip-conflict
fix was a World change — it lived in `famcal`, never in this repo.)

## Who you're working with
Matt — a Senior UX Researcher, comfortable with AI tools but still growing the deeper
engineering craft. Pitch explanations at "capable practitioner still learning the stack":
skip the 101 basics, explain non-obvious technical decisions, and name concepts so he can
go deeper. This project runs **low-touch** — Matt's main energy is elsewhere, so default to
making progress and summarizing async. Reserve his attention for irreversible actions,
spending money, security/privacy tradeoffs, or a real fork in direction.

## Tech stack (authoritative version = `reynolds_family_dashboard/pubspec.yaml`)
- Flutter (Dart), app lives in **`reynolds_family_dashboard/`**.
- State: Riverpod. **No backend datastore today** — the app runs on **seeded mock data** (FH0–FH3).
  D-15 ("mirror the markdown world") is reversed: Phase 5 reads Reynolds-World (Supabase, with
  Supabase Auth and read-only policies) and the calendar; build UI against world-model-shaped seeded
  data until then (PRD 00 Order step 3). **Supabase was removed in the Phase-0 prune** (2026-08-03), along with
  `flutter_dotenv`, `google_fonts`, and `google_generative_ai`.
- Assistant Bar (FH2, history): lives in the app's `lib/features/assistant/` and uses a deterministic,
  Shopping-only local intent adapter. The old **`Agent/`** Gemini prototype remains as historical
  reference but is not an app dependency; it must not become a second household brain.
- Design-system tokens under `lib/theme/hub_tokens.dart` (seed v1.2, Helvetica Neue). Widget tests in `test/`.
- No secrets are needed by the app today (dotenv removed with Supabase). Any future keys live in
  `reynolds_family_dashboard/.env` — git-ignored, never committed; `.env.example` documents them.

## Repo layout
- `reynolds_family_dashboard/lib/` — app source: `main.dart`, `app.dart`, `theme/hub_tokens.dart`, and
  `features/home_hub/` (the ambient shell). The prior 5-tab shell, Supabase service/repo, old
  models/providers, and the light theme were removed in the Phase-0 prune.
- `reynolds_family_dashboard/lib/domain/<domain>/` — the household data layer, **UI-free**: model,
  parser/serializer, mutations, repository. `shopping/` is the reference implementation.
- `reynolds_family_dashboard/assets/fixtures/` — committed **seed** copies of the household markdown
  files. Development reads these, never the live `~/projects/reynolds-household/*.md`.
- `Agent/` — historical Gemini chat-bar prototype, not wired and not an app dependency.
- `.github/workflows/` — CI + secret scan. See `.github/PIPELINE.md` for how the
  gate + auto-merge work and how to enable them.

## The pipeline — how changes ship
Right-sized from indigo-flow. Every code change goes through a PR; CI is the quality gate;
a person merges green PRs (no auto-merge since 2026-10-29). Full mechanics and the one-time GitHub setup: **`.github/PIPELINE.md`**.

**"Ship it" flow** (run end-to-end when a unit of work is done):
1. Branch from `origin/main`. Name it `feat/…`, `fix/…`, `chore/…`, `ci/…`, or `docs/…`.
2. Commit with a [Conventional Commits](https://www.conventionalcommits.org) message
   (`feat: add weather widget`, `fix: correct task toggle`).
3. Open the PR (`gh pr create`) with a short what/why body.
4. Wait for CI and read the review, then merge by hand: `gh pr merge <n> --squash --delete-branch`.
   No auto-merge: one merge rule across the household repos (PRD 00 v2, C4; repo setting off 2026-10-29).
5. Return to `main` (`git checkout main && git pull --ff-only`) so the next session starts clean.

Don't leave work "done but not submitted." If a change genuinely shouldn't be a PR, say so
and why.

**Execution runs on the real Mac** — via Claude Code, or from Cowork through the Desktop
Commander MCP (a real shell where `gh` is authenticated). Both routes are equivalent, both are
gated by the preflight below, and every change still lands via a PR. (Cowork's *sandbox* shell
has no git creds and can't reach GitHub's API — Desktop Commander is what makes Cowork able to
execute.) The full narrative lives in `docs/WAYS-OF-WORKING.md`.

## Repo alignment — the HARD RULE
FamilyHub and IndigoFlow (`~/projects/indigo-flow`, `Reynolds-Research/indigoflow`) share the
same two surfaces, the same Mac, and near-identical conventions. To stop them crossing wires:

- **Preflight leads every session and every prompt.** The first action in any Claude Code
  session here — and the literal first line of every CC handoff prompt Cowork writes — is:
  ```bash
  bash scripts/preflight.sh || exit 1
  ```
  It confirms `origin` is `matt-reynolds-research/FamilyHub` and **stops loudly** otherwise.
  Do not edit, commit, branch, or push until it prints `✔ FamilyHub aligned`. Prompts are
  built from `.claude/CC-PROMPT-TEMPLATE.md`, which bakes this in.
- **One repo per window.** FamilyHub work only from `~/projects/reynolds-household/FamilyHub`.
  Never `cd` into IndigoFlow mid-session.
- **`indigo-flow` is read-only reference.** Never edit the IndigoFlow repo from a FamilyHub
  session; in Cowork, mount it only when deliberately referencing it.
- **Plain git + gh only.** Do NOT use IndigoFlow's global git aliases (`savedocs`, `pushdocs`,
  `shuttle-docs`) or its commands (`/hotlist-next`, `/arm-runner`) here — they are set
  `--global`, so they exist in this repo too and will misfire. FamilyHub ships via the plain
  flow above.
- **No shared IDs or doc structure.** Don't reuse IndigoFlow's audit IDs (`P0-1`, `UXR-3`, …),
  its `docs/active/planning` tree, or its skills. FamilyHub keeps its own, simpler shape.

## Build principles
- **Small steps.** Smallest safe, reviewable pieces; no sweeping rewrites in one PR.
- **Fail loud while building.** Missing/unknown data surfaces as a clear error in dev, never
  silently faked; degrade gracefully once shipped.
- **Test the opposite too.** When you fix something, check you didn't break the neighbor.
- **Household markdown is shared — serialize byte-exactly.** `SHOPPING.md` / `TASKS.md` are read by
  the Morning Briefing and written by the text assistant. Model the *whole file* (intros, comment
  blocks, blank-line rhythm) and replay unmutated lines verbatim; never normalise or re-render.
  Domain logic stays as pure functions on the document so the Assistant Bar can call it too (D-19).
- **Protect core names.** Don't rename or batch-replace identifiers (DB keys, routes, config
  keys, localStorage keys) as "cleanup" without flagging it — silent breakage.
- **Keep `.env` clean.** Secrets only there; if CI needs a value, it uses a placeholder or a
  repo secret, never a committed key.
- **Keep docs true.** If `PROJECT_MAP.md` or a comment states behavior, the code must match —
  update them in the same change.

## Verifying changes
Never test against real family data or live accounts. Use mock/seeded data. The app runs on
mock data today (see `PROJECT_MAP.md`), which is a safe default for visual checks.
