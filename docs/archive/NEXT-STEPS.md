# NEXT STEPS

## ✅ Done — the pipeline is live (2026-07-22)
The CI + auto-merge pipeline is built, proven, and enforced on GitHub:
- **CI gate** on every PR: `dart format` → `flutter analyze --no-fatal-infos` → Home smoke test → `flutter build web`.
- **Secret scan** (gitleaks).
- **Branch ruleset** on `main` requires the `flutter` + `secret-scan` checks; **auto-merge** enabled.
- Proven end-to-end by **PR #1**, which merged itself on green.

`main` is protected, so **all changes now go through a PR** (docs included). Ship with the
`AGENTS.md` "ship it" flow: branch → conventional commit → `gh pr create` →
`gh pr merge <n> --auto --squash`.

## ▶️ Next milestone — Supabase (Phase 1 in PROJECT_MAP.md)
The app still runs on mock data. The next real step is standing up a Supabase project, adding
the keys to `reynolds_family_dashboard/.env`, running `supabase_migration.sql`, and flipping
the app to live data. This one needs your Supabase account.

## 🧹 Good first PRs (easy pipeline practice)
- Fix the Home header overflow (wrap the greeting in a `Flexible`).
- Clear the 5 deprecation infos: `Color.value` → `toARGB32`, `withOpacity` → `withValues`,
  Supabase `anonKey` → `publishableKey`, `ColorScheme.background` → `surface`.
