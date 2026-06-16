import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_form_styles.dart';
import '../../core/theme/theme_context.dart';
import '../../data/services/manual_manager_service.dart';
import '../widgets/app_card.dart';

class ManualImportScreen extends StatefulWidget {
  const ManualImportScreen({super.key});

  @override
  State<ManualImportScreen> createState() => _ManualImportScreenState();
}

class _ManualImportScreenState extends State<ManualImportScreen> {
  final _vendorController = TextEditingController();
  final _modelController = TextEditingController();
  String _selectedManualType = 'User Manual';
  String? _selectedFilePath;
  bool _isImporting = false;
  Map<String, dynamic>? _storageInfo;

  final List<String> _manualTypes = [
    'User Manual',
    'Parameter Guide',
    'Troubleshooting Guide',
    'Quick Start Guide',
    'Installation Manual',
    'Communication Manual',
  ];

  final List<String> _vendors = [
    'ABB',
    'Yaskawa',
    'INVT',
    'Danfoss',
    'Schneider',
    'Allen Bradley',
    'Siemens',
    'Mitsubishi',
    'Delta',
  ];

  @override
  void initState() {
    super.initState();
    _loadStorageInfo();
  }

  Future<void> _loadStorageInfo() async {
    final info = await ManualManagerService.getStorageInfo();
    setState(() => _storageInfo = info);
  }

  Future<void> _pickPdfFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _selectedFilePath = result.files.single.path);
      }
    } catch (e) {
      _showError('File selection failed: $e');
    }
  }

  Future<void> _importManual() async {
    if (_vendorController.text.isEmpty) {
      _showError('Vendor name enter karein');
      return;
    }
    if (_modelController.text.isEmpty) {
      _showError('Model name enter karein');
      return;
    }
    if (_selectedFilePath == null) {
      _showError('PDF file select karein');
      return;
    }

    setState(() => _isImporting = true);

    try {
      await ManualManagerService.importManual(
        _selectedFilePath!,
        _vendorController.text,
        _modelController.text,
        _selectedManualType,
      );

      await _loadStorageInfo();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Manual successfully imported!'),
            backgroundColor: context.successColor,
          ),
        );
      }

      // Clear form
      _vendorController.clear();
      _modelController.clear();
      setState(() {
        _selectedFilePath = null;
        _selectedManualType = 'User Manual';
      });
    } catch (e) {
      _showError('Import failed: $e');
    } finally {
      setState(() => _isImporting = false);
    }
  }

  Future<void> _importBulkManuals() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => _isImporting = true);

        int successCount = 0;
        int failCount = 0;

        for (var file in result.files) {
          if (file.path == null) continue;

          try {
            // Extract vendor and model from filename
            // Expected format: VendorName_ModelName_ManualType.pdf
            final fileName = file.name.replaceAll('.pdf', '');
            final parts = fileName.split('_');

            if (parts.length >= 3) {
              final vendor = parts[0];
              final model = parts[1];
              final manualType = parts.sublist(2).join(' ');

              await ManualManagerService.importManual(
                file.path!,
                vendor,
                model,
                manualType,
              );
              successCount++;
            } else {
              failCount++;
            }
          } catch (e) {
            failCount++;
          }
        }

        await _loadStorageInfo();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ $successCount imported, $failCount failed'),
              backgroundColor: successCount > 0 ? context.successColor : context.warningColor,
            ),
          );
        }

        setState(() => _isImporting = false);
      }
    } catch (e) {
      setState(() => _isImporting = false);
      _showError('Bulk import failed: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: context.errorColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Import'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Storage Info Card
            if (_storageInfo != null)
              AppCard(
                icon: Icons.storage,
                title: 'Storage Info',
                subtitle: 'Current manual storage usage and availability',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoChip('Total Manuals', '${_storageInfo!['totalFiles']}', Icons.picture_as_pdf),
                    _infoChip('Storage Used', '${_storageInfo!['totalSizeMB']} MB', Icons.sd_storage),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Single Manual Import
            Text(
              'Single Manual Import',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Vendor Dropdown
            _buildDropdown(
              label: 'Vendor',
              value: _vendorController.text.isEmpty ? null : _vendorController.text,
              items: _vendors,
              onChanged: (value) {
                setState(() => _vendorController.text = value ?? '');
              },
            ),

            const SizedBox(height: 16),

            // Model Name
            TextField(
              controller: _modelController,
              style: AppFormStyles.fieldText(context),
              decoration: AppFormStyles.decoration(
                context,
                labelText: 'Model Name',
                hintText: 'e.g., ACS580, SINAMICS G120',
                prefixIcon: const Icon(Icons.memory),
              ),
            ),

            const SizedBox(height: 16),

            // Manual Type Dropdown
            _buildDropdown(
              label: 'Manual Type',
              value: _selectedManualType,
              items: _manualTypes,
              onChanged: (value) {
                setState(() => _selectedManualType = value ?? 'User Manual');
              },
            ),

            const SizedBox(height: 16),

            // File Picker
            OutlinedButton.icon(
              onPressed: _pickPdfFile,
              icon: const Icon(Icons.attach_file),
              label: Text(_selectedFilePath == null 
                ? 'Select PDF File' 
                : 'File: ${_selectedFilePath!.split('\\').last}'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),

            const SizedBox(height: 24),

            // Import Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isImporting ? null : _importManual,
                icon: _isImporting 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.onPrimaryBg,
                      ),
                    )
                  : const Icon(Icons.upload),
                label: Text(_isImporting ? 'Importing...' : 'Import Manual'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // Bulk Import
            Text(
              'Bulk Import',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'File naming format: VendorName_ModelName_ManualType.pdf\nExample: ABB_ACS580_User_Manual.pdf',
              style: context.captionStyle?.copyWith(color: context.onSurfaceMuted),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isImporting ? null : _importBulkManuals,
                icon: const Icon(Icons.folder_open),
                label: const Text('Import Multiple PDFs'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            AppCard(
              icon: Icons.info_outline,
              title: 'Instructions',
              subtitle: 'Follow these steps to import manuals cleanly',
              backgroundColor: context.warningBg,
              accentColor: context.warningColor,
              titleColor: context.onSurface,
              subtitleColor: context.onSurfaceMuted,
              child: Text(
                '1. PDF files app ke documents folder mein store hongi\n'
                '2. Manuals vendor aur model ke according organize hongi\n'
                '3. App mein manual section se directly access kar sakte hain\n'
                '4. Bulk import ke liye proper file naming follow karein',
                style: context.captionStyle?.copyWith(color: context.warningColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: AppFormStyles.decoration(context, labelText: label),
      value: value,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _infoChip(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: context.infoColor),
            const SizedBox(width: 4),
            Text(label, style: context.captionStyle?.copyWith(color: context.onSurfaceMuted)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.titleStyle?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.infoColor,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _vendorController.dispose();
    _modelController.dispose();
    super.dispose();
  }
}
