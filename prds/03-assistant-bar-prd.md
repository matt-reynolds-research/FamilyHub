# PRD 03 — Assistant Bar v1 (Shopping only)

_FamilyHub · Phase 2 · Status: **Locked (2026-08-21)** · Last updated 2026-08-21_
_Depends on: [PRD 01 — Home Hub](01-home-hub-prd.md) and [PRD 02 — Shopping](02-shopping-prd.md), both implemented._

## TL;DR

The Assistant Bar is FamilyHub's conversational front door. V1 proves the interaction against one
working domain—Shopping—using typed, deterministic commands and the same controller as touch. It does
not call a model, listen to voice, or create a second household brain. The bar expands into a calm
conversation canvas, confirms what changed, and returns to the ambient household view on close.

## Product job

A family member should be able to change altitude without changing apps: glance at the household,
then type a natural Shopping request and immediately see the result reflected in the shared surface.
The exchange should feel like addressing the home, not operating a command line.

## Goals

1. Make the persistent bar genuinely interactive without changing its place in the shell.
2. Support Shopping's three useful intents: add, list/query, and mark bought.
3. Reuse Shopping's existing controller and pure mutations—touch and conversation must never diverge.
4. Demonstrate ambient → engaged → ambient as one coherent surface transition.
5. Fail honestly and helpfully when a request is unsupported or ambiguous.

## Non-goals

- No microphone, wake word, speech-to-text, waveform, or silence timeout. Voice remains Phase 5.
- No hosted/on-device model call and no API key. V1 is deterministic and free.
- No Tasks, packages, calendar, or general knowledge. Those domains are added one at a time.
- No connection to the live Family Assistant runtime or household files. Seeded Shopping only.
- No claim that this local intent adapter is the household brain. It is a replaceable surface seam.

## Experience

### Ambient entry

- The bottom pill becomes a real text field with a send affordance.
- Focusing or submitting it moves the surface into engaged mode.
- Placeholder examples set honest scope: “add milk · what do we need? · we got eggs”.

### Engaged mode

- The conversation occupies the main canvas using the existing dark design system.
- A compact Shopping status panel remains visible so results can be checked at a glance.
- User messages and FamilyHub replies are visually distinct and legible at wall distance.
- An obvious close action returns to ambient mode; Shopping changes remain visible there.
- The latest reply is concise and action-oriented—confirmation first, explanation only when needed.

### Supported intents

- **Add:** “add milk”, “add paper towels to household”. Default list is Grocery unless the request
  explicitly says Household.
- **Query:** “what do we need?”, “what's on the shopping list?” Returns Grocery and Household items.
- **Bought:** “we got milk”, “bought paper towels”. Matches the same dedup key as touch. If an item is
  missing or ambiguous, no mutation occurs and the reply explains what to try.
- **Unsupported:** calmly states the current Shopping-only scope and offers examples.

## Data and architecture

- Reads and writes `shoppingControllerProvider`; never duplicates Shopping mutation logic.
- Conversation state is in-memory and resets with the app session, matching the fixture repository.
- The intent adapter is deterministic and isolated behind one controller so a future connection to the
  real Family Assistant can replace it without redesigning the bar or engaged canvas.
- The retained `Agent/` package is not wired: its Gemini service is stubbed, its palette is obsolete,
  and direct model ownership conflicts with the one-World/same-brain architecture.

## Done when

- Add, query, and bought requests produce correct replies and Shopping document changes.
- Unsupported and missing-item requests never mutate data.
- A conversational mutation immediately updates the ambient Shopping tile and focused touch view.
- The surface can enter and leave engaged mode without losing Shopping or conversation state.
- Widget tests cover the three intents, unsupported input, and ambient return; analysis and full tests pass.

## Deferred decisions

- The transport/API that connects the Assistant Bar to the live Family Assistant.
- Model choice, cost, and privacy—only relevant if deterministic/local handling is insufficient.
- Voice trigger, listening/speaking states, silence timeout, and presence sphere (Phase 5).
- Whether Calendar joins the engaged sidebar as a future domain.
