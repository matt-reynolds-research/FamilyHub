# PRD 04 — Tasks / Todo

_FamilyHub · Phase 3 · Status: **Locked (2026-08-21)** · Last updated 2026-08-21_
_Depends on: Home Hub, Shopping vertical-slice pattern, and Assistant Bar v1._

## Product job

Tasks should tell a passing family member how much household work remains, where it is in the
workflow, and who created the latest commitments so they know when an in-person or text follow-up
may help. The focused surface supports reading, adding, and completing tasks without diverging from
the household's shared `TASKS.md` conventions.

## Verified World format

- Sections: `Family Tasks`, `Open Tasks`, `Waiting On`, `Someday / Maybe`, terminal `Done`.
- Active: `- [ ] **Title** — optional context — added via text from <person> on <YYYY-MM-DD>`.
- Done: `- [x] ~~Title~~ (<YYYY-MM-DD>)`; completing drops prior annotations and moves to `Done`.
- Development uses a committed fixture only; live wiring remains Phase 5.

## Important ownership gap

`added via text from Sara` is **authorship**, not assignment. Today's World does not store a task
owner, so FamilyHub must not infer that the author owns the task or fabricate per-person remaining
counts. V1 shows workflow-section counts plus author/date provenance. True “tasks under each person's
name” requires a later World-layer decision and format change in `family-assistant/`.

## Goals

1. Byte-exact, whole-file model/parser/serializer covering every section and active/done form.
2. Add to Open or Family Tasks with optional context and seeded author/date provenance.
3. Complete a uniquely matched task by relocating it to Done with today's date; never delete.
4. Ambient summary based on real fixture data; focused view grouped by workflow section.
5. Assistant intents added only after touch/data behavior works.

## Non-goals

- No fabricated assignment, priority, due date, or reminders.
- No live `TASKS.md`, external accounts, arbitrary edit/delete, or client-side archive clearing.
- No Waiting/Someday moves in v1; those need explicit household commands/conventions first.

## Phasing

- **3a — data contract:** fixture, lossless parser/serializer, add/done mutations, repository, tests.
- **3b — surface:** truthful ambient tile and focused workflow lists with touch add/complete.
- **3c — conversation:** Tasks add/query/done intents through the same controller.

## Done

- Unmutated fixtures serialize byte-identically, including comments and blank-line rhythm.
- Add/done produce hand-written expected whole-file output and conserve every unrelated line.
- Unknown content is preserved; malformed bullets in known sections fail loudly with a line number.
- UI never labels authorship as ownership.
