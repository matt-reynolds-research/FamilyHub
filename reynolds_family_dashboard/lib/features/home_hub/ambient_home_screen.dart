import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../theme/hub_tokens.dart';
import 'home_hub_models.dart';

/// The Home Hub shell — Phase 0. The always-on frame that domain tiles plug into: a header,
/// the 3-tile ambient grid, a generic focused-tile container, and the pinned Assistant Bar pill.
/// This is the *stage*, not the play: tiles summarise seeded data; the focus view is a generic
/// container; the bar is a reserved, inert shell element. Voice / presence-sphere / engaged mode
/// are a later layer (see `design/claude-design-import--home-hub.md`).
class AmbientHomeScreen extends ConsumerStatefulWidget {
  const AmbientHomeScreen({super.key});

  @override
  ConsumerState<AmbientHomeScreen> createState() => _AmbientHomeScreenState();
}

class _AmbientHomeScreenState extends ConsumerState<AmbientHomeScreen> {
  /// null → ambient home; a tile id → that tile's generic focused container. Protect this key.
  String? _focusedTileId;
  late DateTime _now;
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    // Always-on surface: keep the clock honest without a heavy rebuild loop.
    _clock = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tiles = ref.watch(homeTilesProvider);
    final focused = _focusedTileId == null
        ? null
        : tiles.firstWhere((t) => t.id == _focusedTileId);

    return Scaffold(
      backgroundColor: HubColors.page,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(HubSpace.margin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: focused == null
                    ? _AmbientBody(
                        now: _now,
                        tiles: tiles,
                        onOpen: (id) => setState(() => _focusedTileId = id),
                      )
                    : _FocusedContainer(
                        tile: focused,
                        onBack: () => setState(() => _focusedTileId = null),
                      ),
              ),
              const SizedBox(height: HubSpace.zone),
              const _AssistantBar(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ambient home: header zone + the 3-tile grid.
class _AmbientBody extends StatelessWidget {
  const _AmbientBody(
      {required this.now, required this.tiles, required this.onOpen});

  final DateTime now;
  final List<DomainTileData> tiles;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(now: now),
        const SizedBox(height: HubSpace.zone),
        Expanded(
          child: Row(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) const SizedBox(width: HubSpace.gap),
                Expanded(
                    child: _DomainTile(
                        data: tiles[i], onTap: () => onOpen(tiles[i].id))),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.now});
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final clock = DateFormat('h:mm').format(now);
    final date = DateFormat('EEEE, MMMM d').format(now);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(clock, style: HubType.hero),
            const SizedBox(height: HubSpace.xs),
            Text(date,
                style: HubType.body.copyWith(color: HubColors.textSecondary)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(AmbientHeaderData.wordmark, style: HubType.wordmark),
            const SizedBox(height: HubSpace.sm),
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                      color: HubColors.accentMail, shape: BoxShape.circle),
                ),
                const SizedBox(width: HubSpace.sm),
                Text(AmbientHeaderData.weatherSeed,
                    style:
                        HubType.body.copyWith(color: HubColors.textSecondary)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// A single glanceable domain tile. Icon + title, one key number in the domain accent, its
/// meaning, and a single derived summary line. It never shows a raw list.
class _DomainTile extends StatelessWidget {
  const _DomainTile({required this.data, required this.onTap});
  final DomainTileData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: HubColors.tile,
      borderRadius: BorderRadius.circular(HubRadii.tile),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(HubRadii.tile),
        child: Container(
          padding: const EdgeInsets.all(HubSpace.margin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(HubRadii.tile),
            border: Border.all(color: HubColors.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(data.icon, color: data.accent, size: 22),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(data.title,
                        style: HubType.label
                            .copyWith(color: HubColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(data.keyNumber,
                      style: HubType.keyNumber.copyWith(color: data.accent)),
                  const SizedBox(width: HubSpace.sm),
                  Flexible(
                    child: Text(data.keyMeaning,
                        style: HubType.body
                            .copyWith(color: HubColors.textSecondary),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: HubSpace.xs),
              Text(data.glance,
                  style: HubType.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

/// The shell's generic focus container — domain-agnostic. Tapping a tile expands it onto the
/// raised surface with an obvious way back. What fills it is a *domain's* job (later phases);
/// here it fails loud as an explicit placeholder rather than faking content.
class _FocusedContainer extends StatelessWidget {
  const _FocusedContainer({required this.tile, required this.onBack});
  final DomainTileData tile;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HubColors.raised,
        borderRadius: BorderRadius.circular(HubRadii.screen),
      ),
      padding: const EdgeInsets.all(HubSpace.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(HubRadii.tile),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: HubSpace.sm, vertical: HubSpace.xs),
                  child: Row(
                    children: [
                      const Icon(Icons.chevron_left,
                          color: HubColors.textSecondary),
                      Text('Home',
                          style: HubType.body
                              .copyWith(color: HubColors.textSecondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: HubSpace.tile),
              Icon(tile.icon, color: tile.accent, size: 22),
              const SizedBox(width: 10),
              Flexible(
                child: Text(tile.title,
                    style: HubType.keyNumber
                        .copyWith(color: HubColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Focused view',
                      style:
                          HubType.label.copyWith(color: HubColors.textMuted)),
                  const SizedBox(height: HubSpace.sm),
                  Text('${tile.title} content plugs in here',
                      style: HubType.caption),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The Assistant Bar — the pinned "front door". Always present and visually prominent (not a
/// footer), reserved even while stubbed. Inert in Phase 0; wiring is a later phase.
class _AssistantBar extends StatelessWidget {
  const _AssistantBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: HubSpace.gap),
      decoration: BoxDecoration(
        color: HubColors.raised,
        borderRadius: BorderRadius.circular(HubRadii.pill),
        border: Border.all(color: HubColors.hairline),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
                color: HubColors.tile, shape: BoxShape.circle),
            child: const Icon(Icons.mic_none,
                color: HubColors.textSecondary, size: 20),
          ),
          const SizedBox(width: HubSpace.tile),
          Flexible(
            child: Text("Ask me anything — 'add milk…'",
                style: HubType.body.copyWith(color: HubColors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
