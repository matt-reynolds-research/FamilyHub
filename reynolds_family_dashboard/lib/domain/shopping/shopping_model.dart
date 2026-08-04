/// The lossless `SHOPPING.md` model (PRD 02 P0-1, D-10).
///
/// **Why a document model and not `{section, text, checked}`.** `SHOPPING.md` is *shared* —
/// the 6:30 AM Morning Briefing reads it and the text assistant writes it. If FamilyHub
/// re-renders the file from a thin model it silently destroys everything it didn't model
/// (intro prose, the HTML-comment example blocks, blank-line rhythm, notes, provenance).
/// So the model represents the **whole file** as an ordered tree of nodes, every one of which
/// can render itself back, and unmutated nodes carry their original `raw` line verbatim.
///
/// Round-trip contract: `serialize(parse(text)) == text`, byte for byte.
library;

/// Which list a `##` section is. `other` = a section we don't know about; its contents are
/// preserved verbatim and never reinterpreted (PRD 02 P0-2).
enum ShoppingSectionKind { grocery, household, recentlyBought, other }

/// The two *active* lists. A bought line stamps which one it came from.
enum ShoppingList { grocery, household }

extension ShoppingListX on ShoppingList {
  /// The token the backend writes into the bought parenthetical.
  String get token => this == ShoppingList.grocery ? 'grocery' : 'household';

  ShoppingSectionKind get sectionKind => this == ShoppingList.grocery
      ? ShoppingSectionKind.grocery
      : ShoppingSectionKind.household;

  static ShoppingList fromToken(String token) =>
      token == 'grocery' ? ShoppingList.grocery : ShoppingList.household;
}

/// How an active item carries its note. The live list uses parentheticals; the sections'
/// example blocks also document an em-dash form, so both must survive.
enum NoteStyle {
  /// `- [ ] Milk (2 gallons)`
  parenthetical,

  /// `- [ ] Bread — sourdough if they have it`
  emDash,

  /// `- [ ] Pasta`
  none,
}

/// Raised when a line *inside a known section* looks like a bullet but matches no known form.
/// Fail loud while building: never silently skip a line, because a skipped line is a lost
/// household item.
class ShoppingParseException implements Exception {
  ShoppingParseException(this.message,
      {required this.lineNumber, required this.line});

  final String message;

  /// 1-based, for pointing a human at the offending line.
  final int lineNumber;
  final String line;

  @override
  String toString() =>
      'ShoppingParseException: $message (line $lineNumber): "$line"';
}

/// One line of the file, in file order.
sealed class ShoppingNode {
  const ShoppingNode();

  /// The exact text this node contributes to the file (no trailing newline).
  String render();
}

/// Anything that isn't an item bullet: intro prose, HTML-comment example blocks, blank lines.
/// Preserved verbatim — this is most of what a thin model would have thrown away.
final class RawNode extends ShoppingNode {
  const RawNode(this.text);

  final String text;

  @override
  String render() => text;
}

/// `- [ ] Pasta` / `- [ ] Milk (2 gallons)` / `- [ ] Bread — sourdough if they have it`
final class ActiveItem extends ShoppingNode {
  const ActiveItem({
    required this.title,
    this.note,
    this.noteStyle = NoteStyle.none,
    this.raw,
  });

  /// The item itself, without its note segment.
  final String title;

  /// The note/quantity, verbatim and **uninterpreted** — `2 gallons` is an opaque string,
  /// not a structured quantity (deliberate non-goal).
  final String? note;

  final NoteStyle noteStyle;

  /// The original line, when this item came from a parsed file. Kept so serialization is
  /// byte-exact even if our renderer would have spaced things differently.
  final String? raw;

  /// The full text after the checkbox — what the backend calls "the item text".
  String get itemText => switch (noteStyle) {
        NoteStyle.parenthetical => '$title ($note)',
        NoteStyle.emDash => '$title — $note',
        NoteStyle.none => title,
      };

  /// `list-conventions.md` dedup key: **the line minus its trailing parenthetical**. So
  /// `Milk` and `Milk (2 gallons)` are the same item, while an em-dash note is part of the
  /// key (the conventions only strip parentheticals). Normalised case/whitespace so a
  /// hub-typed "milk" matches a text-assistant "Milk".
  String get dedupKey => normalizeDedupKey(
        noteStyle == NoteStyle.parenthetical ? title : itemText,
      );

  @override
  String render() => raw ?? '- [ ] $itemText';

  ActiveItem asNew() =>
      ActiveItem(title: title, note: note, noteStyle: noteStyle);
}

/// `- [x] ~~Adult camp chair~~ (household, 2026-07-22)` — an archived line in
/// `## Recently Bought`. Carries source-list provenance + the completion date.
final class BoughtItem extends ShoppingNode {
  const BoughtItem({
    required this.title,
    required this.source,
    required this.date,
    this.raw,
  });

  final String title;
  final ShoppingList source;

  /// Date only; the file has no time component.
  final DateTime date;
  final String? raw;

  String get dateStamp => _yyyymmdd(date);

  @override
  String render() => raw ?? '- [x] ~~$title~~ (${source.token}, $dateStamp)';
}

/// A `##` section: its heading line, its kind, and its nodes in file order.
final class ShoppingSection {
  const ShoppingSection({
    required this.headingRaw,
    required this.title,
    required this.kind,
    required this.nodes,
  });

  /// The heading line verbatim (e.g. `## Grocery`).
  final String headingRaw;

  /// The heading text (e.g. `Grocery`).
  final String title;

  final ShoppingSectionKind kind;
  final List<ShoppingNode> nodes;

  Iterable<ActiveItem> get activeItems => nodes.whereType<ActiveItem>();
  Iterable<BoughtItem> get boughtItems => nodes.whereType<BoughtItem>();

  ShoppingSection copyWith({List<ShoppingNode>? nodes}) => ShoppingSection(
        headingRaw: headingRaw,
        title: title,
        kind: kind,
        nodes: nodes ?? this.nodes,
      );
}

/// The whole file.
final class ShoppingDocument {
  const ShoppingDocument({
    required this.preamble,
    required this.sections,
    required this.endsWithNewline,
  });

  /// Everything before the first `##` heading (the `# Reynolds Family Shopping` title, blanks).
  final List<ShoppingNode> preamble;

  final List<ShoppingSection> sections;

  /// Whether the source file ended with a newline — part of byte-exactness.
  final bool endsWithNewline;

  ShoppingSection? sectionOf(ShoppingSectionKind kind) {
    for (final s in sections) {
      if (s.kind == kind) return s;
    }
    return null;
  }

  /// Unchecked items in a given active list, in file order.
  List<ActiveItem> activeItems(ShoppingList list) =>
      sectionOf(list.sectionKind)?.activeItems.toList() ?? const [];

  /// The tile's key number: total unchecked across both active lists (PRD 02 P0-3).
  int get totalToBuy =>
      activeItems(ShoppingList.grocery).length +
      activeItems(ShoppingList.household).length;

  List<BoughtItem> get recentlyBought =>
      sectionOf(ShoppingSectionKind.recentlyBought)?.boughtItems.toList() ??
      const [];

  ShoppingDocument copyWith({List<ShoppingSection>? sections}) =>
      ShoppingDocument(
        preamble: preamble,
        sections: sections ?? this.sections,
        endsWithNewline: endsWithNewline,
      );
}

/// Lowercase + collapse whitespace + drop trailing punctuation noise, so dedup is forgiving
/// about how a human typed it but still literal about *what* it is.
String normalizeDedupKey(String text) =>
    text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

String _yyyymmdd(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
