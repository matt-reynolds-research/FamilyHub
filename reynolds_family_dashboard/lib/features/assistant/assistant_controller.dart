import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/shopping/shopping_model.dart';
import '../shopping/shopping_controller.dart';

class AssistantMessage {
  const AssistantMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}

class AssistantState {
  const AssistantState({
    this.isEngaged = false,
    this.isProcessing = false,
    this.messages = const [],
  });

  final bool isEngaged;
  final bool isProcessing;
  final List<AssistantMessage> messages;

  AssistantState copyWith({
    bool? isEngaged,
    bool? isProcessing,
    List<AssistantMessage>? messages,
  }) =>
      AssistantState(
        isEngaged: isEngaged ?? this.isEngaged,
        isProcessing: isProcessing ?? this.isProcessing,
        messages: messages ?? this.messages,
      );
}

final assistantControllerProvider =
    NotifierProvider<AssistantController, AssistantState>(
  AssistantController.new,
);

/// Phase-2 local intent adapter. It is deliberately deterministic and Shopping-only; a future
/// transport to the live Family Assistant replaces this seam without changing the surface.
class AssistantController extends Notifier<AssistantState> {
  @override
  AssistantState build() => const AssistantState();

  void engage() => state = state.copyWith(isEngaged: true);

  void close() => state = state.copyWith(isEngaged: false);

  Future<void> submit(String input) async {
    final text = input.trim();
    if (text.isEmpty || state.isProcessing) return;

    state = state.copyWith(
      isEngaged: true,
      isProcessing: true,
      messages: [
        ...state.messages,
        AssistantMessage(text: text, isUser: true),
      ],
    );

    String reply;
    try {
      reply = await _handle(text);
    } catch (error) {
      reply = 'I couldn\'t reach the seeded Shopping list: $error';
    }

    state = state.copyWith(
      isProcessing: false,
      messages: [
        ...state.messages,
        AssistantMessage(text: reply, isUser: false),
      ],
    );
  }

  Future<String> _handle(String input) async {
    final lower = input.toLowerCase().trim();
    if (_isQuery(lower)) return _shoppingSummary();

    final boughtText = _afterPrefix(lower, const [
      'we got ',
      'we bought ',
      'bought ',
      'got ',
    ]);
    if (boughtText != null) return _markBought(boughtText);

    if (lower.startsWith('add ')) {
      var item = input.substring(4).trim();
      var list = ShoppingList.grocery;
      final householdSuffix = RegExp(
        r'\s+(?:to\s+)?(?:the\s+)?household(?:\s+list)?$',
        caseSensitive: false,
      );
      final grocerySuffix = RegExp(
        r'\s+(?:to\s+)?(?:the\s+)?grocery(?:\s+list)?$',
        caseSensitive: false,
      );
      if (householdSuffix.hasMatch(item)) {
        list = ShoppingList.household;
        item = item.replaceFirst(householdSuffix, '').trim();
      } else if (grocerySuffix.hasMatch(item)) {
        item = item.replaceFirst(grocerySuffix, '').trim();
      }
      final outcome = await ref
          .read(shoppingControllerProvider.notifier)
          .add(list: list, title: item);
      return outcome.message;
    }

    return 'I can help with Shopping right now. Try “add milk”, '
        '“what do we need?”, or “we got the eggs”.';
  }

  bool _isQuery(String input) =>
      input == 'list' ||
      input.contains('what do we need') ||
      input.contains('what\'s on') ||
      input.contains('what is on') ||
      input.contains('shopping list');

  String _shoppingSummary() {
    final document = ref.read(shoppingControllerProvider).requireValue;
    final grocery = document.activeItems(ShoppingList.grocery);
    final household = document.activeItems(ShoppingList.household);
    final groceryText = grocery.isEmpty
        ? 'nothing'
        : grocery.map((item) => item.itemText).join(', ');
    final householdText = household.isEmpty
        ? 'nothing'
        : household.map((item) => item.itemText).join(', ');
    return '${document.totalToBuy} things left. Grocery: $groceryText. '
        'Household: $householdText.';
  }

  Future<String> _markBought(String requested) async {
    final document = ref.read(shoppingControllerProvider).requireValue;
    final itemText = requested.replaceFirst(RegExp(r'^the\s+'), '').trim();
    final key = normalizeDedupKey(itemText);
    final matches = <(ShoppingList, ActiveItem)>[
      for (final list in ShoppingList.values)
        for (final item in document.activeItems(list))
          if (item.dedupKey == key) (list, item),
    ];
    if (matches.isEmpty) {
      return 'I couldn\'t find “$itemText” on either Shopping list.';
    }
    if (matches.length > 1) {
      return '“$itemText” appears on both lists. Tell me Grocery or Household.';
    }
    final match = matches.single;
    final outcome = await ref
        .read(shoppingControllerProvider.notifier)
        .markBought(list: match.$1, item: match.$2);
    return outcome.message;
  }

  String? _afterPrefix(String input, List<String> prefixes) {
    for (final prefix in prefixes) {
      if (input.startsWith(prefix)) {
        return input.substring(prefix.length).trim();
      }
    }
    return null;
  }
}
