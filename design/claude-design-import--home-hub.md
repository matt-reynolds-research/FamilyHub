# Claude Design import — Home Hub (shell) + review

_Imported 2026-08-03 from the Claude Design project into the repo. Source of truth for the
built design; the live project keeps its own version history._

- **Live project:** https://claude.ai/design/p/2c288722-825e-42d1-a378-ea0a9d23749f
- **Imported files (byte-exact):**
  - `FamilyHub Home Hub.dc.html` (50,978 bytes) — the design, a `.dc.html` (Claude Design
    "Design Components" format: `<x-dc>` root, `{{ }}` template vars, `<sc-if>`, `style-hover`).
    The **sphere animation lives in a trailing `<script>`** in this file.
  - `support.js` (69,150 bytes) — the **generic Design-Components runtime** (`dc-runtime`,
    auto-generated). Not app logic; it interprets the `.dc.html`. Not something we port.

## What the design actually contains
It's an **exploration doc, not one screen** — 8 frames across 3 iteration turns:

| Turn | Frames | Idea |
|------|--------|------|
| 1 | `1a` Ambient home · `1b` Assistant Bar (idle/listening/reply) · `1c` Focused tile · `1d` Engaged mode | The original PRD-01 prompt: tile grid + bottom pill, waveform for voice. |
| 2 | `2a` Idle home · `2b` Listening · `2c` Reply | Wireframe-aligned engaged shell; a **particle sphere replaces the waveform**. |
| 3 | `3a` Reactive sphere | **Live amplitude-reactive presence sphere** — clickable states. |

**Latest intent (Turn 3 + Turn 2 layout):** a voice **presence sphere** as the centrepiece of
engaged mode. State is encoded by hue + size/amplitude: listening `#6C7BF0`, speaking `#9B7BF0`,
confirmed `#7FC98A`, failed `#E5726B`, resting `#6F757F`. In a real build the sphere reads a
WebAudio `AnalyserNode` RMS (mic) / TTS level; ~420 points, 60fps.

## Drift from the locked spec (seed v1.1 + PRD 01) — decisions needed
1. **Voice-forward vs. text-first (the big one).** The design centres on a live voice sphere +
   5 voice states. **PRD 01 Phase 0 is explicitly text-first; voice/waveform is Phase 5.** Matt
   drove the sphere evolution himself, so it's clearly wanted — but building it now pulls Phase-5
   work forward and isn't the roadmap's next small step. The **static ambient home (`1a`) + focused
   container (`1c`)** are the true Phase-0 shell and are fully specified here.
2. **Font.** Design uses **Helvetica Neue**; seed/app uses **Inter** (`google_fonts`). Pick one.
3. **New tokens** not in seed v1.1: **`#6C7BF0`** (listening), **`#9B7BF0`** (speaking), and a
   **`#08090B`** page backing behind the `#0D0F12` frames. Fold into the seed, or drop.
4. Everything else matches seed v1.1 (surfaces `#15181D`/`#1E2229`, hairline `#333842`, text ramp,
   accents `#5DCAA5`/`#7F9FF0`/`#EFB45A`, type scale 52/30/16/14/13).

## Recommendation
Build **Phase 0 = the static shell** first (ambient home `1a`: header, 3-tile grid, pinned
Assistant Bar pill, + generic focused container `1c`) — it's the roadmap's next step and is
directly rendered by these frames. Treat the **presence sphere + engaged mode as a Phase-2/5
layer** (mint `#6C7BF0`/`#9B7BF0` into the seed now so it's ready). Font: keep **Inter** unless
Matt prefers Helvetica Neue for the wall look. Awaiting Matt's call on scope + font before writing
the Flutter theme.
