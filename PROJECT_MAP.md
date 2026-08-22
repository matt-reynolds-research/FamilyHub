# FamilyHub — PROJECT_MAP.md

> **The north star.** This file is the single source of truth for *what FamilyHub is,
> what exists vs. what's still a placeholder, and the order we build in.* If reality and
> this file disagree, one of them is wrong — fix it in the same step. Everything else
> (PRDs, design system, code) hangs off this.

_Last updated: 2026-08-22 · Status: **Phase 3 complete — Tasks is a working seeded vertical slice across ambient, touch, and conversation. The Assistant Bar now routes explicit Tasks add/query/complete commands through the same controller as touch and switches its engaged preview by domain. Next: Phase 4 Mail & Packages scoping.**_
_Phase 0 (done, for the record): Home Hub design imported from Claude Design (`design/FamilyHub Home Hub.dc.html`); first Flutter shell increment landed — dark seed v1.2 tokens (Helvetica Neue) + ambient home (header, 3-tile grid, Assistant Bar pill, generic focus container) on seeded data, widget-tested. Sphere / engaged / voice deferred to a later layer. **Prior tab shell + Supabase + light theme now pruned — the app tree is just the Home Hub shell and analyzes clean.**_

---

## 1. Vision (the one sentence)

**A primarily headless AI assistant I can hang on the wall and talk to to run my home** —
an always-on iPad "home hub" for the Reynolds household where the conversation *is* the
product and the screen is the ambient, glanceable backup.

The mental model isn't "an app with a chatbot in it." It's **an assistant with a face**.
Voice/conversation is the front door; the tiles (tasks, shopping, mail) are what the
assistant shows you when you glance over, and what you can poke with a finger when talking
isn't convenient.

## 2. What this project is (and isn't)

Carried over from the project instructions so the map stands on its own:

- **Experimental over practical.** It doesn't have to be useful. Novelty and "let's see if
  this works" are valid goals. When a choice is low-stakes, take the more interesting path.
- **A way to stay sharp on AI development.** Prefer current, real-world tools and patterns.
  Notable technical decisions get a short written *what & why* so the pipeline keeps teaching.
- **Still high fidelity.** Experimental ≠ sloppy. Clean, quality work inside the experiment.
- **Not a public product.** Family MVP / playground. Favor simple working solutions over
  enterprise complexity. Never build against real family data or live accounts — **seed/mock
  data only** during development.

## 3. How FamilyHub relates to the assistant we already run

This matters, because we are **not** starting from zero on the *backend*. The household
already has a working assistant (see the Cowork project `README.md`):

- **Data lives as markdown** — `TASKS.md` and `SHOPPING.md` are the current source of truth,
  with defined sections and states.
- **Input channels already exist** — Cowork, email commands (`ADD:`, `GROCERY:`, `SHOP:`…),
  and iMessage (`@claude …`, voice memos), all landing in the household inbox.
- **Automations already run** — 6:30 AM Morning Briefing, 10 PM calendar sweep, an email-in
  task handler, a mail watcher.

**So FamilyHub is a new *surface* over an existing *world*, not a new system.** Its domain
models should mirror the conventions those files already use (same sections, same states,
same command vocabulary) so the wall display and the text/email assistant stay in sync.

> **This is now a load-bearing correction, not just a principle.** The prior Flutter app
> (see §6a) went the *opposite* way — it built a separate **Supabase** database as its
> backend. That is being **shelved**: a second datastore writing household state both
> duplicates the markdown world and would collide with the existing automations (see the
> live-wiring concurrency hazard, §9.3). FamilyHub mirrors the markdown files; it does not
> stand up a parallel database.

> **Build-time rule:** FamilyHub develops against **seeded mock data shaped like** those
> files — not the live files. Wiring the hub to the real household backend is a deliberate,
> later phase (see Roadmap Phase 5 and Open Decisions), not something we do casually.

