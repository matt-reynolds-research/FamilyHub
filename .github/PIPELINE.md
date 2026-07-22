# FamilyHub pipeline

The right-sized version of indigo-flow's pipeline: **a quality gate on every PR, and
auto-merge when it's green.** Enough to keep quality high without babysitting.

## What runs

| Check | Workflow | What it proves |
|---|---|---|
| **CI** | `.github/workflows/ci.yml` | The app analyzes clean (`flutter analyze`), tests pass (once they exist), and it compiles (`flutter build web`). |
| **Secret Scan** | `.github/workflows/secret-scan.yml` | No API key or secret got committed. |

Both run automatically on every PR into `main` and on direct pushes to `main`.

## The flow

```
open PR  ──►  CI + Secret Scan run  ──►  both green?
                                          ├─ yes ──►  auto-merges itself (squash)
                                          └─ no  ──►  merge blocked until fixed
```

You arm auto-merge once per PR with `gh pr merge <n> --auto --squash`. GitHub holds the
PR until the required checks pass, then merges it. You keep a veto the whole time:
`gh pr merge <n> --disable-auto`.

## One-time setup (do this once, after pushing these files)

These are GitHub settings — a few clicks, or scriptable via `gh` if you authorize the
GitHub connector. Nothing below can be done from inside the repo files alone.

1. **Push the pipeline files** so the workflows exist on `main`:
   ```
   git push origin main
   ```
   That push triggers CI once, which registers the check names GitHub needs in step 3.

2. **Enable auto-merge:** repo **Settings → General → Pull Requests → check
   "Allow auto-merge."**

3. **Require the checks:** repo **Settings → Branches → Add branch ruleset (or protection
   rule) for `main`:**
   - Require a pull request before merging.
   - Require status checks to pass → add **`flutter`** (from CI) and **`secret-scan`**.
   - (Optional) Require branches to be up to date before merging.

Once those are set, any PR you open — or the pipeline opens — merges itself on green and
blocks on red. That's the whole low-touch loop.

## What we deliberately left out (vs. indigo-flow)

Indigo-flow also runs an independent AI reviewer with a required "review-gate" status, a
self-healing sweeper, an overnight autonomous build runner, e2e/visual/RLS test stacks, and
several bespoke lint tripwires. All valuable there (it handles real money); all overkill for
a hobby app today. The natural next add, once this gate has proven itself, is the **overnight
runner** (`/arm-runner` + `/hotlist-next` style) — a fully hands-off "build the next scoped
item" loop.

## First test drive

A good first PR to exercise this: the small `withOpacity` → `withValues` cleanup in
`lib/features/home/home_page.dart` (the rest of the app already uses `withValues`). Tiny,
safe, and it lets you watch the gate + auto-merge work end to end before real feature work.
