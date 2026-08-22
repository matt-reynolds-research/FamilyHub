import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reynolds_family_dashboard/domain/shopping/shopping_model.dart';
import 'package:reynolds_family_dashboard/domain/shopping/shopping_repository.dart';
import 'package:reynolds_family_dashboard/domain/tasks/task_model.dart';
import 'package:reynolds_family_dashboard/domain/tasks/task_repository.dart';
import 'package:reynolds_family_dashboard/features/assistant/assistant_controller.dart';
import 'package:reynolds_family_dashboard/features/shopping/shopping_controller.dart';
import 'package:reynolds_family_dashboard/features/tasks/task_controller.dart';

const fixture = '''# Shopping

## Grocery

- [ ] Pasta
- [ ] Milk (2 gallons)

## Household

- [ ] Paper towels

## Recently Bought

''';

const taskFixture = '''# Tasks

## Family Tasks

- [ ] **Plan dinner** — added via text from Sara on 2026-08-20

## Open Tasks

- [ ] **Return books** — added via text from Matt on 2026-08-21

## Waiting On

- [ ] **School list** — teacher email

## Someday / Maybe

## Done

''';

void main() {
  Future<ProviderContainer> containerWithDomains() async {
    final repository = FixtureShoppingRepository(
      loadAsset: (_) async => fixture,
    );
    final taskRepository = FixtureTaskRepository(
      loadAsset: (_) async => taskFixture,
    );
    final container = ProviderContainer(
      overrides: [
        shoppingRepositoryProvider.overrideWithValue(repository),
        taskRepositoryProvider.overrideWithValue(taskRepository),
      ],
    );
    await container.read(shoppingControllerProvider.future);
    await container.read(taskControllerProvider.future);
    return container;
  }

  test('add defaults to Grocery and can target Household', () async {
    final container = await containerWithDomains();
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
    final container = await containerWithDomains();
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
    final container = await containerWithDomains();
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
    final container = await containerWithDomains();
    addTearDown(container.dispose);
    final before =
        container.read(shoppingControllerProvider).requireValue.totalToBuy;

    await container
        .read(assistantControllerProvider.notifier)
        .submit('When is the lunchbox arriving?');

    final assistant = container.read(assistantControllerProvider);
    expect(assistant.messages.last.text, contains('Shopping and Tasks'));
    expect(
      container.read(shoppingControllerProvider).requireValue.totalToBuy,
      before,
    );
  });

  test('task add targets Open Tasks and switches the engaged preview',
      () async {
    final container = await containerWithDomains();
    addTearDown(container.dispose);

    await container
        .read(assistantControllerProvider.notifier)
        .submit('add task Call plumber');

    final tasks = container.read(taskControllerProvider).requireValue;
    expect(
      tasks.activeTasks(TaskSectionKind.open).map((task) => task.title),
      contains('Call plumber'),
    );
    expect(container.read(assistantControllerProvider).activeDomain,
        AssistantDomain.tasks);
  });

  test('task query summarizes workflow sections without mutation', () async {
    final container = await containerWithDomains();
    addTearDown(container.dispose);
    final before = container.read(taskControllerProvider).requireValue;

    await container
        .read(assistantControllerProvider.notifier)
        .submit('What tasks are left?');

    final reply =
        container.read(assistantControllerProvider).messages.last.text;
    expect(reply, contains('3 tasks remain'));
    expect(reply, contains('Family: Plan dinner'));
    expect(reply, contains('Open: Return books'));
    expect(container.read(taskControllerProvider).requireValue, same(before));
  });

  test('done with relocates the matching task into Done', () async {
    final container = await containerWithDomains();
    addTearDown(container.dispose);

    await container
        .read(assistantControllerProvider.notifier)
        .submit('done with return books');

    final tasks = container.read(taskControllerProvider).requireValue;
    expect(tasks.allActive.map((task) => task.title),
        isNot(contains('Return books')));
    expect(tasks.done.map((task) => task.title), contains('Return books'));
    expect(container.read(assistantControllerProvider).messages.last.text,
        'Checked off: Return books');
  });
}
