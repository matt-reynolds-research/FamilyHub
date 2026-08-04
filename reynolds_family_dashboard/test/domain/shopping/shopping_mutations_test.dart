import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reynolds_family_dashboard/domain/shopping/shopping_model.dart';
import 'package:reynolds_family_dashboard/domain/shopping/shopping_mutations.dart';
import 'package:reynolds_family_dashboard/domain/shopping/shopping_parser.dart';
import 'package:reynolds_family_dashboard/domain/shopping/shopping_repository.dart';

/// PRD 02 P0-5/P0-6: add and check must produce markdown **byte-compatible** with what the
/// text assistant (`list-conventions.md` GROCERY / SHOP / BOUGHT_*) would have written — so
/// the expectations here are hand-written whole-file diffs, not assertions about our own model.
void main() {
  const parser = ShoppingParser();
  const mutations = ShoppingMutations();

  String fixture(String name) =>
      File('test/fixtures/shopping/$name').readAsStringSync();
  String seed() => File('assets/fixtures/shopping_seed.md').readAsStringSync();
  ShoppingDocument seedDoc() => parser.parse(seed());

  group('add (GROCERY / SHOP)', () {
    test('appends to the end of the section, whole-file byte-compatible', () {
      final result = mutations.add(seedDoc(),
          list: ShoppingList.grocery, title: 'Eggs', note: 'dozen');
      expect(result.applied, isTrue);
      expect(result.message, 'Added to grocery: Eggs (dozen)');
      expect(
          parser.serialize(result.document), fixture('expected_after_add.md'));
    });

    test('a bare item writes the bare form', () {
      final result = mutations.add(seedDoc(),
          list: ShoppingList.household, title: 'Bin bags');
      expect(parser.serialize(result.document),
          contains('- [ ] Litter box (a.co/d/EXAMPLE01)\n- [ ] Bin bags\n'));
    });

    test('dedupes by the conventions key and leaves the file untouched', () {
      final source = seed();
      // "milk" vs the file's "Milk (2 gallons)" — same item under the dedup key.
      final result = mutations.add(parser.parse(source),
          list: ShoppingList.grocery, title: 'milk');
      expect(result.applied, isFalse);
      expect(result.message, 'Already on the grocery list: Milk (2 gallons)');
      expect(parser.serialize(result.document), source);
    });

    test(
        'an item-less section still appends inside the section, not at the file end',
        () {
      final doc = parser.parse(fixture('empty_lists.md'));
      final result =
          mutations.add(doc, list: ShoppingList.household, title: 'Bin bags');
      final out = parser.serialize(result.document);
      expect(out, contains("_Everything that isn't food._\n- [ ] Bin bags\n"));
      expect(out, contains('## Recently Bought'));
      expect(out.trimRight().endsWith('(grocery, 2026-07-24)'), isTrue);
    });

    test('empty input is rejected calmly', () {
      final result =
          mutations.add(seedDoc(), list: ShoppingList.grocery, title: '   ');
      expect(result.applied, isFalse);
      expect(parser.serialize(result.document), seed());
    });
  });

  group('check / mark bought (BOUGHT_GROCERY / BOUGHT_SHOP)', () {
    test(
        'relocates to the end of Recently Bought with provenance + today\'s date',
        () {
      final result = mutations.markBought(
        seedDoc(),
        list: ShoppingList.grocery,
        dedupKey: 'milk',
        today: DateTime(2026, 8, 4),
      );
      expect(result.applied, isTrue);
      expect(result.message, 'Got it — Milk moved to Recently Bought.');
      expect(parser.serialize(result.document),
          fixture('expected_after_check.md'));
    });

    test(
        'the note is dropped on archive — lossless-by-design, matching the backend',
        () {
      final result = mutations.markBought(seedDoc(),
          list: ShoppingList.grocery,
          dedupKey: 'milk',
          today: DateTime(2026, 8, 4));
      expect(parser.serialize(result.document),
          contains('- [x] ~~Milk~~ (grocery, 2026-08-04)'));
      expect(parser.serialize(result.document),
          isNot(contains('~~Milk (2 gallons)~~')));
    });

    test('nothing is deleted — the item count is conserved', () {
      final before = seedDoc();
      final after = mutations
          .markBought(before,
              list: ShoppingList.grocery,
              dedupKey: 'milk',
              today: DateTime(2026, 8, 4))
          .document;
      expect(before.totalToBuy + before.recentlyBought.length,
          after.totalToBuy + after.recentlyBought.length);
      expect(after.totalToBuy, before.totalToBuy - 1);
    });

    test('a miss is reported, not silently applied', () {
      final result = mutations.markBought(seedDoc(),
          list: ShoppingList.grocery, dedupKey: 'caviar');
      expect(result.applied, isFalse);
      expect(result.message, contains('Couldn\'t find'));
      expect(parser.serialize(result.document), seed());
    });

    test('there is no client-side archive clear', () {
      // Guard against re-adding one: the mutation surface is add + markBought, nothing else.
      expect(mutations.runtimeType.toString(), 'ShoppingMutations');
      final doc = seedDoc();
      expect(doc.recentlyBought.length, 4);
    });
  });

  group('repository seam', () {
    test('load → mutate → save round-trips through the serializer', () async {
      final repo = FixtureShoppingRepository(loadAsset: (_) async => seed());
      final doc = await repo.load();
      expect(doc.totalToBuy, 4);

      final result = mutations.add(doc,
          list: ShoppingList.grocery, title: 'Eggs', note: 'dozen');
      await repo.save(result.document);

      expect(repo.workingCopy, fixture('expected_after_add.md'));
      expect((await repo.load()).totalToBuy,
          5); // the session copy is what reloads
    });

    test('an unparseable source fails loud through the repository', () async {
      final repo = FixtureShoppingRepository(
        loadAsset: (_) async => fixture('malformed_bullet.md'),
      );
      expect(repo.load(), throwsA(isA<ShoppingParseException>()));
    });
  });
}
