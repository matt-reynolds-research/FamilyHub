# Project Best Practices Framework

**TL;DR:** Establish immutable sources of truth, enforce strict boundaries between planning and execution, test only against disposable states, and build tripwires to ensure silent failures fail loud.

## I. Structural Authority & Sources of Truth

*   **Define the North Star:** Anchor the project with an immutable product overview document. This dictates prioritization and scope. Read it before altering functionality or writing user-facing copy.
*   **Lexicon Strictness:** Establish exact naming conventions for prose, codebase identifiers, and infrastructure slugs. Do not normalize or batch-replace across these boundaries. Protect core identifiers (like storage keys or route slugs) from arbitrary cleanup.
*   **Document Hierarchy:** 
    *   Maintain a strict separation between active documentation and archives.
    *   Consolidate all open work into a single, chronological tracker (e.g., `TODOS.md`). 
    *   Treat the package manager manifest or dependency lockfile as the absolute authority on stack versions, superseding written documentation if drift occurs.
*   **Comment Contracts:** If a comment or specification document dictates semantics (e.g., "gates on X condition"), the code must implement it exactly. If the logic changes, the comment updates in the same commit.

## II. Execution & Workflow Protocols

*   **Strategic Gatekeeping:** Evaluate every request against the project's long-term objectives. If the logic is flawed, targets are unrealistic, or context is missing, halt execution. Challenge assumptions and point out friction points before writing code.
*   **The 1% Rule:** Break massive overhauls into the smallest possible, repeatable, low-burnout steps. Focus on immediate, incremental execution.
*   **Environment Isolation:** Planning lives in one mental or physical sandbox; execution (code generation) lives in another. Never cross-contaminate code repositories with uncommitted planning artifacts. 
*   **Commit Rituals:** Automate document saving to prevent local state loss. Planning documents must be committed the moment they are written. Use scripts to sync, rebase, and clear lockfiles automatically.

## III. Correctness & Defense

*   **Fail Loud:** Divergence without errors is a critical threat. Missing data stamps do not mean "clean" or "default"; they mean "unknown." Degrade gracefully in production, but throw hard errors in development and CI.
*   **The Inverse Test:** A red test turning green is incomplete. Write a companion test for the adjacent invariant the fix could break. Prove the new logic does not admit or exclude the wrong data.
*   **Tripwires for Impossible States:** When a bug produces an impossible database or application state, write a sanity-check script to detect it going forward.
*   **Disposable Verification:** Default to seeded, mock testing environments for manual, visual, or state verification. Never authenticate or test against production user data. 

## IV. AI Context Hygiene 

*   **One Job per Session:** Start a fresh session for a genuinely new task. A short, clean context is the most reliable state. Do not extend a mega-thread.
*   **Externalize Durable Facts:** Architecture decisions, stack constraints, and project rules belong in a root instruction file. Re-read them every turn; do not rely on conversation memory.
*   **Break at the Seams:** Monitor task structures. When a self-contained unit of work closes and the next task is independent, checkpoint the progress, summarize the state, and hand off to a fresh session before context erosion degrades reasoning.
