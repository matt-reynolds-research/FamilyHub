import 'package:flutter/services.dart' show rootBundle;

import 'shopping_model.dart';
import 'shopping_parser.dart';

/// The data-layer seam (PRD 01 P0-5 / PRD 02 P0-2).
///
/// Everything above this interface — tiles, mutations, later the Assistant Bar — only ever
/// sees a [ShoppingDocument]. That is what makes the seeded fixture and (in Phase 5) the live
/// `SHOPPING.md` **interchangeable sources of the same model**: swapping the implementation
/// is the only change live wiring should require.
abstract interface class ShoppingRepository {
  Future<ShoppingDocument> load();

  /// Persists a mutated document. Phase 1 keeps this in memory (see [FixtureShoppingRepository]).
  Future<void> save(ShoppingDocument document);
}

/// Phase-1 implementation: reads the **committed seed fixture** bundled as an asset, and holds
/// mutations in memory for the session.
///
/// Why in-memory: bundled assets are read-only at runtime, and writing the household's real
/// `SHOPPING.md` is explicitly out of scope until Phase 5 (concurrent-write arbitration with
/// the 10 PM sweep and the email-in handler is an unmet precondition, D-11). Mutations are
/// still *real* — they go through the same parse → mutate → serialize path a file write would,
/// so the serializer is genuinely exercised; only the final `write()` is missing.
class FixtureShoppingRepository implements ShoppingRepository {
  FixtureShoppingRepository({
    this.assetPath = 'assets/fixtures/shopping_seed.md',
    this.parser = const ShoppingParser(),
    Future<String> Function(String key)? loadAsset,
  }) : _loadAsset = loadAsset ?? rootBundle.loadString;

  final String assetPath;
  final ShoppingParser parser;
  final Future<String> Function(String key) _loadAsset;

  /// The session's working copy of the file, as markdown text (not a parsed object) — so the
  /// round-trip through the serializer happens on every save, not just at the end.
  String? _workingCopy;

  @override
  Future<ShoppingDocument> load() async {
    final source = _workingCopy ??= await _loadAsset(assetPath);
    // Deliberately un-caught: a fixture that no longer parses must fail loud in dev
    // (ShoppingParseException), never degrade into a silently short list.
    return parser.parse(source);
  }

  @override
  Future<void> save(ShoppingDocument document) async {
    _workingCopy = parser.serialize(document);
  }

  /// The current markdown text — useful for tests and for a dev "show me the file" view.
  String? get workingCopy => _workingCopy;
}
