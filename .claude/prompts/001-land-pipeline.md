# CC prompt 001 — bring the pipeline online + shakedown PR

> ✅ **COMPLETED 2026-07-22.** This ran end-to-end and landed as **PR #1**, which merged
> itself on green CI. The pipeline is live and enforced. Kept as a reference example of a
> handoff prompt — for new work, build prompts from `.claude/CC-PROMPT-TEMPLATE.md`.

Paste everything below the line into Claude Code, opened at
`~/projects/reynolds-household/FamilyHub`.

---

**0. Preflight — run first, stop on failure.**
```bash
bash scripts/preflight.sh || exit 1
```
If it prints `✋ STOP`, halt and tell me — you're in the wrong repo.

**1. Context.**
You're in `~/projects/reynolds-household/FamilyHub` — FamilyHub, a Flutter iPad home hub.
Read `AGENTS.md` and `NEXT-STEPS.md` first. Stay in this repo only; plain `git` + `gh`; do
not use any IndigoFlow aliases or commands.

**2. Task — bring the CI + auto-merge pipeline online and prove it with the shakedown PR.**

Format the code once (so the new `dart format` gate passes), commit, and push `main` —
this brings the pipeline + governance commits live and triggers CI:
```bash
dart format .
git add -A && git commit -m "chore: apply dart format"
git push origin main
```

Enable the merge automation — via `gh` if you can, otherwise tell me the exact clicks:
- Allow auto-merge on the repo.
- Branch protection on `main` requiring a PR and the `flutter` and `secret-scan` status checks.

Land the shakedown PR (already committed on branch `fix/deprecated-withopacity`):
```bash
git push -u origin fix/deprecated-withopacity
gh pr create --title "fix: replace deprecated withOpacity with withValues" \
             --body "Shakedown PR for the new CI pipeline."
gh pr merge <n> --auto --squash
```

Watch CI. It runs format → analyze → smoke test → build web, plus the secret scan.
**This is the first real run of the smoke test and gates**, so if anything is red, share the
log and propose a fix before merging — do not force it through.

When the PR merges green, return to a clean `main`:
```bash
git checkout main && git pull --ff-only
```

**3. Done =**
- `main` is on GitHub with CI passing.
- Auto-merge + branch protection (`flutter`, `secret-scan`) enabled.
- The shakedown PR opened, went green, and squash-merged itself.
- You're back on a clean `main`.
