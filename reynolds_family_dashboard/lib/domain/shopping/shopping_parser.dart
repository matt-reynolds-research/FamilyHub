import 'shopping_model.dart';

/// Parser + serializer for `SHOPPING.md` (PRD 02 P0-2).
///
/// **Whitespace policy: byte-exact** (PRD 02 open question, decided here). The file is shared
/// with the text assistant and the Morning Briefing, so normalising it would produce noisy
/// diffs and could fight the other writers. Every parsed node keeps its original line and
/// replays it verbatim; only lines we deliberately add or remove ever change.
class ShoppingParser {
  const ShoppingParser();

  static final _heading = RegExp(r'^(#{1,6})\s+(.*)$');
  static final _bullet = RegExp(r'^\s*[-*]\s');
  static final _active = RegExp(r'^- \[ \] (.+)$');
  static final _bought = RegExp(
    r'^- \[[xX]\] ~~(.+)~~ \((grocery|household), (\d{4})-(\d{2})-(\d{2})\)$',
  );
  static final _trailingParen = RegExp(r'^(.*\S)\s+\((.+)\)$');
  static final _emDash = RegExp(r'\s+(?:—|--)\s+');

  ShoppingDocument parse(String source) {
    final endsWithNewline = source.endsWith('\n');
    final body =
        endsWithNewline ? source.substring(0, source.length - 1) : source;
    final lines = body.isEmpty ? <String>[] : body.split('\n');

    final preamble = <ShoppingNode>[];
    final sections = <ShoppingSection>[];

    String? headingRaw;
    String? title;
    ShoppingSectionKind? kind;
    var nodes = <ShoppingNode>[];

    void closeSection() {
      final heading = headingRaw;
      if (heading == null) return;
      sections.add(ShoppingSection(
        headingRaw: heading,
        title: title!,
        kind: kind!,
        nodes: nodes,
      ));
      nodes = <ShoppingNode>[];
    }

    // Both sections document their item forms in an HTML-comment example block whose lines
    // *look* exactly like real bullets. Comment blocks are inert: nothing inside one is an
    // item (or a heading) — it's prose about items.
    var inComment = false;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      // Tolerate CRLF: match against the trimmed line, but keep `line` verbatim as `raw`.
      final probe =
          line.endsWith('\r') ? line.substring(0, line.length - 1) : line;

      if (inComment) {
        if (headingRaw == null) {
          preamble.add(RawNode(line));
        } else {
          nodes.add(RawNode(line));
        }
        if (probe.contains('-->')) inComment = false;
        continue;
      }
      final opensComment = probe.contains('<!--') &&
          !probe.contains('-->', probe.indexOf('<!--'));
      if (opensComment) {
        inComment = true;
        if (headingRaw == null) {
          preamble.add(RawNode(line));
        } else {
          nodes.add(RawNode(line));
        }
        continue;
      }

      final h = _heading.firstMatch(probe);
      if (h != null && h.group(1)!.length == 2) {
        closeSection();
        headingRaw = line;
        final headingTitle = h.group(2)!.trim();
        title = headingTitle;
        kind = _kindOf(headingTitle);
        continue;
      }

      if (headingRaw == null) {
        preamble.add(RawNode(line));
        continue;
      }

      // Unknown sections are preserved verbatim and never reinterpreted.
      if (kind == ShoppingSectionKind.other) {
        nodes.add(RawNode(line));
        continue;
      }

      nodes.add(_parseSectionLine(probe, raw: line, lineNumber: i + 1));
    }
    closeSection();

    return ShoppingDocument(
      preamble: preamble,
      sections: sections,
      endsWithNewline: endsWithNewline,
    );
  }

  /// `serialize(parse(text)) == text` for an unmutated document.
  String serialize(ShoppingDocument doc) {
    final out = <String>[
      for (final n in doc.preamble) n.render(),
      for (final s in doc.sections) ...[
        s.headingRaw,
        for (final n in s.nodes) n.render(),
      ],
    ];
    final body = out.join('\n');
    return doc.endsWithNewline ? '$body\n' : body;
  }

  ShoppingNode _parseSectionLine(
    String probe, {
    required String raw,
    required int lineNumber,
  }) {
    final bought = _bought.firstMatch(probe);
    if (bought != null) {
      return BoughtItem(
        title: bought.group(1)!,
        source: ShoppingListX.fromToken(bought.group(2)!),
        date: DateTime(
          int.parse(bought.group(3)!),
          int.parse(bought.group(4)!),
          int.parse(bought.group(5)!),
        ),
        raw: raw,
      );
    }

    final active = _active.firstMatch(probe);
    if (active != null) {
      final text = active.group(1)!.trim();
      final (titleText, note, style) = splitNote(text);
      return ActiveItem(
        title: titleText,
        note: note,
        noteStyle: style,
        raw: raw,
      );
    }

    // Not an item — but if it *looks* like a bullet inside a list section, we refuse to guess.
    if (_bullet.hasMatch(probe)) {
      throw ShoppingParseException(
        'Bullet in a list section matches no known item form '
        '(expected "- [ ] item", "- [ ] item (note)" or '
        '"- [x] ~~item~~ (grocery|household, YYYY-MM-DD)")',
        lineNumber: lineNumber,
        line: raw,
      );
    }

    return RawNode(raw);
  }

  /// Splits an active item's text into title + note. Em-dash first (the conventions split on
  /// the first `—`/`--`), then a trailing parenthetical.
  static (String, String?, NoteStyle) splitNote(String text) {
    final dash = _emDash.firstMatch(text);
    if (dash != null) {
      return (
        text.substring(0, dash.start).trim(),
        text.substring(dash.end).trim(),
        NoteStyle.emDash,
      );
    }
    final paren = _trailingParen.firstMatch(text);
    if (paren != null) {
      return (
        paren.group(1)!.trim(),
        paren.group(2)!.trim(),
        NoteStyle.parenthetical
      );
    }
    return (text, null, NoteStyle.none);
  }

  static ShoppingSectionKind _kindOf(String title) =>
      switch (title.toLowerCase()) {
        'grocery' => ShoppingSectionKind.grocery,
        'household' => ShoppingSectionKind.household,
        'recently bought' => ShoppingSectionKind.recentlyBought,
        _ => ShoppingSectionKind.other,
      };
}
