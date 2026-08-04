import 'package:flutter/material.dart';

/// FamilyHub Home Hub design system — v1.2 (Flutter mirror of `design/design-system-seed.md`).
///
/// Why this exists as a *new* file (not an edit to [AppColors]): the prior app ships a light,
/// arm's-length palette (`app_colors.dart`) still referenced by the old tab shell. Phase 0
/// reshapes the app onto the seed's dark, distance-legible tokens; introducing them here keeps
/// the reshape non-breaking while the old shell is pruned in a follow-up. Trust `pubspec.yaml`
/// for the stack; trust this file + the seed doc for the visual contract.
///
/// v1.2 deltas from seed v1.1 (both folded back into `design/design-system-seed.md`):
///  - Typeface Inter → **Helvetica Neue** (Matt's call, 2026-08-03 — reads better on the wall).
///  - New voice-state tokens from the Home Hub design: [listening], [speaking].
///  - New [pageBacking] (`#08090B`) — the space *behind* the `#0D0F12` frames.
class HubColors {
  HubColors._();

  // Surface steps (depth is surface steps + a 1px hairline — no drop shadows).
  static const Color pageBacking = Color(0xFF08090B); // behind the frame
  static const Color page = Color(0xFF0D0F12); // frame / screen background
  static const Color tile = Color(0xFF15181D); // tile surface
  static const Color raised = Color(0xFF1E2229); // focused tile / bars
  static const Color hairline = Color(0xFF333842);

  // Text ramp.
  static const Color textPrimary = Color(0xFFE7E9EE);
  static const Color textSecondary = Color(0xFF9AA0AB);
  static const Color textMuted = Color(0xFF6F757F);

  // Domain accents — used only for meaning (icon + the one key number), never decoration.
  static const Color accentShopping = Color(0xFF5DCAA5); // teal
  static const Color accentTasks = Color(0xFF7F9FF0); // blue
  static const Color accentMail = Color(0xFFEFB45A); // amber

  // Status.
  static const Color error = Color(0xFFE5726B); // muted coral
  static const Color success = Color(0xFF7FC98A); // leafy green

  // Voice-state accents (Home Hub presence sphere — reserved for the Phase-2/5 engaged layer).
  static const Color listening = Color(0xFF6C7BF0); // indigo blue
  static const Color speaking = Color(0xFF9B7BF0); // indigo purple
}

/// Type scale — glanceable-first, two weights only (400 regular, 500 medium), sentence case.
/// Family is Helvetica Neue (a system face on the iPad target — no bundled asset needed).
class HubType {
  HubType._();

  static const String family = 'Helvetica Neue';

  static const TextStyle hero = TextStyle(
      fontFamily: family,
      fontSize: 52,
      height: 1.2,
      fontWeight: FontWeight.w500,
      color: HubColors.textPrimary,
      letterSpacing: -0.5);

  static const TextStyle keyNumber = TextStyle(
      fontFamily: family,
      fontSize: 30,
      height: 1.2,
      fontWeight: FontWeight.w500,
      color: HubColors.textPrimary);

  static const TextStyle body = TextStyle(
      fontFamily: family,
      fontSize: 16,
      height: 1.4,
      fontWeight: FontWeight.w400,
      color: HubColors.textPrimary);

  static const TextStyle label = TextStyle(
      fontFamily: family,
      fontSize: 14,
      height: 1.4,
      fontWeight: FontWeight.w500,
      color: HubColors.textSecondary);

  static const TextStyle caption = TextStyle(
      fontFamily: family,
      fontSize: 13,
      height: 1.4,
      fontWeight: FontWeight.w400,
      color: HubColors.textMuted);

  /// Subtle wordmark — the one place letter-spacing goes wide.
  static const TextStyle wordmark = TextStyle(
      fontFamily: family,
      fontSize: 13,
      height: 1.4,
      fontWeight: FontWeight.w500,
      color: HubColors.textMuted,
      letterSpacing: 2.4);
}

/// Spacing scale (base 4). Airy over dense — whitespace is a feature on a wall.
class HubSpace {
  HubSpace._();
  static const double xs = 4;
  static const double sm = 8;
  static const double tile = 12; // default tile padding token
  static const double gap = 16; // gaps between tiles
  static const double margin = 20; // screen margin
  static const double zone = 32; // major zone breaks
}

/// Radii.
class HubRadii {
  HubRadii._();
  static const double tile = 12;
  static const double screen = 18;
  static const double pill = 999;
}