**The backend world evolves on its own track.** Work that changes the *world* rather than the
*surface* is scoped outside this map — e.g. automated calendar maintenance
(`../docs/calendar-maintenance-scoping.md`, draft). FamilyHub consumes whatever that world
produces; it isn't blocked by it.

## 4. The five features — and their *roles*

The features aren't five peers. They play three different structural roles, and that's what
determines build order:

| # | Feature | Role | Plain-English job |
|---|---------|------|-------------------|
| 5 | **Home Hub** | **Foundation (the shell)** | The always-on frame: the grid, the ambient/wall idle state, navigation, and the data layer everything else renders into. |
| 1 | **AI Conversational Assistant Bar** | **Spine (primary interaction)** | The persistent way you talk to the hub. Depends on the shell existing and on having at least one domain to act on. Grows one domain at a time. |
| 2 | **Tasks / Todo** | Data domain | Read + touch surface over the household to-do list (mirrors `TASKS.md`). |
| 3 | **Shopping (Grocery + Household)** | Data domain | Read + touch surface over the shopping lists (mirrors `SHOPPING.md`). |
| 4 | **Mail & Packages** | Data domain (integration-heavy) | Glanceable view of household mail + package/delivery status. Most external-integration risk; likely read-mostly first. |

**Why this framing:** you can't design a "system" for domains you haven't defined, and the
assistant has nothing to talk about until at least one domain exists. So the shell and one
real domain come first; the assistant proves itself against that domain; then the rest fan out.

## 5. Roadmap — dependency order, not excitement order

Build in the order things *stand on each other*, and always ship one complete vertical slice
before going wide. **Phase 0 is now "salvage-and-reshape," not greenfield** — a prior Flutter
app exists and its reusable parts (project, CI, Riverpod patterns, theme structure, the `Agent`
AI bar) are harvested rather than rebuilt. See §6a and `SALVAGE-AUDIT.md`.

- **Phase 0 — Foundation & guardrails (reshape the prior app).** Reuse the existing Flutter
  project, CI, and `Agent` package. **Replace** `lib/shell` + the tab navigation with the tile
  grid + the ambient⇄engaged mode concept; **retheme** the token files from the light arm's-length
  palette to the seed's dark, distance-legible tokens; stand up a **seeded/mock data layer behind
  the existing Riverpod pattern** (not Supabase). Keep the design-system seed as the visual
  contract. Fail-loud on missing data. Deliver the empty Home Hub shell (grid + ambient idle +
  navigation).

- **Phase 1 — First vertical slice: Shopping.** Build the domain end-to-end as a real tile:
  render, **add/check** (user-owned), respect the `SHOPPING.md` sections. **Clearing is the agent's
  ~7-day sweep, not a client action** (critic L3) — the tile reads a cleared state, never
  destructively deletes. **Phase 1 also builds the real Dart parser against `SHOPPING.md`** and the
  lossless model (D-10) — genuinely new work, since the prior app never had it (it went to
  Supabase). Validates the whole pipeline (data → design system → tile → interaction). *Tasks is an
  equally valid slice; Shopping chosen for being the most constrained CRUD.*

- **Phase 2 — Assistant Bar v1 (wired to Shopping).** **Complete.** The persistent text bar controls
  exactly one domain: "add milk," "what's on the list," "we got the eggs." It expands into the
  engaged canvas and reuses Shopping's controller/mutations. V1 is a deterministic local adapter—no
  model cost, API key, or second brain. The old `Agent/` Gemini prototype is historical reference.

- **Phase 3 — Tasks / Todo domain.** **Complete.** Second domain tile + assistant integration reuses
  Phase 1–2 patterns and confirms the shell and deterministic assistant generalize beyond one domain.

- **Phase 4 — Mail & Packages.** The integration-heavy domain. Start read-mostly (glanceable
  status). External accounts are a security/privacy decision point — pause and confirm before wiring
  anything live.

