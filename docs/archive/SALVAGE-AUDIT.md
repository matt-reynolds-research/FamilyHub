# FamilyHub — Salvage Audit of the existing Flutter app

_Audited 2026-08-03 · Source: `~/projects/reynolds-household/FamilyHub/reynolds_family_dashboard/` (+ the `Agent` package) · Target vision: the two-mode tile shell + markdown-mirror data layer described in PRD 01/02 and the design seed._

## Bottom line

The app is small and tidy — **~1,540 lines of Dart across the app, ~180 in the `Agent` package** — and it's genuinely well-organized (clean Riverpod + feature-folder layout). That's the good news: almost nothing is *wasted*, but a meaningful slice points the wrong way for the tile-shell/markdown vision. Roughly:

- **~40% carries over as-is or near-as-is** — the Flutter project + CI + platform folders, the Riverpod state pattern, the theme *structure*, `Agent` (the AI bar), and reusable widget idioms.
- **~35% is worth adapting** — the models and the repository *interface* keep their shape but get reworked from Supabase/DB rows to the lossless markdown model.
- **~25% gets shelved** — the Supabase backend, the tab navigation, and the light arm's-length theme *values*.

This confirms the "rebuild the spine, harvest the parts" recommendation: you keep the scaffolding, patterns, and AI bar; you replace the data backbone, the nav model, and the visual values.

## Stack (from `pubspec.yaml`, the authority)

`flutter_riverpod ^3.3.2` · `supabase_flutter ^2.16.0` · `google_generative_ai ^0.4.0` · `google_fonts ^8.1.0` · `intl ^0.20.3` · `agent` (local package) · `flutter_dotenv ^6.0.1`. SDK `>=3.2.0`.

Riverpod (state), google_fonts/intl/dotenv all fit the plan. `supabase_flutter` is the one dependency the plan doesn't want. Gemini (`google_generative_ai`) is real but ties to the still-open "assistant brains — on-device vs. hosted, which model, $" decision (PROJECT_MAP §9.4).

## Piece-by-piece

### ✅ Carries over (keep — high value)

| Piece | Why it survives |
|---|---|
| Flutter project, `ios/ android/ macos/…`, CI (`.github/`), lints | Real scaffolding; the tile shell is a *rewrite of `lib/`, not a new project.* This is the bulk of "not starting from zero." |
| **`Agent` package** (`agent_terminal_bar.dart`, `chat_provider`, `gemini_service`) | A working pinned-bottom AI bar with text input + chat-history sheet + Riverpod. This *is* the Phase-2 Assistant Bar starting point. Restyle from "terminal" to the seed's pill; the model choice stays the open $ decision. |
| Riverpod state **pattern** (`data_providers.dart`: `AsyncNotifier` + `refresh/add/toggle/remove` per domain) | Exactly the right shape for a domain data layer. Keep the pattern; swap the *source* (Supabase → markdown repo). |
| Theme **structure** (`AppColors`/`AppTypography`/`AppTheme` → `ThemeData`) | This is the precise pattern the design seed anticipated ("these become a single `tokens.dart` feeding `ThemeData`"). Keep the wiring; replace the values. |
| `google_fonts` + **Inter**, `intl`, `flutter_dotenv` + `.env` bootstrap, `ProviderScope` app root | All fit the plan unchanged. |
| Widget idioms (check-toggle w/ strikethrough, inline add-field, empty-state, list rendering in `groceries_page`/`tasks_page`) | Harvest as snippets into the new tile/focused views. |

### 🔧 Adapt (keep the shape, rework the substance)

| Piece | What changes |
|---|---|
| `models/task.dart`, `models/grocery_item.dart` | Field skeletons are a decent start but **not lossless vs. the markdown.** `GroceryItem.quantity` is an `int` — loses `(2 gallons)`; `category` defaults to `'Other'` — doesn't map to Grocery/Household sections; no provenance/date/archive. `Task` has no title+em-dash-context split, no "added via text from X" provenance, no Done/archive concept. Rework to the lossless model (PRD 01 P0-5 / PRD 02 P0-1); replace DB `fromJson/toJson` with markdown parse/serialize. |
| `repositories/supabase_repository.dart` | The *interface* (fetch/insert/toggle/delete per domain) is a clean template. Keep the interface; replace the implementation with a markdown-file repository. |
| `providers/mock_data_provider.dart` | Useful stopgap, but reshape fixtures to mirror `SHOPPING.md`/`TASKS.md` (and go fail-loud, per the plan) instead of arbitrary demo rows. |
| Theme **values** (`app_colors` light cream palette; `app_typography` 48/36/28… sizes; `app_theme` card elevation/shadows) | Replace with the seed's **dark, distance-legible** tokens (`ink.900…`, `type.hero 52 / number 30`), and drop drop-shadows (seed uses surface steps). Same files, new numbers. |
| Feature pages (`groceries_page`, `tasks_page`, `mail_page`, `home_page`) | Rebuild layouts for the **summary tile + focused view** model; the current full-screen category-card layouts assume tabs and DB categories. Harvest the widgets, not the page structure. |

### ⛔ Shelve (drop for this direction)

| Piece | Why |
|---|---|
| `supabase_flutter` dep, `supabase_repository.dart`, `services/supabase_service.dart`, `supabase_migration.sql` | The plan mirrors the household's **markdown files**, not a separate Postgres. A second DB writing household state also collides with the existing automations (the plan's Phase-5 concurrency hazard). Shelve, don't finish. |
| `providers/navigation_provider.dart` (`AppTab` enum) + `_TabBarRow` in `app_shell.dart` | Tab navigation is the opposite of the ambient⇄engaged + tile-focus model. Replace with a mode/focus provider. *(The pinned-bottom-`AgentTerminalBar` idea in the same shell file survives — see above.)* |
| DB-shaped `fromJson/toJson`, category-grouping grocery logic | Tied to the Supabase schema and to categories that don't exist in `SHOPPING.md`. |

## What this means for the plan

1. **`PROJECT_MAP.md` must stop saying "nothing built."** Correct §6 to: *a prior Flutter app exists (`reynolds_family_dashboard`) — we harvest its scaffold, Riverpod patterns, theme structure, and the `Agent` AI bar; we shelve its Supabase backend and tab nav.* This is the honest reconciliation I deliberately didn't fake earlier.
2. **Phase 0 changes from "greenfield empty shell" to "extract + reshape."** The shell work is now: replace `lib/shell` + nav with the tile grid + mode concept, retheme the tokens, and stand up the markdown repo behind the existing Riverpod pattern. Cheaper than greenfield, because the project, patterns, and AI bar already exist.
3. **The markdown parser (PRD 02) remains the real new work** — the existing app never had it (it went to Supabase instead), so nothing is lost there; it was always going to be built fresh.
4. **`Agent` de-risks Phase 2.** The Assistant Bar has a working head start; the remaining question is the still-open model/$ decision, not "build a chat bar from scratch."

## Recommended next step

Rewrite `PROJECT_MAP.md` around this reality (a "what exists / what we harvest / what we shelve" inventory + the revised Phase 0–1 scope), then keep going on the Shopping slice with the salvage in mind. I can do that rewrite next — it's the honest reconciliation that was blocked until this audit existed.
