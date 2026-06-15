import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import '../widgets/app_card.dart';

class QRGeneratorScreen extends StatefulWidget {
  const QRGeneratorScreen({super.key});

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  final _vendorController = TextEditingController();
  final _modelController = TextEditingController();
  final _powerController = TextEditingController();
  final _serialController = TextEditingController();

  String _generatedCode = '';
  String _selectedFormat = 'simple';

  @override
  void dispose() {
    _vendorController.dispose();
    _modelController.dispose();
    _powerController.dispose();
    _serialController.dispose();
    super.dispose();
  }

  void _generateQRCode() {
    final vendor = _vendorController.text.trim();
    final model = _modelController.text.trim();
    final power = _powerController.text.trim();
    final serial = _serialController.text.trim();

    if (vendor.isEmpty || model.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vendor and Model are required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String code = '';

    switch (_selectedFormat) {
      case 'simple':
        code = vendor;
        code += '|$model';
        if (power.isNotEmpty) code += '|$power';
        if (serial.isNotEmpty) code += '|$serial';
        break;

      case 'detailed':
        code = 'VENDOR:$vendor|MODEL:$model';
        if (power.isNotEmpty) code += '|POWER:$power';
        if (serial.isNotEmpty) code += '|SERIAL:$serial';
        break;

      case 'json':
        code = '{"vendor":"$vendor","model":"$model"';
        if (power.isNotEmpty) code += ',"power":$power';
        if (serial.isNotEmpty) code += ',"serial":"$serial"';
        code += '}';
        break;
    }

    setState(() {
      _generatedCode = code;
    });
  }

  void _copyToClipboard() {
    if (_generatedCode.isEmpty) return;

    Clipboard.setData(ClipboardData(text: _generatedCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Code data copied to clipboard'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              icon: Icons.info,
              title: 'QR Code Generator',
              subtitle: 'Generate scannable VFD nameplate QR codes',
              accentColor: Colors.blue.shade700,
              backgroundColor: Colors.blue.shade50,
              child: Text(
                'Scan the QR below with VFD Hub or print it on a nameplate label.',
                style: TextStyle(
                  color: Colors.blue.shade900,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'QR Code Format',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'simple',
                  label: Text('Simple'),
                  icon: Icon(Icons.minimize),
                ),
                ButtonSegment(
                  value: 'detailed',
                  label: Text('Detailed'),
                  icon: Icon(Icons.list),
                ),
                ButtonSegment(
                  value: 'json',
                  label: Text('JSON'),
                  icon: Icon(Icons.code),
                ),
              ],
              selected: {_selectedFormat},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedFormat = newSelection.first;
                  _generatedCode = '';
                });
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'VFD Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _vendorController,
              decoration: const InputDecoration(
                labelText: 'Vendor *',
                hintText: 'e.g., ABB, Siemens, Delta',
                prefixIcon: Icon(Icons.business),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model *',
                hintText: 'e.g., ACS580, SINAMICS G120',
                prefixIcon: Icon(Icons.memory),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _powerController,
              decoration: const InputDecoration(
                labelText: 'Power Rating (kW)',
                hintText: 'e.g., 7.5',
                prefixIcon: Icon(Icons.bolt),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _serialController,
              decoration: const InputDecoration(
                labelText: 'Serial Number',
                hintText: 'e.g., 12345ABC',
                prefixIcon: Icon(Icons.tag),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.qr_code),
                label: const Text('Generate QR Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _generateQRCode,
              ),
            ),
            const SizedBox(height: 24),

            if (_generatedCode.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: _generatedCode,
                    version: QrVersions.auto,
                    size: 220,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Encoded Data',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: _copyToClipboard,
                    tooltip: 'Copy to clipboard',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  _generatedCode,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Ready to use',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Scan with VFD Hub QR scanner\n'
                      '2. Or print this screen / take a screenshot for the nameplate\n'
                      '3. Share encoded data via clipboard if needed',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text('QR Code Formats'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFormatInfo(
                'Simple Format',
                'VENDOR|MODEL|POWER|SERIAL',
                'ABB|ACS580|7.5|12345',
              ),
              const Divider(height: 24),
              _buildFormatInfo(
                'Detailed Format',
                'VENDOR:value|MODEL:value|...',
                'VENDOR:ABB|MODEL:ACS580|POWER:7.5',
              ),
              const Divider(height: 24),
              _buildFormatInfo(
                'JSON Format',
                '{"vendor":"...","model":"..."}',
                '{"vendor":"ABB","model":"ACS580"}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatInfo(String title, String format, String example) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          'Format: $format',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            example,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
