# Scoping-Critic Returns — FamilyHub PRD 01 packet

_Recorded 2026-08-02. Two outside reads (GPT, Gemini) of the verified packet
[`2026-08-02-scoping-critic-packet.md`](2026-08-02-scoping-critic-packet.md). Returns reproduced
**verbatim first**, correlation below. Per the scoping-critic method, lone voices are kept, not
filtered on agreement._

---

## Verbatim returns

### GPT

```
VERDICT: REVISE

[1] SEVERITY: material
    QUOTE: "The layer is backed by seeded/mock data shaped to mirror TASKS.md / SHOPPING.md
    (sections + item states), so domains map cleanly later."
    PROBLEM: "Sections + item states" does not preserve required fields such as completion date,
    source-list provenance, optional shopping notes/quantities, or the task title/context split.
    A later Markdown adapter cannot map cleanly through a typed contract that omits information
    needed to reproduce the source-of-truth lifecycle.
    DISPROOF: A Phase 0 typed-model schema and round-trip fixture showing every verified Shopping
    and Tasks form can be parsed, mutated, serialized, and restored without information loss.

[2] SEVERITY: material
    QUOTE: "Given the iPad is powered and FamilyHub is running, when the display wakes, then the
    ambient home view is shown immediately with no login, launch, or intermediate screen."
    PROBLEM: This is a P0 requirement and Phase 0 success metric, while the mechanism that could
    make it true—Guided Access, kiosk behavior, or keep-awake configuration—is explicitly deferred
    until Phase 5. Phase 0 therefore cannot establish its own definition of done on the target device.
    DISPROOF: A documented Phase 0 device configuration plus a successful 10/10 physical wake test
    demonstrating the requirement without depending on any deferred Phase 5 work.

[3] SEVERITY: material
    QUOTE: "Given engaged mode is triggered (a hot word, per the notes), when triggered, then the
    shell can switch modes without a layout rebuild; and on silence/close-out word, it returns to
    ambient."
    PROBLEM: This acceptance criterion requires hot-word, silence-timeout, and spoken close-out
    behavior even though Phase 0 stubs engaged mode and Phase 5 owns those voice capabilities.
    Merely storing an ambient/engaged enum cannot verify the stated trigger-and-return behavior.
    DISPROOF: Revised Phase 0 acceptance criteria using an explicit synthetic trigger and timer
    event, together with a test showing that the same state-machine interface can later accept
    voice events without shell changes.

[4] SEVERITY: material
    QUOTE: "A 6-column base is an additive split later (each column halves into two) if a wide/hero
    tile or a fourth domain appears — the existing tiles keep their positions, so it's not a rewrite."
    PROBLEM: Three existing equal-width tiles already consume all six half-columns, so adding a
    fourth domain cannot preserve their widths and positions in the same row. The open Calendar
    domain makes this claimed growth case concrete, yet no wrapping, second-row, paging, or resizing
    rule exists.
    DISPROOF: A dimensioned four-domain layout on the 1180×820 canvas showing the existing three
    tiles unchanged in size and position, with the fourth tile and reserved Assistant Bar fitting
    under the stated grid rules.

UNSTATED ASSUMPTIONS:
- The typed contract will preserve ordering, formatting-relevant fields, archive provenance, dates,
  and every lifecycle transition even though only "sections + item states" are specified.
- A simulator-built shell can later acquire the required physical-device wake behavior without
  changing navigation, lifecycle handling, or the Phase 0 definition of done.
- Future domains such as Calendar can fit into the fixed three-tile ambient layout and engaged
  sidebar without revising the shell contract.

FRAME CHECK: The package directly addresses the need for a coherent visual shell and staged
conversational experiment. It does not yet demonstrate that this shell can faithfully surface the
existing Markdown-backed world, so its strongest evidence currently supports a polished mock-data
interface rather than the claimed replaceable surface over that world.
```

### Gemini

