import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/shopping/shopping_model.dart';
import '../../theme/hub_tokens.dart';
import '../shopping/shopping_controller.dart';
import 'assistant_controller.dart';

class AssistantBar extends ConsumerStatefulWidget {
  const AssistantBar({super.key});

  @override
  ConsumerState<AssistantBar> createState() => _AssistantBarState();
}

class _AssistantBarState extends ConsumerState<AssistantBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assistant = ref.watch(assistantControllerProvider);
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: HubSpace.sm),
      decoration: BoxDecoration(
        color: HubColors.raised,
        borderRadius: BorderRadius.circular(HubRadii.pill),
        border: Border.all(color: HubColors.hairline),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: HubColors.tile,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_outlined,
              color: HubColors.listening,
              size: 20,
            ),
          ),
          const SizedBox(width: HubSpace.sm),
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !assistant.isProcessing,
              onTap: () =>
                  ref.read(assistantControllerProvider.notifier).engage(),
              onSubmitted: (_) => _submit(),
              textInputAction: TextInputAction.send,
              style: HubType.body,
              decoration: const InputDecoration(
                hintText: 'Add milk · What do we need? · We got eggs',
                hintStyle: HubType.bodyMuted,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: HubSpace.sm),
              ),
            ),
          ),
          if (assistant.isProcessing)
            const Padding(
              padding: EdgeInsets.all(HubSpace.tile),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: HubColors.listening,
                ),
              ),
            )
          else
            IconButton(
              tooltip: 'Send to FamilyHub',
              onPressed: _submit,
              style: IconButton.styleFrom(
                backgroundColor: HubColors.listening,
                foregroundColor: HubColors.textPrimary,
              ),
              icon: const Icon(Icons.arrow_upward_rounded),
            ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final text = _controller.text;
    _controller.clear();
    await ref.read(assistantControllerProvider.notifier).submit(text);
  }
}

class AssistantEngagedView extends ConsumerWidget {
  const AssistantEngagedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assistant = ref.watch(assistantControllerProvider);
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
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: HubColors.listening,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: HubSpace.sm),
              const Text('FamilyHub', style: HubType.labelPrimary),
              const SizedBox(width: HubSpace.sm),
              const Text('Shopping preview', style: HubType.caption),
              const Spacer(),
              TextButton.icon(
                onPressed: () =>
                    ref.read(assistantControllerProvider.notifier).close(),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Back to home'),
                style: TextButton.styleFrom(
                  foregroundColor: HubColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: HubSpace.gap),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _Conversation(messages: assistant.messages),
                ),
                const SizedBox(width: HubSpace.zone),
                Container(width: 1, color: HubColors.hairline),
                const SizedBox(width: HubSpace.zone),
                Expanded(child: _ShoppingGlance(shopping: shopping)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Conversation extends StatelessWidget {
  const _Conversation({required this.messages});

  final List<AssistantMessage> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              color: HubColors.listening,
              size: 36,
            ),
            SizedBox(height: HubSpace.tile),
            Text('What can I help with?', style: HubType.keyNumber),
            SizedBox(height: HubSpace.sm),
            Text(
              'Try “add milk”, “what do we need?”, or “we got the eggs”.',
              style: HubType.bodyMuted,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      reverse: true,
      itemCount: messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: HubSpace.tile),
      itemBuilder: (context, reversedIndex) {
        final message = messages[messages.length - 1 - reversedIndex];
        return Align(
          alignment:
              message.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.symmetric(
              horizontal: HubSpace.gap,
              vertical: HubSpace.tile,
            ),
            decoration: BoxDecoration(
              color: message.isUser ? HubColors.listening : HubColors.tile,
              borderRadius: BorderRadius.circular(HubRadii.tile),
              border:
                  message.isUser ? null : Border.all(color: HubColors.hairline),
            ),
            child: Text(message.text, style: HubType.body),
          ),
        );
      },
    );
  }
}

class _ShoppingGlance extends StatelessWidget {
  const _ShoppingGlance({required this.shopping});

  final AsyncValue<ShoppingDocument> shopping;

  @override
  Widget build(BuildContext context) {
    return shopping.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: HubColors.accentShopping),
      ),
      error: (error, _) => Text('$error', style: HubType.caption),
      data: (document) {
        final grocery = document.activeItems(ShoppingList.grocery);
        final household = document.activeItems(ShoppingList.household);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  color: HubColors.accentShopping,
                ),
                SizedBox(width: HubSpace.sm),
                Text('Shopping', style: HubType.labelPrimary),
              ],
            ),
            const SizedBox(height: HubSpace.zone),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${document.totalToBuy}',
                  style: HubType.keyNumber.copyWith(
                    color: HubColors.accentShopping,
                  ),
                ),
                const SizedBox(width: HubSpace.sm),
                const Text('things to buy', style: HubType.bodySecondary),
              ],
            ),
            const SizedBox(height: HubSpace.zone),
            Text('Grocery · ${grocery.length}', style: HubType.eyebrow),
            const SizedBox(height: HubSpace.sm),
            Text(
              grocery.map((item) => item.itemText).join(' · '),
              style: HubType.bodySecondary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: HubSpace.zone),
            Text('Household · ${household.length}', style: HubType.eyebrow),
            const SizedBox(height: HubSpace.sm),
            Text(
              household.map((item) => item.itemText).join(' · '),
              style: HubType.bodySecondary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }
}
