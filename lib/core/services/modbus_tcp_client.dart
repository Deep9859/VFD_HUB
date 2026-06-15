import 'dart:io';
import 'dart:typed_data';

class ModbusException implements Exception {
  final String message;
  ModbusException(this.message);
  @override
  String toString() => message;
}

class ModbusRegisterValue {
  final int address;
  final int rawValue;

  const ModbusRegisterValue({required this.address, required this.rawValue});

  double asUInt16() => rawValue.toDouble();
  int asInt16() => rawValue > 32767 ? rawValue - 65536 : rawValue;
}

class ModbusTcpClient {
  static int _transactionId = 0;

  /// Read holding registers (Modbus function 0x03).
  static Future<List<ModbusRegisterValue>> readHoldingRegisters({
    required String host,
    int port = 502,
    int unitId = 1,
    required int pduStartAddress,
    required int quantity,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    if (quantity < 1 || quantity > 125) {
      throw ModbusException('Quantity must be 1–125');
    }

    final socket = await Socket.connect(host, port, timeout: timeout);
    try {
      socket.add(_buildReadRequest(
        unitId: unitId,
        startAddress: pduStartAddress,
        quantity: quantity,
      ));
      await socket.flush();

      final response = await _readResponse(socket, timeout);
      return _parseReadResponse(response, pduStartAddress);
    } finally {
      await socket.close();
    }
  }

  /// Convert user-facing address (40001) to PDU address (0-based).
  static int toPduAddress(int userAddress) {
    if (userAddress >= 40001) return userAddress - 40001;
    if (userAddress >= 30001) return userAddress - 30001;
    return userAddress;
  }

  static Uint8List _buildReadRequest({
    required int unitId,
    required int startAddress,
    required int quantity,
  }) {
    _transactionId = (_transactionId + 1) & 0xFFFF;
    final pdu = Uint8List(6);
    pdu[0] = unitId;
    pdu[1] = 0x03;
    pdu[2] = (startAddress >> 8) & 0xFF;
    pdu[3] = startAddress & 0xFF;
    pdu[4] = (quantity >> 8) & 0xFF;
    pdu[5] = quantity & 0xFF;

    final mbap = Uint8List(7 + pdu.length);
    mbap[0] = (_transactionId >> 8) & 0xFF;
    mbap[1] = _transactionId & 0xFF;
    mbap[2] = 0;
    mbap[3] = 0;
    final length = pdu.length + 1;
    mbap[4] = (length >> 8) & 0xFF;
    mbap[5] = length & 0xFF;
    mbap.setRange(6, 6 + pdu.length, pdu);
    return mbap;
  }

  static Future<Uint8List> _readResponse(
    Socket socket,
    Duration timeout,
  ) async {
    final deadline = DateTime.now().add(timeout);
    final buffer = <int>[];

    while (buffer.length < 6) {
      final remaining = deadline.difference(DateTime.now());
      if (remaining.isNegative) {
        throw ModbusException('Read timeout (header)');
      }
      buffer.addAll(await socket.timeout(remaining).first);
    }

    final pduLength = (buffer[4] << 8) | buffer[5];
    final total = 6 + pduLength;
    while (buffer.length < total) {
      final remaining = deadline.difference(DateTime.now());
      if (remaining.isNegative) {
        throw ModbusException('Read timeout (body)');
      }
      buffer.addAll(await socket.timeout(remaining).first);
    }

    return Uint8List.fromList(buffer.sublist(0, total));
  }

  static List<ModbusRegisterValue> _parseReadResponse(
    Uint8List response,
    int startPdu,
  ) {
    if (response.length < 9) {
      throw ModbusException('Response too short');
    }
    final functionCode = response[7];
    if (functionCode & 0x80 != 0) {
      final code = response[8];
      throw ModbusException('Modbus exception code $code');
    }
    final byteCount = response[8];
    final values = <ModbusRegisterValue>[];
    for (var i = 0; i < byteCount; i += 2) {
      final hi = response[9 + i];
      final lo = response[10 + i];
      final raw = (hi << 8) | lo;
      values.add(ModbusRegisterValue(
        address: startPdu + (i ~/ 2),
        rawValue: raw,
      ));
    }
    return values;
  }
}
