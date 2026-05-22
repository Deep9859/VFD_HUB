import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/vfd_provider.dart';
import '../widgets/app_card.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _isProcessing = true);

    final provider = context.read<VfdProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Parse QR code data
    final result = await _parseQRCode(code, provider);

    if (!mounted) return;

    if (result['success']) {
      // Show success dialog
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700),
              const SizedBox(width: 8),
              const Text('VFD Detected'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Vendor', result['vendor'] ?? 'N/A'),
              _buildInfoRow('Model', result['model'] ?? 'N/A'),
              if (result['serial'] != null)
                _buildInfoRow('Serial', result['serial']),
              if (result['power'] != null)
                _buildInfoRow('Power', '${result['power']} kW'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _isProcessing = false);
              },
              child: const Text('Scan Again'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                navigator.pop(result);
              },
              child: const Text('Load Configuration'),
            ),
          ],
        ),
      );
    } else {
      if (!mounted) return;
      // Show error
      messenger.showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Invalid QR Code'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isProcessing = false);
    }
  }

  Future<Map<String, dynamic>> _parseQRCode(
      String code, VfdProvider provider) async {
    try {
      // QR Code format examples:
      // 1. Simple: "ABB|ACS580|7.5"
      // 2. Detailed: "VENDOR:ABB|MODEL:ACS580|POWER:7.5|SERIAL:12345"
      // 3. JSON: {"vendor":"ABB","model":"ACS580","power":7.5}

      Map<String, dynamic> result = {'success': false};

      // Try JSON format: {"vendor":"ABB","model":"ACS580","power":7.5}
      if (code.trim().startsWith('{')) {
        try {
          final json = jsonDecode(code.trim()) as Map<String, dynamic>;
          final vendor = (json['vendor'] ?? json['VENDOR'] ?? '').toString().trim();
          final model = (json['model'] ?? json['MODEL'] ?? '').toString().trim();
          final power = json['power'] ?? json['POWER'];
          final serial = (json['serial'] ?? json['SERIAL'])?.toString().trim();

          if (vendor.isNotEmpty && model.isNotEmpty) {
            final vendorExists = provider.vendors
                .any((v) => v.name.toLowerCase() == vendor.toLowerCase());
            if (!vendorExists) {
              return {'success': false, 'error': 'Vendor "$vendor" not found in database'};
            }
            return {
              'success': true,
              'vendor': vendor,
              'model': model,
              'power': power is num ? power.toDouble() : double.tryParse(power?.toString() ?? ''),
              'serial': serial,
            };
          }
        } catch (_) {
          // Not valid JSON, fall through to pipe format
        }
      }

      // Try pipe-separated format
      if (code.contains('|')) {
        final parts = code.split('|');

        // Simple format: VENDOR|MODEL|POWER
        if (parts.length >= 2) {
          String vendor = parts[0].trim();
          String model = parts[1].trim();
          double? power;
          String? serial;

          // Check if it's key-value format
          if (vendor.contains(':')) {
            for (var part in parts) {
              final kv = part.split(':');
              if (kv.length == 2) {
                final key = kv[0].trim().toUpperCase();
                final value = kv[1].trim();

                switch (key) {
                  case 'VENDOR':
                    vendor = value;
                    break;
                  case 'MODEL':
                    model = value;
                    break;
                  case 'POWER':
                    power = double.tryParse(value);
                    break;
                  case 'SERIAL':
                    serial = value;
                    break;
                }
              }
            }
          } else {
            // Simple format
            if (parts.length >= 3) {
              power = double.tryParse(parts[2].trim());
            }
            if (parts.length >= 4) {
              serial = parts[3].trim();
            }
          }

          // Validate vendor exists
          final vendorExists = provider.vendors
              .any((v) => v.name.toLowerCase() == vendor.toLowerCase());

          if (!vendorExists) {
            return {
              'success': false,
              'error': 'Vendor "$vendor" not found in database'
            };
          }

          result = {
            'success': true,
            'vendor': vendor,
            'model': model,
            'power': power,
            'serial': serial,
          };
        }
      }

      if (!result['success']) {
        return {'success': false, 'error': 'Invalid QR code format'};
      }

      return result;
    } catch (e) {
      return {'success': false, 'error': 'Error parsing QR code: $e'};
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan VFD QR Code'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController,
              builder: (context, state, child) {
                switch (state.torchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on);
                  default:
                    return const Icon(Icons.flash_off);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          // Overlay with scanning frame
          CustomPaint(
            painter: ScannerOverlay(),
            child: Container(),
          ),
          // Instructions
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: AppCard(
              backgroundColor: Colors.black.withOpacity(0.72),
              accentColor: Colors.green,
              title: 'Ready to Scan',
              subtitle: 'Position QR code within the frame',
              titleColor: Colors.white,
              subtitleColor: Colors.white70,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_scanner,
                      color: Colors.white, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Scan VFD nameplate or configuration QR code',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          // Manual entry button
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.keyboard),
                label: const Text('Enter Manually'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade700,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () => _showManualEntryDialog(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualEntryDialog(BuildContext context) {
    final vendorController = TextEditingController();
    final modelController = TextEditingController();
    final powerController = TextEditingController();
    final serialController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Manual Entry'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: vendorController,
                decoration: const InputDecoration(
                  labelText: 'Vendor (e.g., ABB)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: modelController,
                decoration: const InputDecoration(
                  labelText: 'Model (e.g., ACS580)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: powerController,
                decoration: const InputDecoration(
                  labelText: 'Power (kW) - Optional',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: serialController,
                decoration: const InputDecoration(
                  labelText: 'Serial Number - Optional',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final vendor = vendorController.text.trim();
              final model = modelController.text.trim();

              if (vendor.isEmpty || model.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vendor and Model are required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final result = {
                'success': true,
                'vendor': vendor,
                'model': model,
                'power': double.tryParse(powerController.text.trim()),
                'serial': serialController.text.trim().isEmpty
                    ? null
                    : serialController.text.trim(),
              };

              Navigator.pop(ctx);
              Navigator.pop(context, result);
            },
            child: const Text('Load'),
          ),
        ],
      ),
    );
  }
}

// Custom painter for scanner overlay
class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final scanAreaSize = size.width * 0.7;
    final left = (size.width - scanAreaSize) / 2;
    final top = (size.height - scanAreaSize) / 2;

    // Draw overlay with transparent center
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
        const Radius.circular(12),
      ))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw corner brackets
    final bracketPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const bracketLength = 30.0;

    // Top-left
    canvas.drawLine(Offset(left, top + bracketLength), Offset(left, top),
        bracketPaint);
    canvas.drawLine(Offset(left, top), Offset(left + bracketLength, top),
        bracketPaint);

    // Top-right
    canvas.drawLine(Offset(left + scanAreaSize - bracketLength, top),
        Offset(left + scanAreaSize, top), bracketPaint);
    canvas.drawLine(Offset(left + scanAreaSize, top),
        Offset(left + scanAreaSize, top + bracketLength), bracketPaint);

    // Bottom-left
    canvas.drawLine(Offset(left, top + scanAreaSize - bracketLength),
        Offset(left, top + scanAreaSize), bracketPaint);
    canvas.drawLine(Offset(left, top + scanAreaSize),
        Offset(left + bracketLength, top + scanAreaSize), bracketPaint);

    // Bottom-right
    canvas.drawLine(
        Offset(left + scanAreaSize - bracketLength, top + scanAreaSize),
        Offset(left + scanAreaSize, top + scanAreaSize),
        bracketPaint);
    canvas.drawLine(Offset(left + scanAreaSize, top + scanAreaSize),
        Offset(left + scanAreaSize, top + scanAreaSize - bracketLength),
        bracketPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
