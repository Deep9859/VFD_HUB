import 'package:flutter_test/flutter_test.dart';
import 'package:vfd_param_app/core/services/modbus_tcp_client.dart';

void main() {
  group('ModbusTcpClient', () {
    test('toPduAddress converts 40001-style addresses', () {
      expect(ModbusTcpClient.toPduAddress(40001), 0);
      expect(ModbusTcpClient.toPduAddress(40100), 99);
      expect(ModbusTcpClient.toPduAddress(30001), 0);
    });
  });
}
