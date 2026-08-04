import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reynolds_family_dashboard/features/home_hub/ambient_home_screen.dart';

/// Phase-0 shell smoke tests: the ambient Home Hub renders its seeded glance content, the
/// Assistant Bar is always present, and tapping a tile opens the generic focus container and
/// returns home. Verifies the tree builds without exceptions (no simulator needed).
void main() {
  Future<void> pumpHub(WidgetTester tester) async {
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
    expect(find.text('to buy'), findsOneWidget);
    expect(find.text('Grocery 2 · Household 1'), findsOneWidget);
    expect(find.text("Ask me anything — 'add milk…'"), findsOneWidget);

    await teardownHub(tester);
  });

  testWidgets('tapping a tile opens the focus container and back returns home',
      (tester) async {
    await pumpHub(tester);

    await tester.tap(find.text('Shopping'));
    await tester.pumpAndSettle();
    expect(find.text('Focused view'), findsOneWidget);
    expect(find.text('Shopping content plugs in here'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Focused view'), findsNothing);
    expect(find.text('FAMILYHUB'), findsOneWidget);

    await teardownHub(tester);
  });
}
