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
    required this.previewLabel,
    required this.previewItems,
  });

  /// Stable identity — also the focus-route key. Protect this name (route/config key).
  final String id;
  final String title;
  final String keyNumber; // the one number
  final String keyMeaning; // what the number means
  final String glance; // one derived summary line, never a raw list
  final Color accent;
  final IconData icon;
  final String previewLabel;
  final List<TilePreviewItem> previewItems;
}

/// A compact, seeded activity signal for the ambient tile and its focused preview.
/// These are intentionally presentation-ready summaries rather than domain models; live
/// domains will derive the same shape from their own repositories in later phases.
@immutable
class TilePreviewItem {
  const TilePreviewItem({
    required this.title,
    required this.meta,
    this.status,
    this.isLate = false,
  });

  final String title;
  final String meta;
  final String? status;
  final bool isLate;
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
      keyMeaning: 'people added items',
      glance: '14 things to buy · 9 added today',
      accent: HubColors.accentShopping,
      icon: Icons.shopping_bag_outlined,
      previewLabel: 'Recently added',
      previewItems: [
        TilePreviewItem(
          title: 'Milk, berries + 6 more',
          meta: 'Alex · today, 7:42 AM',
        ),
        TilePreviewItem(
          title: 'Coffee filters + 3 more',
          meta: 'Matt · yesterday',
        ),
        TilePreviewItem(
          title: 'Lunch bags',
          meta: 'Family · Monday',
        ),
      ],
    ),
    DomainTileData(
      id: 'tasks',
      title: 'Tasks',
      keyNumber: '9',
      keyMeaning: 'tasks remaining',
      glance: 'Alex 4 · Matt 3 · Family 2',
      accent: HubColors.accentTasks,
      icon: Icons.checklist_rounded,
      previewLabel: 'By owner',
      previewItems: [
        TilePreviewItem(
          title: 'Alex · 4 left',
          meta: 'Return library books · added today',
        ),
        TilePreviewItem(
          title: 'Matt · 3 left',
          meta: 'Choose skylight frame · added Tue',
        ),
        TilePreviewItem(
          title: 'Family · 2 left',
          meta: 'Plan Saturday dinner · added Sun',
        ),
      ],
    ),
    DomainTileData(
      id: 'mail',
      title: 'Mail & packages',
      keyNumber: '3',
      keyMeaning: 'deliveries coming',
      glance: '1 today · 1 tomorrow · 1 running late',
      accent: HubColors.accentMail,
      icon: Icons.mail_outline,
      previewLabel: 'Next deliveries',
      previewItems: [
        TilePreviewItem(
          title: 'Kids lunchbox',
          meta: 'Alex · Amazon',
          status: 'Today by 8 PM',
        ),
        TilePreviewItem(
          title: 'Air filters',
          meta: 'Matt · Home Depot',
          status: 'Tomorrow',
        ),
        TilePreviewItem(
          title: 'Birthday gift',
          meta: 'Alex · USPS',
          status: '2 days late',
          isLate: true,
        ),
      ],
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
