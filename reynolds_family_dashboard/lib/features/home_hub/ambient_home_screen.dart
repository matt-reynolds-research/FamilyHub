import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../theme/hub_tokens.dart';
import '../../domain/shopping/shopping_model.dart';
import '../../domain/tasks/task_model.dart';
import '../assistant/assistant_controller.dart';
import '../assistant/assistant_surface.dart';
import '../shopping/shopping_controller.dart';
import '../shopping/shopping_focus_view.dart';
import '../tasks/task_controller.dart';
import '../tasks/task_focus_view.dart';
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
    final shopping = ref.watch(shoppingControllerProvider);
    final tasks = ref.watch(taskControllerProvider);
    final assistant = ref.watch(assistantControllerProvider);
    final liveTiles = [
      _shoppingTile(tiles.first, shopping),
      _tasksTile(tiles[1], tasks),
      ...tiles.skip(2),
    ];
    final focused = _focusedTileId == null
        ? null
        : liveTiles.firstWhere((t) => t.id == _focusedTileId);

    return Scaffold(
      backgroundColor: HubColors.page,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(HubSpace.margin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: assistant.isEngaged
                    ? const AssistantEngagedView()
                    : focused == null
                        ? _AmbientBody(
                            now: _now,
                            tiles: liveTiles,
                            onOpen: (id) => setState(() => _focusedTileId = id),
                          )
                        : focused.id == 'shopping'
                            ? ShoppingFocusView(
                                onBack: () =>
                                    setState(() => _focusedTileId = null),
                              )
                            : focused.id == 'tasks'
                                ? TaskFocusView(
                                    onBack: () =>
                                        setState(() => _focusedTileId = null),
                                  )
                                : _FocusedContainer(
                                    tile: focused,
                                    onBack: () =>
                                        setState(() => _focusedTileId = null),
                                  ),
              ),
              const SizedBox(height: HubSpace.zone),
              const AssistantBar(),
            ],
          ),
        ),
      ),
    );
  }

  DomainTileData _tasksTile(
    DomainTileData seed,
    AsyncValue<TaskDocument> tasks,
  ) {
    return tasks.when(
      loading: () => seed.copyWith(
        keyNumber: '—',
        keyMeaning: 'loading tasks',
        glance: 'Reading the seeded working copy…',
        previewItems: const [],
      ),
      error: (error, _) => seed.copyWith(
        keyNumber: '!',
        keyMeaning: 'couldn\'t load tasks',
        glance: '$error',
        previewItems: const [],
      ),
      data: (document) {
        final family = document.activeTasks(TaskSectionKind.family);
        final open = document.activeTasks(TaskSectionKind.open);
        final waiting = document.activeTasks(TaskSectionKind.waiting);
        final recent = document.allActive
            .where((task) => task.addedDate != null)
            .toList()
          ..sort((a, b) => b.addedDate!.compareTo(a.addedDate!));
        return seed.copyWith(
          keyNumber: '${document.totalRemaining}',
          keyMeaning: 'tasks remaining',
          glance:
              'Family ${family.length} · Open ${open.length} · Waiting ${waiting.length}',
          previewLabel: 'Recently added',
          previewItems: [
            for (final task in recent.take(3))
              TilePreviewItem(
                title: task.title,
                meta:
                    'Added by ${task.addedBy ?? 'unknown'} · ${DateFormat('MMM d').format(task.addedDate!)}',
              ),
          ],
        );
      },
    );
  }

  DomainTileData _shoppingTile(
    DomainTileData seed,
    AsyncValue<ShoppingDocument> shopping,
  ) {
    return shopping.when(
      loading: () => seed.copyWith(
        keyNumber: '—',
        keyMeaning: 'loading shopping',
        glance: 'Reading the seeded working copy…',
        previewItems: const [],
      ),
      error: (error, _) => seed.copyWith(
        keyNumber: '!',
        keyMeaning: 'couldn\'t load shopping',
        glance: '$error',
        previewItems: const [],
      ),
      data: (document) {
        final grocery = document.activeItems(ShoppingList.grocery);
        final household = document.activeItems(ShoppingList.household);
        final preview = <TilePreviewItem>[
          for (final item in grocery.take(2))
            TilePreviewItem(
              title: item.itemText,
              meta: 'Grocery · no author/date',
            ),
          for (final item in household.take(1))
            TilePreviewItem(
              title: item.itemText,
              meta: 'Household · no author/date',
            ),
        ];
        return seed.copyWith(
          keyNumber: '${document.totalToBuy}',
          keyMeaning: 'things to buy',
          glance: 'Grocery ${grocery.length} · Household ${household.length}',
          previewLabel: 'On the list',
          previewItems: preview,
        );
      },
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

/// A single glanceable domain tile. The headline orients from across the room; compact seeded
/// activity rows add ownership and recency for someone passing close enough to follow up.
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
              const SizedBox(height: HubSpace.zone),
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
              const SizedBox(height: HubSpace.gap),
              Container(height: 1, color: HubColors.hairline),
              const SizedBox(height: HubSpace.tile),
              Text(data.previewLabel.toUpperCase(), style: HubType.eyebrow),
              const SizedBox(height: HubSpace.sm),
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < data.previewItems.length; i++) ...[
                      _PreviewRow(item: data.previewItems[i]),
                      if (i < data.previewItems.length - 1)
                        const SizedBox(height: HubSpace.tile),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.item, this.expanded = false});

  final TilePreviewItem item;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: (expanded ? HubType.body : HubType.label)
                    .copyWith(color: HubColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: HubSpace.xs),
              Text(
                item.meta,
                style: HubType.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (item.status != null) ...[
          const SizedBox(width: HubSpace.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item.isLate
                  ? HubColors.error.withValues(alpha: 0.12)
                  : HubColors.tile,
              borderRadius: BorderRadius.circular(HubRadii.pill),
              border: Border.all(
                color: item.isLate ? HubColors.error : HubColors.hairline,
              ),
            ),
            child: Text(
              item.status!,
              style: HubType.caption.copyWith(
                color: item.isLate ? HubColors.error : HubColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
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
          const SizedBox(height: HubSpace.zone),
          Text(tile.glance,
              style: HubType.body.copyWith(color: HubColors.textSecondary)),
          const SizedBox(height: HubSpace.zone),
          Text(tile.previewLabel.toUpperCase(), style: HubType.eyebrow),
          const SizedBox(height: HubSpace.gap),
          for (var i = 0; i < tile.previewItems.length; i++) ...[
            _PreviewRow(item: tile.previewItems[i], expanded: true),
            if (i < tile.previewItems.length - 1) ...[
              const SizedBox(height: HubSpace.gap),
              Container(height: 1, color: HubColors.hairline),
              const SizedBox(height: HubSpace.gap),
            ],
          ],
          const Spacer(),
          const Text(
            'Seeded preview · live household data is not connected',
            style: HubType.caption,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
