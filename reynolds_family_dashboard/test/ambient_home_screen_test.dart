import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reynolds_family_dashboard/features/home_hub/ambient_home_screen.dart';

/// Phase-0 shell smoke tests: the ambient Home Hub renders its seeded glance content, the
/// Assistant Bar is always present, and tapping a tile opens the generic focus container and
/// returns home. Verifies the tree builds without exceptions (no simulator needed).
void main() {
  Future<void> pumpHub(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1180, 820);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: AmbientHomeScreen()),
      ),
    );
    await tester.pump(); // let the first frame settle
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
    expect(find.text('people added items'), findsOneWidget);
    expect(find.text('Milk, berries + 6 more'), findsOneWidget);
    expect(find.text('Alex · 4 left'), findsOneWidget);
    expect(find.text('Kids lunchbox'), findsOneWidget);
    expect(find.text('2 days late'), findsOneWidget);
    expect(find.text("Ask me anything — 'add milk…'"), findsOneWidget);

    await teardownHub(tester);
  });

  testWidgets('tapping a tile opens the focus container and back returns home',
      (tester) async {
    await pumpHub(tester);

    await tester.tap(find.text('Shopping'));
    await tester.pumpAndSettle();
    expect(find.text('Recently added'.toUpperCase()), findsOneWidget);
    expect(find.text('Seeded preview · live household data is not connected'),
        findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Seeded preview · live household data is not connected'),
        findsNothing);
    expect(find.text('FAMILYHUB'), findsOneWidget);

    await teardownHub(tester);
  });
}
