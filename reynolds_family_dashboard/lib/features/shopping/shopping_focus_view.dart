import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/shopping/shopping_model.dart';
import '../../theme/hub_tokens.dart';
import 'shopping_controller.dart';

class ShoppingFocusView extends ConsumerStatefulWidget {
  const ShoppingFocusView({required this.onBack, super.key});

  final VoidCallback onBack;

  @override
  ConsumerState<ShoppingFocusView> createState() => _ShoppingFocusViewState();
}

class _ShoppingFocusViewState extends ConsumerState<ShoppingFocusView> {
  final _groceryController = TextEditingController();
  final _householdController = TextEditingController();

  @override
  void dispose() {
    _groceryController.dispose();
    _householdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shopping = ref.watch(shoppingControllerProvider);

    return Container(
      decoration: BoxDecoration(
        color: HubColors.raised,
        borderRadius: BorderRadius.circular(HubRadii.screen),
      ),
      padding: const EdgeInsets.all(HubSpace.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ShoppingHeader(onBack: widget.onBack, shopping: shopping),
          const SizedBox(height: HubSpace.zone),
          Expanded(
            child: shopping.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: HubColors.accentShopping,
                ),
              ),
              error: (error, _) => _ShoppingError(error: error),
              data: (document) => _ShoppingLists(
                document: document,
                groceryController: _groceryController,
                householdController: _householdController,
                onAdd: _add,
                onBought: _markBought,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _add(ShoppingList list, TextEditingController controller) async {
    final outcome = await ref
        .read(shoppingControllerProvider.notifier)
        .add(list: list, title: controller.text);
    if (!mounted) return;
    if (outcome.applied) controller.clear();
    _showMessage(outcome.message, success: outcome.applied);
  }

  Future<void> _markBought(ShoppingList list, ActiveItem item) async {
    final outcome = await ref
        .read(shoppingControllerProvider.notifier)
        .markBought(list: list, item: item);
    if (!mounted) return;
    _showMessage(outcome.message, success: outcome.applied);
  }

  void _showMessage(String message, {required bool success}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? HubColors.raised : HubColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _ShoppingHeader extends StatelessWidget {
  const _ShoppingHeader({required this.onBack, required this.shopping});

  final VoidCallback onBack;
  final AsyncValue<ShoppingDocument> shopping;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(HubRadii.tile),
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: HubSpace.sm,
              vertical: HubSpace.xs,
            ),
            child: Row(
              children: [
                Icon(Icons.chevron_left, color: HubColors.textSecondary),
                Text('Home', style: HubType.bodySecondary),
              ],
            ),
          ),
        ),
        const SizedBox(width: HubSpace.tile),
        const Icon(
          Icons.shopping_bag_outlined,
          color: HubColors.accentShopping,
          size: 22,
        ),
        const SizedBox(width: 10),
        const Text('Shopping', style: HubType.keyNumber),
        const Spacer(),
        Text(
          shopping.when(
            data: (document) => '${document.totalToBuy} to buy',
            loading: () => 'Loading…',
            error: (_, __) => 'Unavailable',
          ),
          style: HubType.bodySecondary,
        ),
      ],
    );
  }
}

class _ShoppingLists extends StatelessWidget {
  const _ShoppingLists({
    required this.document,
    required this.groceryController,
    required this.householdController,
    required this.onAdd,
    required this.onBought,
  });

  final ShoppingDocument document;
  final TextEditingController groceryController;
  final TextEditingController householdController;
  final Future<void> Function(
    ShoppingList list,
    TextEditingController controller,
  ) onAdd;
  final Future<void> Function(ShoppingList list, ActiveItem item) onBought;