```
VERDICT: REVISE

[1] SEVERITY: blocking
    QUOTE: "Mock format: hand-authored JSON mirroring the markdown sections/states (decided). The
    typed model is the contract, not the file format — so a markdown adapter can replace the JSON
    source later (Phase 5) without touching any tile."
    PROBLEM: The verified markdown structure is not just sections and booleans; it contains rich
    metadata natively embedded in strings (provenance lists, dates, strikethroughs, parenthetical
    quantities, bold titles). If the JSON model mirrors only "sections/states" and ignores this rich
    unstructured schema, swapping to a markdown adapter in Phase 5 will fail because the client UI
    won't know how to render or safely mutate strings like `- [x] ~~Milk~~ (grocery, 2026-04-18)`.
    DISPROOF: Evidence that the JSON model explicitly defines and enforces strict typing for
    provenance, completion_date, quantity, and context_notes rather than just title and is_complete.

[2] SEVERITY: material
    QUOTE: "Given engaged mode is triggered (a hot word, per the notes), when triggered, then the
    shell can switch modes without a layout rebuild... engaged mode is stubbed in Phase 0 (no
    conversation, no voice)."
    PROBLEM: P0-8 mandates that the shell successfully swaps to engaged mode when "triggered (a hot
    word)", but the Phase 0 non-goals explicitly forbid voice, microphones, and assistant
    intelligence. You cannot fulfill or test a "must-have" (P0) requirement triggered by a hot word
    when the mechanism to detect it is structurally banned from the phase.
    DISPROOF: Evidence of a defined, non-voice fallback trigger (like a developer debug button or
    tap gesture on the stubbed Assistant Bar) specified in Phase 0 to test the mode swap.

[3] SEVERITY: material
    QUOTE: "Phase 1 — First vertical slice: Shopping... add/check/clear, respect the SHOPPING.md
    sections + 'Recently Bought' behavior. This validates the whole pipeline..."
    PROBLEM: The verified "clear" behavior is handled by an external async actor (Claude
    auto-clearing after ~7 days), not synchronous client logic. Building a "clear" action against a
    static JSON mock in Phase 1 creates a false sense of validation; it builds client-side mutation
    logic that will immediately clash with the backend's automated sweeps in Phase 5.
    DISPROOF: Evidence that the Phase 1 "clear" logic merely simulates reading a cleared state from
    the mock, rather than implementing a destructive client-side delete function.

[4] SEVERITY: minor
    QUOTE: "The reusable tile... row 4: one glanceable detail line... The tile does not know about
    domain logic — it's a shell that renders whatever the data layer hands it."
    PROBLEM: The verified TASKS.md convention uses bolded titles plus em-dash context (e.g.,
    **Skylight Frame decision** — deliberating buy vs. DIY). Forcing this into a single type.body
    generic detail line will strip the contextual formatting and likely truncate the string,
    rendering complex tasks unreadable at the target 8-foot distance.
    DISPROOF: Mathematical evidence that a 14px type.body font on an 1180px width canvas divided
    into three columns with padding can display 45+ character strings without aggressive,
    context-destroying truncation.

UNSTATED ASSUMPTIONS:
1. The plan assumes that reading/writing to the same markdown files via an iPad app will not
   introduce race conditions with the existing backend automations (e.g., the 10 PM calendar sweep
   or email-in task handler) modifying the file at the same time.
2. It assumes the 1180×820 logical canvas can be fully utilized edge-to-edge without accounting for
   the iOS home indicator safe area at the bottom of the screen, which overlaps the pinned
   Assistant Bar.
3. It assumes that mocking the data layer in JSON is cheaper than writing a basic Regex/Markdown
   parser in Dart, artificially pushing the highest technical risk (parsing string conventions into
   UI models) to the very end of the project (Phase 5).

FRAME CHECK: The proposed solution addresses the problem of "how to build a clean, scalable Flutter
UI framework for a screen," but avoids the actual core problem demonstrated by the evidence. The
unique challenge of this specific project is safely rendering and mutating human-authored, heavily
formatted markdown strings concurrently with an AI agent, which the plan deliberately ignores until
Phase 5 by hiding behind a sanitized JSON abstraction.
```

---

## Correlation (post-hoc — author's read)

Both verdicts: **REVISE.** No RESHAPE — the shape is accepted; the concerns are about faithfulness
to the real data world and Phase-0 testability.

**CORROBORATED (both readers hit the same passage):**

- **C1 — Data model is thinner than the verified reality.** GPT [1] (material) + Gemini [1]
  (blocking). Both quote the "sections + item states" / JSON claim and say it drops provenance,
  completion date, notes/quantity, and task title/context. *Severity conflict: GPT material vs
  Gemini blocking — recorded, not resolved away.*
- **C2 — Engaged-mode trigger can't be tested in Phase 0.** GPT [3] + Gemini [2]. Both quote P0-8
  and note a hot-word trigger is unverifiable when voice is a Phase-0 non-goal. Both propose the
  same fix: a non-voice synthetic trigger (dev button / tap / timer) for Phase 0.
- **C3 — Frame: the plan validates a clean mock UI but defers the real hard problem.** GPT frame
  check + Gemini frame check + Gemini assumption 3 all converge: the strongest evidence supports a
  polished JSON/mock interface, while the project's actual core challenge — faithfully surfacing and
  safely mutating the real formatted-markdown world (concurrently with the AI agent) — is pushed to
  Phase 5.

**LONE-VOICE (kept — historically the ones that matter):**

- **L1 — 6-column growth claim is false.** GPT [4]. Three equal tiles consume all six half-columns;
  a fourth domain can't keep the others' positions in-row, and no wrap/paging/resize rule exists.
  *Self-verifiable arithmetic — the author confirms this is a real error in the seed.*
- **L2 — Always-on wake DoD depends on a deferred mechanism.** GPT [2]. P0-1 + the "10/10 wakes"
  metric assume device behavior whose mechanism (kiosk/keep-awake) is Phase 5.
- **L3 — Phase 1 "clear" is an agent-owned async sweep, not client logic.** Gemini [3]. A
  client-side destructive clear is false validation and will clash with the backend in Phase 5.