- **Phase 5 — Ambient / wall mode + live backend.** The "hang it on the wall" polish: the physical
  always-on wake / kiosk mechanism (moved here from Phase 0 — critic L2), always-on glanceable idle
  states, voice input, and the deliberate decision about connecting to the real household backend.
  **Live wiring needs a write-arbitration approach** for concurrent writes with existing automations
  (10 PM sweep, email-in handler) — critic L5.

## 6. Feature inventory — built vs. placeholder

In the **new (tile-shell) architecture**, every surface below is still to be built — but "built"
now means *reshaped from the prior app where possible*, not written from scratch. The prior app's
disposition is §6a.

| Feature | Status | Notes |
|---------|--------|-------|
| Home Hub (shell) | 🟡 shell scaffolded (Phase 0) | Phase 0 — [`prds/01-home-hub-prd.md`](prds/01-home-hub-prd.md). Ambient home now includes populated seeded activity previews across all three tiles: volume, ownership, recency, and delivery urgency. Focus views replay that mock detail and clearly disclose that live household data is not connected. Ambient⇄engaged remains deferred. |
| Design-system seed | ✅ v1.1 | Phase 0 — [`design/design-system-seed.md`](design/design-system-seed.md). Tokens + tile grid + reusable tile. Target device iPad 10th gen. |
| Shopping tile | ✅ working seeded slice (Phase 1) | Phase 1 — [`prds/02-shopping-prd.md`](prds/02-shopping-prd.md). Ambient summary and focused Grocery/Household lists now derive from the fixture-backed lossless document. Touch add/check persist through the byte-exact serializer for the app session; checking relocates to the read-only Recently Bought archive. Loading/error paths fail visibly. Live household data remains Phase 5. |
| Assistant Bar | ✅ working Shopping + Tasks adapter (Phase 3) | [`prds/03-assistant-bar-prd.md`](prds/03-assistant-bar-prd.md). Typed ambient entry → engaged conversation canvas; explicit add/query/complete commands share each domain's controller and switch the side preview. Deterministic and session-only; voice/live-brain transport deferred. |
| Tasks / Todo tile | ✅ working seeded slice (Phase 3) | [`prds/04-tasks-prd.md`](prds/04-tasks-prd.md). Ambient workflow counts and recent provenance, focused touch add/complete, and Assistant Bar add/query/done all use the fixture-backed lossless repository. Authorship is never presented as ownership. |
| Mail & Packages tile | ⬜ Placeholder | Phase 4 |
| Ambient/wall mode | ⬜ Placeholder | Phase 5 |
| Live backend wiring | ⬜ Placeholder | Phase 5 — needs an explicit go |

### 6a. Prior app — what already exists (and its disposition)

A prior Flutter app, **`reynolds_family_dashboard`** (a 5-tab Nest Hub-style dashboard, ~1,540
lines, mock-data + a written-but-off Supabase backend), plus the **`Agent`** AI-bar package, live
in this repo. It embodies an *earlier* product conception (tabs + a separate database); the
tile-shell/markdown vision above is canonical (D-14). Full detail in
[`SALVAGE-AUDIT.md`](SALVAGE-AUDIT.md). Summary:

- **✅ Carry over:** the Flutter project + CI + platform folders; the Riverpod state *pattern*
  (`AsyncNotifier` per domain); the theme *structure* (`tokens → ThemeData`); `google_fonts`/Inter,
  `intl`, `dotenv`; and the **`Agent`** package (the AI bar).
- **🔧 Adapt:** the `Task` / `GroceryItem` models → the lossless markdown model; the repository
  *interface* → a markdown-backed repo; the theme *values* → the seed's dark tokens.
- **⛔ Shelved — now REMOVED (Phase-0 prune, 2026-08-03):** `supabase_flutter` + the repository/
  service/`supabase_migration.sql`; the tab navigation (`AppTab` + `_TabBarRow`) and all five tab
  feature pages; the light `AppColors`/`AppTheme`/`AppTypography`; the old models/providers; and the
  `flutter_dotenv`/`google_fonts`/`google_generative_ai` deps. `Agent/` now remains only as historical reference.

