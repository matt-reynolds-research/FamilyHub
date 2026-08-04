import 'shopping_model.dart';

/// The two user-owned mutations: **add** and **check** (PRD 02 P0-5 / P0-6).
///
/// These are deliberately **pure functions over the document**, not widget methods, so the
/// Phase-2 Assistant Bar can call exactly the same logic ("add milk", "we got the eggs")
/// without a rewrite (PRD 02 P2-1). Output must be byte-compatible with what
/// `list-conventions.md` GROCERY / SHOP / BOUGHT_* would have written.
///
/// Not here, on purpose: edit, rename, reorder, delete, and **clearing `Recently Bought`** —
/// the archive sweep is the agent's (~7 days), never the client's (D-critic L3).
class ShoppingMutations {
  const ShoppingMutations();

  /// Appends `- [ ] item` (or `- [ ] item (note)`) to the **end** of the target section.
  /// Dedupes against unchecked items in that section by `list-conventions.md`'s key.
  MutationOutcome add(
    ShoppingDocument doc, {
    required ShoppingList list,
    required String title,
    String? note,
  }) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return MutationOutcome.rejected('Nothing to add.', doc);
    }

    final section = _requireSection(doc, list.sectionKind);
    final item = ActiveItem(
      title: trimmed,
      note: (note != null && note.trim().isNotEmpty) ? note.trim() : null,
      noteStyle: (note != null && note.trim().isNotEmpty)
          ? NoteStyle.parenthetical
          : NoteStyle.none,
    );

    final existing = section.activeItems
        .where((i) => i.dedupKey == item.dedupKey)
        .firstOrNull;
    if (existing != null) {
      // Mirrors the assistant's calm "Already on the grocery list: <item>".
      return MutationOutcome.rejected(
        'Already on the ${_listWord(list)} list: ${existing.itemText}',
        doc,
      );
    }

    final nodes = [...section.nodes]..insert(_appendIndex(section.nodes), item);
    return MutationOutcome.applied(
      'Added to ${_listWord(list)}: ${item.itemText}',
      _replaceSection(doc, section.copyWith(nodes: nodes)),
    );
  }

  /// Moves an active item to the end of `## Recently Bought` as
  /// `- [x] ~~<item>~~ (<grocery|household>, <YYYY-MM-DD>)`.
  ///
  /// Note the deliberate asymmetry: the archived line keeps only the item text, so a
  /// trailing note (`(2 gallons)`) is dropped. That is **lossless-by-design** — the
  /// active→archive transition is a defined transform in `list-conventions.md`, not a
  /// round-trip of the same line (PRD 02 P0-6). Nothing is deleted; the line relocates.
  MutationOutcome markBought(
    ShoppingDocument doc, {
    required ShoppingList list,
    required String dedupKey,
    DateTime? today,
  }) {
    final source = _requireSection(doc, list.sectionKind);
    final archive = _requireSection(doc, ShoppingSectionKind.recentlyBought);

    final matches =
        source.activeItems.where((i) => i.dedupKey == dedupKey).toList();
    if (matches.isEmpty) {
      return MutationOutcome.rejected(
        'Couldn\'t find "$dedupKey" on the ${_listWord(list)} list.',
        doc,
      );
    }
    if (matches.length > 1) {
      return MutationOutcome.rejected(
        'Found multiple items matching "$dedupKey" — be more specific.',
        doc,
      );
    }

    final item = matches.single;
    final now = today ?? DateTime.now();

    final sourceNodes = [...source.nodes]..remove(item);
    final bought = BoughtItem(
      title: item.title,
      source: list,
      date: DateTime(now.year, now.month, now.day),
    );
    final archiveNodes = [...archive.nodes]
      ..insert(_appendIndex(archive.nodes), bought);

    var next = _replaceSection(doc, source.copyWith(nodes: sourceNodes));
    next = _replaceSection(next, archive.copyWith(nodes: archiveNodes));

    return MutationOutcome.applied(
      'Got it — ${item.title} moved to Recently Bought.',
      next,
    );
  }

  /// "Append to the END of the section" — after the last item, or (for an item-less section)
  /// after its last non-blank line, so the file's blank-line rhythm between sections survives.
  static int _appendIndex(List<ShoppingNode> nodes) {
    for (var i = nodes.length - 1; i >= 0; i--) {
      if (nodes[i] is ActiveItem || nodes[i] is BoughtItem) return i + 1;
    }
    for (var i = nodes.length - 1; i >= 0; i--) {
      if (nodes[i].render().trim().isNotEmpty) return i + 1;
    }
    return nodes.length;
  }

  static ShoppingSection _requireSection(
    ShoppingDocument doc,
    ShoppingSectionKind kind,
  ) {
    final s = doc.sectionOf(kind);
    if (s == null) {
      // Fail loud while building: a missing section means the file contract broke.
      throw StateError(
          'SHOPPING.md has no "$kind" section — cannot mutate it.');
    }
    return s;
  }

  static ShoppingDocument _replaceSection(
    ShoppingDocument doc,
    ShoppingSection section,
  ) =>
      doc.copyWith(sections: [
        for (final s in doc.sections)
          if (s.kind == section.kind) section else s,
      ]);

  static String _listWord(ShoppingList list) =>
      list == ShoppingList.grocery ? 'grocery' : 'household';
}

/// The result of a mutation: the (possibly unchanged) document plus a human-readable line
/// the UI — or later the assistant — can show verbatim.
class MutationOutcome {
  const MutationOutcome._(this.applied, this.message, this.document);

  factory MutationOutcome.applied(String message, ShoppingDocument doc) =>
      MutationOutcome._(true, message, doc);

  factory MutationOutcome.rejected(String message, ShoppingDocument doc) =>
      MutationOutcome._(false, message, doc);

  /// Whether the document actually changed.
  final bool applied;
  final String message;
  final ShoppingDocument document;
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
