// Smoke test: the app's Home screen boots and renders without throwing.
//
// The data providers normally fetch from Supabase, which isn't available in a
// test, so we override the three of them with empty canned results. That's
// enough to prove the widget tree builds. As real features land, add focused
// tests next to them (this file is just the pattern + the first CI signal).

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
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventsProvider.overrideWith(_FakeEvents.new),
          tasksProvider.overrideWith(_FakeTasks.new),
          groceriesProvider.overrideWith(_FakeGroceries.new),
        ],
        child: const MaterialApp(home: HomePage()),
      ),
    );

    // Let the overridden async providers resolve.
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(HomePage), findsOneWidget);
  });
}
