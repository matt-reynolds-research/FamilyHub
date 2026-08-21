import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/shopping/shopping_model.dart';
import '../../domain/shopping/shopping_mutations.dart';
import '../../domain/shopping/shopping_parser.dart';
import '../../domain/shopping/shopping_repository.dart';

final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  return FixtureShoppingRepository();
});

final shoppingControllerProvider =
    AsyncNotifierProvider<ShoppingController, ShoppingDocument>(
  ShoppingController.new,
);

/// The UI seam for Shopping. It owns only async/session state; all document changes remain
/// pure [ShoppingMutations] so the Assistant Bar can reuse them in Phase 2.
class ShoppingController extends AsyncNotifier<ShoppingDocument> {
  static const _mutations = ShoppingMutations();

  @override
  Future<ShoppingDocument> build() {
    return ref.watch(shoppingRepositoryProvider).load();
  }

  Future<MutationOutcome> add({
    required ShoppingList list,
    required String title,
  }) async {
    final current = state.requireValue;
    final (parsedTitle, note, _) = ShoppingParser.splitNote(title.trim());
    final outcome = _mutations.add(
      current,
      list: list,
      title: parsedTitle,
      note: note,
    );
    if (outcome.applied) await _persist(outcome.document);
    return outcome;
  }

  Future<MutationOutcome> markBought({
    required ShoppingList list,
    required ActiveItem item,
  }) async {
    final current = state.requireValue;
    final outcome = _mutations.markBought(
      current,
      list: list,
      dedupKey: item.dedupKey,
    );
    if (outcome.applied) await _persist(outcome.document);
    return outcome;
  }

  Future<void> _persist(ShoppingDocument document) async {
    await ref.read(shoppingRepositoryProvider).save(document);
    state = AsyncData(document);
  }
}
