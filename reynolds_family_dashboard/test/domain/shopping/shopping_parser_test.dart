import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reynolds_family_dashboard/domain/shopping/shopping_model.dart';
import 'package:reynolds_family_dashboard/domain/shopping/shopping_parser.dart';

/// PRD 02 P0-1/P0-2 acceptance: the parser is only "done" if the whole file survives a
/// round-trip byte-for-byte, every real line form is understood, and anything it can't
/// classify fails loud instead of quietly vanishing.
void main() {
  const parser = ShoppingParser();

  String fixture(String name) =>
      File('test/fixtures/shopping/$name').readAsStringSync();
  String seed() => File('assets/fixtures/shopping_seed.md').readAsStringSync();

  group('round-trip fidelity', () {
    test('the seed fixture serializes back byte-identically', () {
      final source = seed();
      expect(parser.serialize(parser.parse(source)), source);
    });

    test('empty-list and unknown-section fixtures round-trip byte-identically',
        () {
      for (final name in ['empty_lists.md', 'unknown_section.md']) {
        final source = fixture(name);
        expect(parser.serialize(parser.parse(source)), source, reason: name);
      }
    });

    test('a file with no trailing newline stays that way', () {
      const source = '# Reynolds Family Shopping\n\n## Grocery\n\n- [ ] Pasta';
      expect(parser.serialize(parser.parse(source)), source);
    });

    test('CRLF line endings survive', () {
      const source =
          '# Reynolds Family Shopping\r\n\r\n## Grocery\r\n\r\n- [ ] Pasta\r\n';
      final doc = parser.parse(source);
      expect(doc.activeItems(ShoppingList.grocery).single.title, 'Pasta');
      expect(parser.serialize(doc), source);
    });
  });

  group('item forms', () {
    late ShoppingDocument doc;
    setUp(() => doc = parser.parse(seed()));

    test('bare, parenthetical and em-dash active items all parse', () {
      final grocery = doc.activeItems(ShoppingList.grocery);
      expect(grocery.map((i) => i.title), ['Pasta', 'Milk', 'Bread']);
      expect(grocery.map((i) => i.note),
          [null, '2 gallons', 'sourdough if they have it']);
      expect(grocery.map((i) => i.noteStyle), [
        NoteStyle.none,
        NoteStyle.parenthetical,
        NoteStyle.emDash,
      ]);
    });

    test('quantities stay opaque strings — no unit parsing', () {
      final milk = doc.activeItems(ShoppingList.grocery)[1];
      expect(milk.note, '2 gallons');
      expect(milk.itemText, 'Milk (2 gallons)');
    });

    test('bought items carry provenance and completion date', () {
      final bought = doc.recentlyBought;
      expect(bought.length, 4);
      expect(bought.first.title, 'Adult camp chair');
      expect(bought.first.source, ShoppingList.household);
      expect(bought.first.dateStamp, '2026-07-22');
      expect(bought.last.source, ShoppingList.grocery);
    });

    test('dedup key is the line minus its trailing parenthetical', () {
      final milk = doc.activeItems(ShoppingList.grocery)[1];
      expect(milk.dedupKey, 'milk');
      expect(milk.dedupKey, normalizeDedupKey('  MILK  '));
      // The conventions only strip parentheticals, so an em-dash note is part of the key.
      expect(
        doc.activeItems(ShoppingList.grocery)[2].dedupKey,
        'bread — sourdough if they have it',
      );
    });

    test('the tile key number is the combined unchecked count', () {
      expect(doc.totalToBuy, 4); // 3 grocery + 1 household
    });
  });

  group('preservation', () {
    test('intro prose and HTML-comment example blocks are kept, not dropped',
        () {
      final doc = parser.parse(seed());
      final grocery = doc.sectionOf(ShoppingSectionKind.grocery)!;
      final raw =
          grocery.nodes.whereType<RawNode>().map((n) => n.text).join('\n');
      expect(raw, contains('_Food and kitchen.'));
      expect(raw, contains('<!-- Examples:'));
      // The commented-out example bullets are inside a raw comment block, not items.
      expect(grocery.activeItems.length, 3);
    });

    test('unknown sections are preserved verbatim and never reinterpreted', () {
      final doc = parser.parse(fixture('unknown_section.md'));
      final other =
          doc.sections.firstWhere((s) => s.kind == ShoppingSectionKind.other);
      expect(other.title, 'Notes for the family');
      expect(other.nodes.every((n) => n is RawNode), isTrue);
    });
  });

  group('fail loud', () {
    test('an unclassifiable bullet inside a list section throws', () {
      expect(
        () => parser.parse(fixture('malformed_bullet.md')),
        throwsA(isA<ShoppingParseException>()
            .having((e) => e.lineNumber, 'lineNumber', 6)
            .having((e) => e.line, 'line', '- Eggs')),
      );
    });

    test('a bought line with a bad date shape throws rather than being skipped',
        () {
      const source =
          '## Recently Bought\n\n- [x] ~~Milk~~ (grocery, 7/24/26)\n';
      expect(
          () => parser.parse(source), throwsA(isA<ShoppingParseException>()));
    });
  });
}
