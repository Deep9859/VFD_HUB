/// Lightweight fuzzy matching for catalog search (no external deps).
class SearchUtils {
  SearchUtils._();

  /// True when [query] is empty or matches [target] via substring or subsequence.
  static bool fuzzyMatch(String query, String target) {
    final q = query.toLowerCase().trim();
    final t = target.toLowerCase();
    if (q.isEmpty) return true;
    if (t.contains(q)) return true;

    var qi = 0;
    for (var i = 0; i < t.length && qi < q.length; i++) {
      if (t[i] == q[qi]) qi++;
    }
    return qi == q.length;
  }

  /// Multi-word query: every token must fuzzy-match at least one field.
  static bool matchesAnyField(String query, List<String> fields) {
    final tokens =
        query.toLowerCase().split(RegExp(r'\s+')).where((t) => t.isNotEmpty);
    if (tokens.isEmpty) return true;
    for (final token in tokens) {
      if (!fields.any((f) => fuzzyMatch(token, f))) return false;
    }
    return true;
  }
}
