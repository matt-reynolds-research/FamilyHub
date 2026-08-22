import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/shopping/shopping_model.dart';
import '../../domain/tasks/task_model.dart';
import '../shopping/shopping_controller.dart';
import '../tasks/task_controller.dart';

enum AssistantDomain { shopping, tasks }

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
    this.activeDomain = AssistantDomain.shopping,
  });

  final bool isEngaged;
  final bool isProcessing;
  final List<AssistantMessage> messages;
  final AssistantDomain activeDomain;

  AssistantState copyWith({
    bool? isEngaged,
    bool? isProcessing,
    List<AssistantMessage>? messages,
    AssistantDomain? activeDomain,
  }) =>
      AssistantState(
        isEngaged: isEngaged ?? this.isEngaged,
        isProcessing: isProcessing ?? this.isProcessing,
        messages: messages ?? this.messages,
        activeDomain: activeDomain ?? this.activeDomain,
      );
}

final assistantControllerProvider =
    NotifierProvider<AssistantController, AssistantState>(
  AssistantController.new,
);

/// Local intent adapter. It is deliberately deterministic and domain-bounded; a future
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
      reply = 'I couldn\'t reach the seeded household lists: $error';
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
    if (_isTaskQuery(lower)) {
      _showDomain(AssistantDomain.tasks);
      return _taskSummary();
    }

    final completedTask = _afterPrefix(lower, const [
      'done with ',
      'complete task ',
      'finish task ',
      'finished ',
    ]);
    if (completedTask != null) {
      _showDomain(AssistantDomain.tasks);
      return _completeTask(completedTask);
    }

    final taskText = _afterPrefix(lower, const [
      'add task ',
      'task: ',
      'todo: ',
    ]);
    if (taskText != null) {
      _showDomain(AssistantDomain.tasks);
      final original = input.substring(input.length - taskText.length).trim();
      final outcome = await ref.read(taskControllerProvider.notifier).add(
            section: TaskSectionKind.open,
            title: original,
          );
      return outcome.message;
    }

    if (_isShoppingQuery(lower)) {
      _showDomain(AssistantDomain.shopping);
      return _shoppingSummary();
    }

    final boughtText = _afterPrefix(lower, const [
      'we got ',
      'we bought ',
      'bought ',
      'got ',
    ]);
    if (boughtText != null) {
      _showDomain(AssistantDomain.shopping);
      return _markBought(boughtText);
    }

    if (lower.startsWith('add ')) {
      _showDomain(AssistantDomain.shopping);
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

    return 'I can help with Shopping and Tasks. Try “add milk”, '
        '“add task call the plumber”, “what tasks are left?”, or '
        '“done with return library books”.';
  }

  bool _isShoppingQuery(String input) =>
      input == 'list' ||
      input.contains('what do we need') ||
      input.contains('what\'s on') ||
      input.contains('what is on') ||
      input.contains('shopping list');

  bool _isTaskQuery(String input) =>
      input == 'tasks' ||
      input == 'task list' ||
      input.contains('what tasks') ||
      input.contains('tasks are left') ||
      input.contains('left to do') ||
      input.contains('todo list') ||
      input.contains('to-do list');

  void _showDomain(AssistantDomain domain) {
    state = state.copyWith(activeDomain: domain);
  }

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

  String _taskSummary() {
    final document = ref.read(taskControllerProvider).requireValue;
    String titles(TaskSectionKind section) {
      final tasks = document.activeTasks(section);
      return tasks.isEmpty
          ? 'nothing'
          : tasks.map((task) => task.title).join(', ');
    }

    return '${document.totalRemaining} tasks remain. '
        'Family: ${titles(TaskSectionKind.family)}. '
        'Open: ${titles(TaskSectionKind.open)}. '
        'Waiting: ${titles(TaskSectionKind.waiting)}. '
        'Someday: ${titles(TaskSectionKind.someday)}.';
  }

  Future<String> _completeTask(String requested) async {
    final document = ref.read(taskControllerProvider).requireValue;
    final taskText = requested.replaceFirst(RegExp(r'^the\s+'), '').trim();
    final key = normalizeTaskKey(taskText);
    final matches =
        document.allActive.where((task) => task.dedupKey == key).toList();
    if (matches.isEmpty) {
      return 'I couldn\'t find an open task matching “$taskText”.';
    }
    if (matches.length > 1) {
      return 'I found multiple tasks matching “$taskText”. Be more specific.';
    }
    final outcome = await ref
        .read(taskControllerProvider.notifier)
        .complete(matches.single);
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
