class InputValidationService {
  static final RegExp _safeTextRegex = RegExp(r'^[a-zA-Z0-9\s\-_.(),]+$');
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp _numericRegex = RegExp(r'^-?\d+\.?\d*$');

  static String sanitizeText(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[<>";&]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static String sanitizeFileName(String input) {
    return input
        .replaceAll(RegExp(r'[^\w\s\-_.]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }

  static bool isValidText(String? input,
      {int minLength = 1, int maxLength = 255}) {
    if (input == null || input.isEmpty) return false;
    if (input.length < minLength || input.length > maxLength) return false;
    return _safeTextRegex.hasMatch(input);
  }

  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    return _emailRegex.hasMatch(email);
  }

  static bool isValidNumeric(String? input) {
    if (input == null || input.isEmpty) return false;
    return _numericRegex.hasMatch(input);
  }

  static bool isValidRange(String value, String minValue, String maxValue) {
    if (!_numericRegex.hasMatch(value)) return false;
    final val = double.tryParse(value);
    final min = double.tryParse(minValue);
    final max = double.tryParse(maxValue);

    if (val == null) return false;
    if (min != null && val < min) return false;
    if (max != null && val > max) return false;

    return true;
  }

  static bool isValidFilePath(String? path) {
    if (path == null || path.isEmpty) return false;

    final invalidChars = RegExp(r'[<>:"|?*]');
    if (invalidChars.hasMatch(path)) return false;

    return true;
  }

  static bool isAllowedFileExtension(
      String fileName, List<String> allowedExtensions) {
    final extension = fileName.split('.').last.toLowerCase();
    return allowedExtensions.map((e) => e.toLowerCase()).contains(extension);
  }

  static List<String> sanitizeList(List<String> input) {
    return input
        .map((e) => sanitizeText(e))
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static Map<String, String> sanitizeMap(Map<String, String> input) {
    final sanitized = <String, String>{};
    input.forEach((key, value) {
      final cleanKey = sanitizeText(key);
      final cleanValue = sanitizeText(value);
      if (cleanKey.isNotEmpty) {
        sanitized[cleanKey] = cleanValue;
      }
    });
    return sanitized;
  }

  static bool validateFileSize(int bytes, int maxSizeInMB) {
    final maxBytes = maxSizeInMB * 1024 * 1024;
    return bytes <= maxBytes;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateMinLength(
      String? value, int minLength, String fieldName) {
    if (value != null && value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  static String? validateMaxLength(
      String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be at most $maxLength characters';
    }
    return null;
  }
}