  @override
  Widget build(BuildContext context) {
    final grocery = document.activeItems(ShoppingList.grocery);
    final household = document.activeItems(ShoppingList.household);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ListColumn(
                  title: 'Grocery',
                  list: ShoppingList.grocery,
                  items: grocery,
                  controller: groceryController,
                  onAdd: onAdd,
                  onBought: onBought,
                ),
              ),
              const SizedBox(width: HubSpace.zone),
              Container(width: 1, color: HubColors.hairline),
              const SizedBox(width: HubSpace.zone),
              Expanded(
                child: _ListColumn(
                  title: 'Household',
                  list: ShoppingList.household,
                  items: household,
                  controller: householdController,
                  onAdd: onAdd,
                  onBought: onBought,
                ),
              ),
            ],
          ),
        ),
        if (document.recentlyBought.isNotEmpty)
          _RecentlyBought(items: document.recentlyBought),
        const SizedBox(height: HubSpace.sm),
        const Text(
          'Seeded working copy · changes last for this app session only',
          style: HubType.caption,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

class _ListColumn extends StatelessWidget {
  const _ListColumn({
    required this.title,
    required this.list,
    required this.items,
    required this.controller,
    required this.onAdd,
    required this.onBought,
  });

  final String title;
  final ShoppingList list;
  final List<ActiveItem> items;
  final TextEditingController controller;
  final Future<void> Function(
    ShoppingList list,
    TextEditingController controller,
  ) onAdd;
  final Future<void> Function(ShoppingList list, ActiveItem item) onBought;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(title, style: HubType.labelPrimary),
            const SizedBox(width: HubSpace.sm),
            Text('· ${items.length}', style: HubType.caption),
          ],
        ),
        const SizedBox(height: HubSpace.tile),
        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text('All caught up', style: HubType.bodyMuted),
                )
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                      Container(height: 1, color: HubColors.hairline),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _ShoppingItemRow(
                      item: item,
                      onBought: () => onBought(list, item),
                    );
                  },
                ),
        ),
        const SizedBox(height: HubSpace.tile),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: HubType.body,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onAdd(list, controller),
                decoration: InputDecoration(
                  hintText: 'Add to ${title.toLowerCase()}',
                  hintStyle: HubType.bodyMuted,
                  filled: true,
                  fillColor: HubColors.tile,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: HubSpace.tile,
                    vertical: HubSpace.sm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(HubRadii.tile),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: HubSpace.sm),
            IconButton.filled(
              tooltip: 'Add to ${title.toLowerCase()}',
              onPressed: () => onAdd(list, controller),
              style: IconButton.styleFrom(
                backgroundColor: HubColors.accentShopping,
                foregroundColor: HubColors.page,
              ),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}

class _ShoppingItemRow extends StatelessWidget {
  const _ShoppingItemRow({required this.item, required this.onBought});

  final ActiveItem item;
  final VoidCallback onBought;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onBought,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: HubSpace.sm),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: Checkbox(
                value: false,
                onChanged: (_) => onBought(),
                side: const BorderSide(color: HubColors.textMuted, width: 1.5),
              ),
            ),
            const SizedBox(width: HubSpace.xs),
            Expanded(
              child: Text(item.itemText, style: HubType.body),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentlyBought extends StatelessWidget {
  const _RecentlyBought({required this.items});

  final List<BoughtItem> items;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: HubSpace.sm),
          iconColor: HubColors.textMuted,
          collapsedIconColor: HubColors.textMuted,
          title: Text(
            'Recently bought · ${items.length}',
            style: HubType.label.copyWith(color: HubColors.textMuted),
          ),
          subtitle: const Text(
            'Read-only · cleared by the Family Assistant',
            style: HubType.caption,
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: HubSpace.gap,
                runSpacing: HubSpace.sm,
                children: [
                  for (final item in items)
                    Text(
                      '${item.title} · ${item.source.token} · ${item.dateStamp}',
                      style: HubType.caption.copyWith(
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShoppingError extends StatelessWidget {
  const _ShoppingError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: HubColors.error, size: 32),
          const SizedBox(height: HubSpace.sm),
          Text(
            'Couldn\'t load shopping',
            style: HubType.body.copyWith(color: HubColors.error),
          ),
          const SizedBox(height: HubSpace.xs),
          Text('$error', style: HubType.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
