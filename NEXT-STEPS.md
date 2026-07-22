# NEXT STEPS — run in Claude Code on the Mac

Cowork can't push (it's read-only for GitHub). Open **Claude Code at
`~/projects/reynolds-household/FamilyHub`** and work through this. Everything is committed
locally and waiting.

## 0. Preflight (always first)
```bash
bash scripts/preflight.sh || exit 1
```
Must print `✔ FamilyHub aligned`. If it prints `✋ STOP`, you're in the wrong repo — halt.

## 1. Put the pipeline live on main
```bash
git push origin main      # may already be up to date
```
This triggers CI once, registering the check names for step 3.

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
