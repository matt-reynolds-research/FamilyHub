import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reynolds_family_dashboard/domain/shopping/shopping_model.dart';
import 'package:reynolds_family_dashboard/domain/shopping/shopping_repository.dart';
import 'package:reynolds_family_dashboard/features/assistant/assistant_controller.dart';
import 'package:reynolds_family_dashboard/features/shopping/shopping_controller.dart';

const fixture = '''# Shopping

## Grocery

- [ ] Pasta
- [ ] Milk (2 gallons)

## Household

- [ ] Paper towels

## Recently Bought

''';

void main() {
  Future<ProviderContainer> containerWithShopping() async {
    final repository = FixtureShoppingRepository(
      loadAsset: (_) async => fixture,
    );
    final container = ProviderContainer(
      overrides: [
        shoppingRepositoryProvider.overrideWithValue(repository),
      ],
    );
    await container.read(shoppingControllerProvider.future);
    return container;
  }

  test('add defaults to Grocery and can target Household', () async {
    final container = await containerWithShopping();
    addTearDown(container.dispose);
    final assistant = container.read(assistantControllerProvider.notifier);

    await assistant.submit('add Eggs');
    await assistant.submit('add Dish soap to household');

    final shopping = container.read(shoppingControllerProvider).requireValue;
    expect(
      shopping.activeItems(ShoppingList.grocery).map((item) => item.title),
      contains('Eggs'),
    );
    expect(
      shopping.activeItems(ShoppingList.household).map((item) => item.title),
      contains('Dish soap'),
    );
    expect(
      container.read(assistantControllerProvider).messages.last.text,
      'Added to household: Dish soap',
    );
  });

  test('query summarizes both Shopping lists without mutation', () async {
    final container = await containerWithShopping();
    addTearDown(container.dispose);

    await container
        .read(assistantControllerProvider.notifier)
        .submit('What do we need?');

    final reply =
        container.read(assistantControllerProvider).messages.last.text;
    expect(reply, contains('3 things left'));
    expect(reply, contains('Grocery: Pasta, Milk (2 gallons)'));
    expect(reply, contains('Household: Paper towels'));
  });

  test('bought moves the matching item into Recently Bought', () async {
    final container = await containerWithShopping();
    addTearDown(container.dispose);

    await container
        .read(assistantControllerProvider.notifier)
        .submit('we got the pasta');

    final shopping = container.read(shoppingControllerProvider).requireValue;
    expect(
      shopping.activeItems(ShoppingList.grocery).map((item) => item.title),
      isNot(contains('Pasta')),
    );
    expect(
        shopping.recentlyBought.map((item) => item.title), contains('Pasta'));
  });

  test('unsupported input is helpful and never mutates Shopping', () async {
    final container = await containerWithShopping();
    addTearDown(container.dispose);
    final before =
        container.read(shoppingControllerProvider).requireValue.totalToBuy;

    await container
        .read(assistantControllerProvider.notifier)
        .submit('When is the lunchbox arriving?');

    final assistant = container.read(assistantControllerProvider);
    expect(assistant.messages.last.text, contains('Shopping right now'));
    expect(
      container.read(shoppingControllerProvider).requireValue.totalToBuy,
      before,
    );
  });
}
