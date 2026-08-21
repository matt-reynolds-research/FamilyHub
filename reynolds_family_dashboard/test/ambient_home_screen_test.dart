import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reynolds_family_dashboard/domain/shopping/shopping_repository.dart';
import 'package:reynolds_family_dashboard/features/home_hub/ambient_home_screen.dart';
import 'package:reynolds_family_dashboard/features/shopping/shopping_controller.dart';

const shoppingFixture = '''# Shopping

## Grocery

- [ ] Pasta
- [ ] Milk (2 gallons)
- [ ] Bread — sourdough

## Household

- [ ] Litter box

## Recently Bought

- [x] ~~Oat milk~~ (grocery, 2026-08-20)
''';

/// Phase-0 shell smoke tests: the ambient Home Hub renders its seeded glance content, the
/// Assistant Bar is always present, and tapping a tile opens the generic focus container and
/// returns home. Verifies the tree builds without exceptions (no simulator needed).
void main() {
  Future<void> pumpHub(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1180, 820);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repository = FixtureShoppingRepository(
      loadAsset: (_) async => shoppingFixture,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shoppingRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: AmbientHomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(); // resolve the fixture-backed async provider
  }

  Future<void> teardownHub(WidgetTester tester) async {
    // Dispose the screen so its periodic clock timer doesn't linger past the test.
    await tester.pumpWidget(const SizedBox());
  }

  testWidgets('ambient home renders header, three tiles, and the assistant bar',
      (tester) async {
    await pumpHub(tester);

    expect(find.text('FAMILYHUB'), findsOneWidget);
    expect(find.text('Shopping'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Mail & packages'), findsOneWidget);
    expect(find.text('things to buy'), findsOneWidget);
    expect(find.text('Grocery 3 · Household 1'), findsOneWidget);
    expect(find.text('Pasta'), findsOneWidget);
    expect(find.text('Alex · 4 left'), findsOneWidget);
    expect(find.text('Kids lunchbox'), findsOneWidget);
    expect(find.text('2 days late'), findsOneWidget);
    expect(find.text("Ask me anything — 'add milk…'"), findsOneWidget);

    await teardownHub(tester);
  });

  testWidgets('tapping Shopping opens its real lists and back returns home',
      (tester) async {
    await pumpHub(tester);

    await tester.tap(find.text('Shopping'));
    await tester.pump();
    expect(find.text('Grocery'), findsOneWidget);
    expect(find.text('Household'), findsOneWidget);
    expect(find.text('Milk (2 gallons)'), findsOneWidget);
    expect(find.text('Recently bought · 1'), findsOneWidget);
    expect(
      find.text('Seeded working copy · changes last for this app session only'),
      findsOneWidget,
    );

    await tester.tap(find.text('Home'));
    await tester.pump();
    expect(find.text('Seeded preview · live household data is not connected'),
        findsNothing);
    expect(find.text('FAMILYHUB'), findsOneWidget);

    await teardownHub(tester);
  });

  testWidgets('adding and checking update the working Shopping document',
      (tester) async {
    await pumpHub(tester);
    await tester.tap(find.text('Shopping'));
    await tester.pump();

    await tester.enterText(
      find.widgetWithText(TextField, 'Add to grocery'),
      'Eggs',
    );
    await tester.tap(find.byTooltip('Add to grocery'));
    await tester.pump();
    expect(find.text('Eggs'), findsOneWidget);
    expect(find.text('5 to buy'), findsOneWidget);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(find.text('Pasta'), findsNothing);
    expect(find.text('4 to buy'), findsOneWidget);
    expect(find.text('Recently bought · 2'), findsOneWidget);

    await teardownHub(tester);
  });
}
