import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/hub_tokens.dart';

/// One domain tile's *glance contract* (seed §7): an icon + title, one key number in the
/// domain accent, what that number means, and one short derived summary line. Tiles summarise —
/// they never render a raw list on the home screen.
@immutable
class DomainTileData {
  const DomainTileData({
    required this.id,
    required this.title,
    required this.keyNumber,
    required this.keyMeaning,
    required this.glance,
    required this.accent,
    required this.icon,
  });

  /// Stable identity — also the focus-route key. Protect this name (route/config key).
  final String id;
  final String title;
  final String keyNumber; // the one number
  final String keyMeaning; // what the number means
  final String glance; // one derived summary line, never a raw list
  final Color accent;
  final IconData icon;
}

/// Phase-0 seeded tiles — shaped like the household markdown world, NOT wired to it yet
/// (mirrors `SHOPPING.md` / `TASKS.md` conventions; live wiring is a deliberate later phase).
/// Values match the Home Hub design's frame `1a` so the shell can be checked against it.
final homeTilesProvider = Provider<List<DomainTileData>>((ref) {
  return const [
    DomainTileData(
      id: 'shopping',
      title: 'Shopping',
      keyNumber: '3',
      keyMeaning: 'to buy',
      glance: 'Grocery 2 · Household 1',
      accent: HubColors.accentShopping,
      icon: Icons.shopping_bag_outlined,
    ),
    DomainTileData(
      id: 'tasks',
      title: 'Tasks',
      keyNumber: '4',
      keyMeaning: 'to do',
      glance: 'Skylight Frame decision',
      accent: HubColors.accentTasks,
      icon: Icons.checklist_rounded,
    ),
    DomainTileData(
      id: 'mail',
      title: 'Mail & packages',
      keyNumber: '2',
      keyMeaning: 'arriving today',
      glance: 'Package · out for delivery',
      accent: HubColors.accentMail,
      icon: Icons.mail_outline,
    ),
  ];
});

/// Ambient header content. Time is live; weather is a seeded placeholder (no live source yet —
/// surfaced as clearly-mock, per "fail loud while building; degrade gracefully once shipped").
class AmbientHeaderData {
  const AmbientHeaderData._();
  static const String weatherSeed =
      '68° clear'; // MOCK — no weather source wired yet
  static const String wordmark = 'FAMILYHUB';
}
