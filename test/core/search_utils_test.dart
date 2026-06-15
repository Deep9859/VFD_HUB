import 'package:flutter_test/flutter_test.dart';
import 'package:vfd_param_app/core/utils/search_utils.dart';

void main() {
  group('SearchUtils', () {
    test('fuzzyMatch empty query matches anything', () {
      expect(SearchUtils.fuzzyMatch('', 'ACS580'), isTrue);
    });

    test('fuzzyMatch substring', () {
      expect(SearchUtils.fuzzyMatch('acs', 'ACS580'), isTrue);
    });

    test('fuzzyMatch subsequence', () {
      expect(SearchUtils.fuzzyMatch('a580', 'ACS580'), isTrue);
    });

    test('matchesAnyField requires all tokens', () {
      expect(
        SearchUtils.matchesAnyField('abb acs', ['ACS580', 'ABB', 'Pump']),
        isTrue,
      );
      expect(
        SearchUtils.matchesAnyField('abb siemens', ['ACS580', 'ABB', 'Pump']),
        isFalse,
      );
    });
  });
}
