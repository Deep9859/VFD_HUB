import 'package:flutter_test/flutter_test.dart';
import 'package:vfd_param_app/core/services/modbus_tcp_client.dart';
import 'package:vfd_param_app/core/services/nameplate_parser_service.dart';

void main() {
  group('ModbusTcpClient', () {
    test('toPduAddress converts 40001-style addresses', () {
      expect(ModbusTcpClient.toPduAddress(40001), 0);
      expect(ModbusTcpClient.toPduAddress(40100), 99);
      expect(ModbusTcpClient.toPduAddress(30001), 0);
    });
  });

  group('NameplateParserService', () {
    test('parses kW voltage current rpm from typical plate text', () {
      const text = 'MOTOR 7.5 kW 415V 14.8A 1450 RPM 50Hz Delta connection';
      final specs = NameplateParserService.parse(text);

      expect(specs.powerKw, 7.5);
      expect(specs.voltage, 415);
      expect(specs.current, closeTo(14.8, 0.01));
      expect(specs.speedRpm, 1450);
    });
  });
}