## 7. PRD writing order

PRDs get written **one phase ahead of the build**, in dependency order:

1. **Home Hub** (the shell) → **✅ Locked: [`prds/01-home-hub-prd.md`](prds/01-home-hub-prd.md).**
2. **Shopping** — first vertical slice → **✅ Locked: [`prds/02-shopping-prd.md`](prds/02-shopping-prd.md).**
3. **Assistant Bar** → **✅ Locked and implemented: [`prds/03-assistant-bar-prd.md`](prds/03-assistant-bar-prd.md).**
4. **Tasks / Todo** — **✅ Locked and implemented: [`prds/04-tasks-prd.md`](prds/04-tasks-prd.md).**
5. **Mail & Packages** — last; most external unknowns.

The **design-system seed comes before PRD #2**; it then *grows* as each PRD surfaces a component it
needs — evidence-driven, not speculative.

## 8. Tech stack — authority

The project is scaffolded, so **the authority on stack + versions is `reynolds_family_dashboard/pubspec.yaml`
/ `pubspec.lock`** — trust those over any prose here. As of this audit: **Flutter (SDK ≥3.2),
`flutter_riverpod`, `google_fonts` (Inter), `intl`, `flutter_dotenv`, and the local `Agent`
package.** Direction: **iPad target, headless/ambient-first.**

**Supabase — REMOVED (Phase-0 prune, 2026-08-03).** `supabase_flutter` + the repository/service/
`supabase_migration.sql` are gone; FamilyHub mirrors the markdown world instead (§3, D-15). The app now
runs on seeded mock data with no datastore. (`google_generative_ai`, `google_fonts`, `flutter_dotenv`
went with it; the old `Agent/` package is retained only as historical reference and is not a dependency.)

## 9. Open decisions — need Matt before/at these points

1. **Repo location — ✅ RESOLVED (2026-08-03, D-16).** Canonical repo is
   **`~/projects/reynolds-household/FamilyHub/`** → GitHub `matt-reynolds-research/FamilyHub` (branch
   `main`). Planning docs were consolidated here from a mislocated `~/Documents` copy (which is
   pending retirement after a household-level audit). Cowork should be re-pointed to this tree.
2. **First vertical slice: Shopping vs. Tasks.** Map assumes Shopping. Easy to flip. *(Blocks Phase 1.)*
3. **Live backend, eventually.** Read/write the real `TASKS.md`/`SHOPPING.md` + calendar, or stay a
   seeded demo? Shapes the data layer. Reinforced by shelving Supabase (§3). *(Decided by Phase 5;
   if yes, concurrent-write arbitration with the existing automations is a hard precondition — L5.)*
4. **Assistant Bar live transport.** V1 is deliberately deterministic and free (D-21). Before it
   becomes a face onto the live Family Assistant, choose the transport/API plus its privacy boundary.
   A model choice is only needed if local/deterministic handling proves insufficient. *(No longer
   blocks Phase 2; blocks live/general assistant behavior. Anything that spends money pauses.)*
5. **Added-by provenance.** The desired ambient experience groups Shopping and Tasks activity by
   person and recency, but today's `SHOPPING.md` active-item format stores neither author nor added
   date. The seeded UI demonstrates the experience only. Making it truthful requires a later **World**
   decision in `family-assistant/` about capturing provenance without breaking existing readers.

## 10. How to keep this file alive

- Update the **status table (§6)** and the **phase markers (§5)** in the *same commit* as the change.
- Log notable decisions in [`DECISIONS.md`](DECISIONS.md) (one line: *what & why*); mirror durable
  technical rules into `AGENTS.md`.
- End each working session with a recap in [`SESSIONS.md`](SESSIONS.md). **To resume in a fresh
  session:** read this file → `AGENTS.md` → the top `SESSIONS.md` entry → `DECISIONS.md` tail.
- Work the phases in order unless Matt says otherwise. Commit early after any working change or new doc.
