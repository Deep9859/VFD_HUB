import 'package:flutter_test/flutter_test.dart';
import 'package:vfd_param_app/core/services/nameplate_parser_service.dart';

void main() {
  group('NameplateParserService', () {
    test('parses kW voltage current rpm from typical plate text', () {
      const text = 'MOTOR 7.5 kW 415V 14.8A 1450 RPM 50Hz Delta connection';
      final specs = NameplateParserService.parse(text);

      expect(specs.powerKw, 7.5);
      expect(specs.voltage, 415);
      expect(specs.current, closeTo(14.8, 0.01));
      expect(specs.speedRpm, 1450);
      expect(specs.frequencyHz, 50);
      expect(specs.connection, 'Delta');
    });

    test('handles sparse text with subsequence-friendly tokens', () {
      const text = 'Rated power 3 kW 230 V 50 Hz';
      final specs = NameplateParserService.parse(text);

      expect(specs.powerKw, 3);
      expect(specs.voltage, 230);
      expect(specs.frequencyHz, 50);
    });
  });
}
