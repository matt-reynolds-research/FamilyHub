# Ways of working — FamilyHub

How we (Matt + Claude) build this project. Written 2026-07-22, after the foundation was laid.
This is the narrative; the enforceable specifics live in `AGENTS.md`, `.github/PIPELINE.md`,
and `scripts/preflight.sh`.

## The shape of a change
1. **Plan in Cowork** — scope the work, write/refresh docs (`PROJECT_MAP.md`, PRDs), pick the next unit.
2. **Execute on the real Mac**, via either equivalent route (both have Matt's authenticated `gh`):
   - **Claude Code**, opened at `~/projects/reynolds-household/FamilyHub`, or
   - **Cowork via the Desktop Commander MCP** — a real shell on the Mac. This is why Cowork is
     *not* limited to planning: the earlier "Cowork is read-only for GitHub" was only ever true
     of Cowork's *sandbox* shell, which has no git credentials and a proxy that blocks GitHub's
     API. Desktop Commander routes around both.
3. **Every change lands via a PR.** `main` is protected by a branch ruleset requiring the
   `flutter` + `secret-scan` checks, with auto-merge on — so even docs go through a PR that
   auto-merges on green. Ship with AGENTS.md's "ship it": branch → conventional commit →
   `gh pr create` → `gh pr merge <n> --auto --squash`.
4. **Validate before pushing when you can.** On the real Mac we run the exact CI locally
   (`flutter analyze` / `flutter test` / `flutter build web`) so a PR is green first try.

## Guardrails that keep it honest
- **Preflight leads every session.** `bash scripts/preflight.sh` confirms this is the FamilyHub
  repo and stops loudly otherwise — and it's the first line of every CC handoff prompt.
- **Stay out of IndigoFlow's lane.** FamilyHub and IndigoFlow share a machine and conventions:
  one repo per window, `indigo-flow` is read-only reference, and none of IndigoFlow's global git
  aliases or commands are used here (see `AGENTS.md` § Repo alignment).
- **The CI gate is the quality net** — format → analyze → smoke test → build, plus a secret scan.
  Right-sized from IndigoFlow's heavier setup: no autonomous runner, no headless reviewer.

## How we work together
- **Low-touch.** Matt's main energy is on IndigoFlow, so Claude defaults to making progress and
  summarizing async; Matt's attention is reserved for irreversible actions, spending money,
  security/privacy, and real forks in direction.
- **Explain the reasoning.** Matt is a capable practitioner still learning the deeper craft —
  decisions get a short "why," and concepts get named.
- **One unit per session.** When a self-contained unit closes and the next is independent,
  checkpoint and start fresh rather than letting one thread sprawl.

## Where the durable record lives
- `PROJECT_MAP.md` — what exists, built vs placeholder, the roadmap (north star).
- `AGENTS.md` — the enforceable rules any AI tool follows here.
- `.github/PIPELINE.md` — how the CI + auto-merge gate works.
- `.claude/CC-PROMPT-TEMPLATE.md` — the shape of every Claude Code handoff.
- `docs/prds/` — per-component PRDs.
- Cowork project memory — the same method in brief, auto-loaded each session.
