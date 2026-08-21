# agent (historical prototype)

> **Not wired into FamilyHub.** Phase 2 was implemented in the main app with a deterministic,
> Shopping-only intent adapter so the surface does not create a second household brain or require
> an API key. This package remains only as reference for the earlier bar/history concept.

A local Flutter package used by the FamilyHub dashboard. It provides the AI assistant
layer: the "terminal" chat bar pinned to the bottom of the app and the Gemini-powered
conversation behind it.

## What it exports

- **`AgentTerminalBar`** — the on-screen chat input bar and message history sheet.
- **`GeminiService`** — talks to Google's Gemini API.
- **`ChatProvider`** — Riverpod state for the conversation.

## Usage

The main app depends on this package via a path reference in its `pubspec.yaml`
(`agent: { path: ../Agent }`) and drops the bar into the app shell:

```dart
import 'package:agent/agent.dart';

// inside the app's layout:
const AgentTerminalBar();
```

Requires a `GEMINI_API_KEY` in the app's `.env` (see the top-level README).

This package is internal to FamilyHub and is not intended for pub.dev.
