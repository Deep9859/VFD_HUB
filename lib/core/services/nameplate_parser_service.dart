/// Parses motor nameplate text (OCR or manual paste) into structured specs.
class NameplateParserService {
  NameplateParserService._();

  static final _kwPatterns = [
    RegExp(r'(\d+(?:\.\d+)?)\s*k\s*w', caseSensitive: false),
    RegExp(r'(\d+(?:\.\d+)?)\s*kw', caseSensitive: false),
    RegExp(r'power[:\s]*(\d+(?:\.\d+)?)', caseSensitive: false),
  ];

  static final _voltPatterns = [
    RegExp(r'(\d+(?:\.\d+)?)\s*v(?:olt)?', caseSensitive: false),
    RegExp(r'voltage[:\s]*(\d+(?:\.\d+)?)', caseSensitive: false),
  ];

  static final _ampPatterns = [
    RegExp(r'(\d+(?:\.\d+)?)\s*a(?:mp)?', caseSensitive: false),
    RegExp(r'current[:\s]*(\d+(?:\.\d+)?)', caseSensitive: false),
  ];

  static final _rpmPatterns = [
    RegExp(r'(\d{3,5})\s*rpm', caseSensitive: false),
    RegExp(r'speed[:\s]*(\d{3,5})', caseSensitive: false),
  ];

  static final _hzPatterns = [
    RegExp(r'(\d{2})\s*hz', caseSensitive: false),
    RegExp(r'frequency[:\s]*(\d{2})', caseSensitive: false),
  ];

  static NameplateSpecs parse(String rawText) {
    final text = rawText.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ');

    return NameplateSpecs(
      powerKw: _firstMatch(_kwPatterns, text),
      voltage: _firstMatch(_voltPatterns, text),
      current: _firstMatch(_ampPatterns, text),
      speedRpm: _firstMatch(_rpmPatterns, text),
      frequencyHz: _firstMatch(_hzPatterns, text) ?? 50,
      connection: _detectConnection(text),
    );
  }

  static double? _firstMatch(List<RegExp> patterns, String text) {
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return double.tryParse(match.group(1)!);
      }
    }
    return null;
  }

  static String _detectConnection(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('delta') && !lower.contains('star-delta')) {
      return 'Delta';
    }
    if (lower.contains('y') || lower.contains('star')) {
      return 'Star';
    }
    return 'Star';
  }
}

class NameplateSpecs {
  final double? powerKw;
  final double? voltage;
  final double? current;
  final double? speedRpm;
  final double frequencyHz;
  final String connection;

  const NameplateSpecs({
    this.powerKw,
    this.voltage,
    this.current,
    this.speedRpm,
    this.frequencyHz = 50,
    this.connection = 'Star',
  });

  bool get hasAnyValue =>
      powerKw != null ||
      voltage != null ||
      current != null ||
      speedRpm != null;
}
