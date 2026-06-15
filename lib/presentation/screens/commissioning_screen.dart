import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/audit_log_service.dart';
import '../../core/services/modbus_tcp_client.dart';
import '../../core/services/modbus_tcp_client.dart';
import '../../data/models/audit_event.dart';
import '../../data/models/vfd_parameter.dart';
import '../providers/vfd_provider.dart';
import '../widgets/app_card.dart';

class CommissioningScreen extends StatefulWidget {
  const CommissioningScreen({super.key});

  @override
  State<CommissioningScreen> createState() => _CommissioningScreenState();
}

class _RegisterReadResult {
  final VfdParameter parameter;
  final int? pduAddress;
  final ModbusRegisterValue? value;
  final String? error;

  _RegisterReadResult({
    required this.parameter,
    this.pduAddress,
    this.value,
    this.error,
  });
}

class _CommissioningScreenState extends State<CommissioningScreen> {
  final _hostCtrl = TextEditingController(text: '192.168.1.10');
  final _portCtrl = TextEditingController(text: '502');
  final _unitCtrl = TextEditingController(text: '1');

  bool _reading = false;
  String? _status;
  List<_RegisterReadResult> _results = [];

  @override
  void dispose() {
    _hostCtrl.dispose();
    _portCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  int? _parseRegisterFromParam(VfdParameter p) {
    final code = p.paramCode.trim();
    final direct = int.tryParse(code);
    if (direct != null) return direct;

    final digits = RegExp(r'\d{3,5}').firstMatch(code);
    if (digits != null) {
      final n = int.tryParse(digits.group(0)!);
      if (n != null && n >= 1) {
        return n >= 30001 ? n : 40000 + n;
      }
    }
    return null;
  }

  Future<void> _readMappedParameters() async {
    final provider = context.read<VfdProvider>();
    final params = [
      ...provider.parameters,
      ...provider.protocolParameters,
    ];

    if (params.isEmpty) {
      setState(() => _status = 'Configure a VFD model with parameters first');
      return;
    }

    final host = _hostCtrl.text.trim();
    final port = int.tryParse(_portCtrl.text.trim()) ?? 502;
    final unitId = int.tryParse(_unitCtrl.text.trim()) ?? 1;

    setState(() {
      _reading = true;
      _status = 'Connecting to $host:$portâ€?;
      _results = [];
    });

    final mapped = <_RegisterReadResult>[];
    for (final p in params.take(20)) {
      final userAddr = _parseRegisterFromParam(p);
      if (userAddr == null) {
        mapped.add(_RegisterReadResult(
          parameter: p,
          error: 'No register in param code',
        ));
        continue;
      }

      final pdu = ModbusTcpClient.toPduAddress(userAddr);
      try {
        final values = await ModbusTcpClient.readHoldingRegisters(
          host: host,
          port: port,
          unitId: unitId,
          pduStartAddress: pdu,
          quantity: 1,
        );
        mapped.add(_RegisterReadResult(
          parameter: p,
          pduAddress: pdu,
          value: values.first,
        ));
      } catch (e) {
        mapped.add(_RegisterReadResult(
          parameter: p,
          pduAddress: pdu,
          error: e.toString(),
        ));
      }
    }

    await AuditLogService.log(
      category: AuditCategory.commissioning,
      action: 'Modbus read',
      detail: '$host â€?${mapped.where((r) => r.value != null).length}/${mapped.length} OK',
    );

    if (mounted) {
      setState(() {
        _reading = false;
        _results = mapped;
        _status = 'Read complete';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VfdProvider>();
    final contextLabel = provider.selectedVendor != null
        ? '${provider.selectedVendor!.name} ${provider.selectedModelName ?? ''}'
        : 'No VFD selected';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modbus Commissioning'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            icon: Icons.lan,
            title: 'Live read (Modbus TCP)',
            subtitle: 'Read-only FC03 â€?compare drive vs configured parameters',
            accentColor: Colors.teal.shade700,
            child: Text(
              'Context: $contextLabel',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _hostCtrl,
                  decoration: const InputDecoration(
                    labelText: 'IP address',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _portCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Port',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _unitCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Unit ID',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _reading ? null : _readMappedParameters,
              icon: _reading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(_reading ? 'Readingâ€? : 'Read mapped parameters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (_status != null) ...[
            const SizedBox(height: 8),
            Text(_status!, style: TextStyle(color: Colors.grey.shade600)),
          ],
          const SizedBox(height: 16),
          if (_results.isNotEmpty)
            ..._results.map((r) {
              final configured = r.parameter.userValue ?? r.parameter.defaultValue;
              final live = r.value?.asUInt16().toString() ?? r.error ?? '-';
              final match = r.value != null && configured == live;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(r.parameter.paramName),
                  subtitle: Text(
                    'Code: ${r.parameter.paramCode}'
                    '${r.pduAddress != null ? ' â€?PDU ${r.pduAddress}' : ''}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Live: $live', style: const TextStyle(fontSize: 12)),
                      Text(
                        'Config: $configured',
                        style: TextStyle(
                          fontSize: 11,
                          color: match ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 8),
          Text(
            'Safety: read-only mode. Ensure network access to the drive is authorized. '
            'Register mapping is inferred from parameter codes â€?verify against the manual.',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
