// Smoke test: the app's Home screen boots and renders without throwing.
//
// The data providers normally fetch from Supabase (unavailable in a test), so we
// override the three of them with empty canned results. We pump inside a Scaffold
// (matching production, where HomePage lives under AppShell's Scaffold) at an
// iPad-sized surface so the hub layout has room. Enough to prove the widget tree
// builds. Add focused tests next to features as they land.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reynolds_family_dashboard/features/home/home_page.dart';
import 'package:reynolds_family_dashboard/models/event.dart';
import 'package:reynolds_family_dashboard/models/grocery_item.dart';
import 'package:reynolds_family_dashboard/models/task.dart';
import 'package:reynolds_family_dashboard/providers/data_providers.dart';

class _FakeEvents extends EventsNotifier {
  @override
  Future<List<Event>> build() async => <Event>[];
}

class _FakeTasks extends TasksNotifier {
  @override
  Future<List<Task>> build() async => <Task>[];
}

class _FakeGroceries extends GroceriesNotifier {
  @override
  Future<List<GroceryItem>> build() async => <GroceryItem>[];
}

void main() {
  testWidgets('Home screen boots without crashing', (tester) async {
    // iPad-sized surface so the hub layout has room to lay out.
    await tester.binding.setSurfaceSize(const Size(1920, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventsProvider.overrideWith(_FakeEvents.new),
          tasksProvider.overrideWith(_FakeTasks.new),
          groceriesProvider.overrideWith(_FakeGroceries.new),
        ],
        child: const MaterialApp(home: Scaffold(body: HomePage())),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(HomePage), findsOneWidget);
  });
}
