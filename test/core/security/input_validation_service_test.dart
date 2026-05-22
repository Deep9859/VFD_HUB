import 'package:flutter_test/flutter_test.dart';
import 'package:vfd_param_app/core/security/input_validation_service.dart';

void main() {
  group('InputValidationService', () {
    group('sanitizeText', () {
      test('removes dangerous characters', () {
        expect(InputValidationService.sanitizeText('<script>'), 'script');
        expect(InputValidationService.sanitizeText('a"b'), 'ab');
        expect(InputValidationService.sanitizeText('a;b'), 'ab');
        expect(InputValidationService.sanitizeText('a&b'), 'ab');
      });

      test('trims whitespace', () {
        expect(InputValidationService.sanitizeText('  hello  '), 'hello');
      });

      test('collapses multiple spaces', () {
        expect(InputValidationService.sanitizeText('a  b'), 'a b');
      });

      test('preserves safe characters', () {
        expect(InputValidationService.sanitizeText('ABB-VFD_1.5'), 'ABB-VFD_1.5');
      });
    });

    group('sanitizeFileName', () {
      test('replaces spaces with underscores', () {
        expect(InputValidationService.sanitizeFileName('my file'), 'my_file');
      });

      test('converts to lowercase', () {
        expect(InputValidationService.sanitizeFileName('ABB'), 'abb');
      });

      test('removes special characters', () {
        final result = InputValidationService.sanitizeFileName('file<>name.pdf');
        expect(result.contains('<'), isFalse);
        expect(result.contains('>'), isFalse);
      });
    });

    group('isValidText', () {
      test('returns false for null', () {
        expect(InputValidationService.isValidText(null), isFalse);
      });

      test('returns false for empty string', () {
        expect(InputValidationService.isValidText(''), isFalse);
      });

      test('returns true for valid text', () {
        expect(InputValidationService.isValidText('ABB VFD'), isTrue);
      });

      test('respects minLength', () {
        expect(InputValidationService.isValidText('ab', minLength: 5), isFalse);
        expect(InputValidationService.isValidText('abcde', minLength: 5), isTrue);
      });

      test('respects maxLength', () {
        expect(InputValidationService.isValidText('abcdef', maxLength: 3), isFalse);
        expect(InputValidationService.isValidText('abc', maxLength: 3), isTrue);
      });
    });

    group('isValidEmail', () {
      test('returns false for null', () {
        expect(InputValidationService.isValidEmail(null), isFalse);
      });

      test('returns false for invalid email', () {
        expect(InputValidationService.isValidEmail('notanemail'), isFalse);
        expect(InputValidationService.isValidEmail('a@'), isFalse);
      });

      test('returns true for valid email', () {
        expect(InputValidationService.isValidEmail('user@example.com'), isTrue);
      });
    });

    group('isValidNumeric', () {
      test('returns false for null or empty', () {
        expect(InputValidationService.isValidNumeric(null), isFalse);
        expect(InputValidationService.isValidNumeric(''), isFalse);
      });

      test('returns true for integers and decimals', () {
        expect(InputValidationService.isValidNumeric('42'), isTrue);
        expect(InputValidationService.isValidNumeric('3.14'), isTrue);
        expect(InputValidationService.isValidNumeric('-10'), isTrue);
      });

      test('returns false for non-numeric', () {
        expect(InputValidationService.isValidNumeric('abc'), isFalse);
      });
    });

    group('isValidRange', () {
      test('returns true when value is within range', () {
        expect(InputValidationService.isValidRange('50', '0', '100'), isTrue);
        expect(InputValidationService.isValidRange('0', '0', '100'), isTrue);
        expect(InputValidationService.isValidRange('100', '0', '100'), isTrue);
      });

      test('returns false when value is out of range', () {
        expect(InputValidationService.isValidRange('-1', '0', '100'), isFalse);
        expect(InputValidationService.isValidRange('101', '0', '100'), isFalse);
      });

      test('returns false for non-numeric value', () {
        expect(InputValidationService.isValidRange('abc', '0', '100'), isFalse);
      });

      test('returns true when min/max are non-numeric', () {
        expect(InputValidationService.isValidRange('50', 'N/A', 'N/A'), isTrue);
      });
    });

    group('isValidFilePath', () {
      test('returns false for null or empty', () {
        expect(InputValidationService.isValidFilePath(null), isFalse);
        expect(InputValidationService.isValidFilePath(''), isFalse);
      });

      test('returns false for paths with invalid chars', () {
        expect(InputValidationService.isValidFilePath('file<name'), isFalse);
        expect(InputValidationService.isValidFilePath('file|name'), isFalse);
      });

      test('returns true for valid path', () {
        expect(InputValidationService.isValidFilePath('/data/manual.pdf'), isTrue);
      });
    });

    group('isAllowedFileExtension', () {
      test('returns true for allowed extension', () {
        expect(
          InputValidationService.isAllowedFileExtension('manual.pdf', ['pdf', 'txt']),
          isTrue,
        );
      });

      test('returns false for disallowed extension', () {
        expect(
          InputValidationService.isAllowedFileExtension('virus.exe', ['pdf', 'txt']),
          isFalse,
        );
      });

      test('is case insensitive', () {
        expect(
          InputValidationService.isAllowedFileExtension('manual.PDF', ['pdf']),
          isTrue,
        );
      });
    });

    group('validateRequired', () {
      test('returns error for null or empty', () {
        expect(InputValidationService.validateRequired(null, 'Name'), isNotNull);
        expect(InputValidationService.validateRequired('', 'Name'), isNotNull);
        expect(InputValidationService.validateRequired('  ', 'Name'), isNotNull);
      });

      test('returns null for valid value', () {
        expect(InputValidationService.validateRequired('ABB', 'Name'), isNull);
      });
    });

    group('validateMinLength', () {
      test('returns error when too short', () {
        expect(InputValidationService.validateMinLength('ab', 5, 'Password'), isNotNull);
      });

      test('returns null when long enough', () {
        expect(InputValidationService.validateMinLength('abcde', 5, 'Password'), isNull);
      });
    });

    group('validateMaxLength', () {
      test('returns error when too long', () {
        expect(InputValidationService.validateMaxLength('abcdef', 3, 'Name'), isNotNull);
      });

      test('returns null when within limit', () {
        expect(InputValidationService.validateMaxLength('abc', 3, 'Name'), isNull);
      });
    });

    group('validateFileSize', () {
      test('returns true when within limit', () {
        expect(InputValidationService.validateFileSize(1024 * 1024, 5), isTrue);
      });

      test('returns false when exceeds limit', () {
        expect(InputValidationService.validateFileSize(10 * 1024 * 1024, 5), isFalse);
      });
    });

    group('sanitizeList', () {
      test('sanitizes all items and removes empty', () {
        final result = InputValidationService.sanitizeList(['<a>', 'valid', '']);
        expect(result.contains('valid'), isTrue);
        expect(result.any((s) => s.contains('<')), isFalse);
      });
    });

    group('sanitizeMap', () {
      test('sanitizes keys and values', () {
        final result = InputValidationService.sanitizeMap({'<key>': '<value>'});
        expect(result.keys.any((k) => k.contains('<')), isFalse);
      });

      test('removes entries with empty keys after sanitization', () {
        final result = InputValidationService.sanitizeMap({'<>': 'value'});
        expect(result.isEmpty, isTrue);
      });
    });
  });
}