- **L4 — Tile glance line strips task title/context and truncates at 8 ft.** Gemini [4] (minor).
- **L5 — Concurrency/race with backend automations** on the shared files. Gemini assumption 1.
- **L6 — iOS safe area / home indicator overlaps the pinned Assistant Bar.** Gemini assumption 2.

**Conflicts:** only the C1 severity split (material vs blocking). No direct contradictions; the two
reads are largely complementary — GPT harder on layout/DoD, Gemini harder on data-fidelity and
concurrency.

---

## Open items (each awaits ACCOMMODATED or ADDRESSED — Matt's call)

| # | Item | Source | Proposed disposition |
|---|------|--------|----------------------|
| OI-1 | Data-layer spec too thin — enumerate real fields (source-list provenance, completion date, notes/qty, task title+context, terminal archive sections) + require lossless round-trip | C1 | **Accommodate** — rewrite PRD P0-5 + seed tile spec |
| OI-2 | P0-8 needs a non-voice synthetic trigger for Phase 0; voice plugs into same interface in Phase 5 | C2 | **Accommodate** — edit P0-8 |
| OI-3 | Correct the "additive split, not a rewrite" grid claim — a 4th domain needs an explicit layout rule | L1 | **Accommodate** — correct seed §6 |
| OI-4 | Scope P0-1's Phase-0 done-ness to app behavior (ambient on resume, no intermediate screen); move physical kiosk wake test to Phase 5 | L2 | **Accommodate** — edit P0-1 + Success Metrics |
| OI-5 | Phase 1 distinguishes user actions (add/check) from agent-owned auto-clear (simulate cleared state, no destructive client sweep); carry write-ownership note to PRD 02 | L3 | **Accommodate (light)** — PROJECT_MAP Phase 1 + PRD 02 flag |
| OI-6 | Tile glance line is a *derived* short summary, not the raw formatted string; full title+context in focused view; note graceful truncation | L4 | **Accommodate (light)** or Address |
| OI-7 | Record concurrency/write-arbitration as an explicit pre-condition for live wiring (§9.3 / Phase 5) | L5 | **Accommodate** — note in open decision |
| OI-8 | Layout respects iOS safe areas, esp. bottom home indicator under the Assistant Bar | L6 | **Accommodate** — note in seed + P0-2/P0-6 |
| OI-9 | **Strategic:** does the real risk (parsing/mutating the formatted markdown) move earlier, or stay deferred? Options: (a) Address — accept clean-shell-first as a valid learning path, record tradeoff; (b) Accommodate — pull the Dart markdown parser into Phase 1 to de-risk early. Legitimately reopens Decision 5 because the *verified data-model richness* is new evidence, not just opinion. | C3 | **Matt decides** |

---

## Closure (2026-08-02) — all items resolved

Every item closed as **ACCOMMODATED** (doc changed). None left as address-only.

| # | Closed as | Where |
|---|-----------|-------|
| OI-1 | ACCOMMODATED — typed model now lossless (real fields + round-trip test) | PRD P0-5 |
| OI-2 | ACCOMMODATED — non-voice synthetic trigger for Phase 0; voice plugs into same interface | PRD P0-8 |
| OI-3 | ACCOMMODATED — false 6-col "free split" claim corrected | seed §6 |
| OI-4 | ACCOMMODATED — P0-1 scoped to app launch/resume; physical wake → Phase 5 | PRD P0-1 + Success Metrics + roadmap Phase 5 |
| OI-5 | ACCOMMODATED — user actions vs agent-owned clear; no destructive client clear | PRD P0-5 + PROJECT_MAP Phase 1 (carry to PRD 02) |
| OI-6 | ACCOMMODATED — glance line is a derived summary; full context in focused view | seed §7 |
| OI-7 | ACCOMMODATED — concurrent-write arbitration recorded as a live-wiring precondition | PRD Open Questions + PROJECT_MAP §9.3 / Phase 5 |
| OI-8 | ACCOMMODATED — layout respects iOS safe areas (home indicator under Assistant Bar) | PRD P0-2 + seed §6 |
| OI-9 | ACCOMMODATED — **Hybrid chosen:** enrich model now; JSON stub in Phase 0; **real Dart parser in Phase 1** against `SHOPPING.md`; parser removed from Phase 5 | PRD P0-5 + PROJECT_MAP Phase 1/5 |

**Severity conflict (C1):** GPT *material* vs Gemini *blocking* — resolved by accommodating fully
either way, so the split didn't need adjudicating.

**New factual claims introduced by the edits, verified (Step 6):** iPad 10th gen has no home button
/ uses a bottom home-indicator safe area (web-verified); agent-owned ~7-day clear (verified in
`SHOPPING.md` Step 2). No edit introduced an unverified world-fact.

**Rejected paths** recorded in PRD 01 `## Rejected ideas` so they can't be re-proposed without new
evidence. Docs exit with no open major items → clear to proceed to PRD 02.
