# NEXT STEPS — run in Claude Code on the Mac

Cowork can't push (it's read-only for GitHub). Open **Claude Code at
`~/projects/reynolds-household/FamilyHub`** and work through this. Everything is committed
locally and waiting.

## 0. Preflight (always first)
```bash
bash scripts/preflight.sh || exit 1
```
Must print `✔ FamilyHub aligned`. If it prints `✋ STOP`, you're in the wrong repo — halt.

## 1. One-time: format, then put the pipeline live on main
CI now has a `dart format` gate. Format the existing code once so it's compliant,
then push (this also formats the new smoke test):
```bash
dart format .                                   # run at the repo root — covers both packages
git add -A && git commit -m "chore: apply dart format"
git push origin main
```
That push triggers CI once, registering the check names for step 3. If `flutter analyze`
or the smoke test flags anything on this first run, paste me the log — I wrote the test
without being able to run Flutter here, so its first CI run is its verification.

## 2. One-time GitHub settings
- **Settings → General → Pull Requests →** enable **Allow auto-merge**.
- **Settings → Branches →** protect `main`: require a PR, and require the **`flutter`** and
  **`secret-scan`** status checks to pass.

## 3. Land the shakedown PR (the `withOpacity` → `withValues` cleanup)
```bash
git push -u origin fix/deprecated-withopacity
gh pr create --title "fix: replace deprecated withOpacity with withValues" \
             --body "Shakedown PR for the new CI pipeline."
gh pr merge --auto --squash <pr-number>
```
Then watch it: CI runs → both checks green → it squash-merges itself. That's the loop working.

## 4. Return to main
```bash
git checkout main && git pull --ff-only
```

---
*After this, the pipeline is proven. The natural next build is real feature work from
`PROJECT_MAP.md` (Phase 1: connect the Supabase database).*
