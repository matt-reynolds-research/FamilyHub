# Claude Code prompt template — FamilyHub

**HARD RULE:** every handoff prompt Cowork writes for Claude Code on this repo begins
with the preflight block below. Copy this whole header verbatim; fill in the TASK. The
preflight is not optional and not summarizable — it is the literal first instruction.

---

## 0. Preflight — run first, stop on failure
Run:
```bash
bash scripts/preflight.sh || exit 1
```
If it prints `✋ STOP`, halt immediately and tell Matt — you are likely in the wrong repo
(IndigoFlow?). Do **not** edit files, commit, branch, or push until it prints
`✔ FamilyHub aligned`.

## 1. Context
- Repo: `~/projects/reynolds-household/FamilyHub` — FamilyHub, a Flutter iPad home hub.
- Read `AGENTS.md` and `PROJECT_MAP.md` before starting.
- Stay in this repo only. Plain `git` + `gh`. No IndigoFlow aliases or commands.

## 2. Task
<one clear, self-contained unit of work>

## 3. Done =
<acceptance criteria — how we know it's finished>

## 4. Ship
Follow AGENTS.md "ship it": branch from `origin/main` → conventional commit → open PR →
`gh pr merge <n> --auto --squash`. Then return to `main`.

---

*Why the preflight leads every prompt: FamilyHub and IndigoFlow share the same surfaces,
machine, and conventions. The check makes "am I in the right project?" a mechanical yes/no
instead of a thing you have to remember.*
