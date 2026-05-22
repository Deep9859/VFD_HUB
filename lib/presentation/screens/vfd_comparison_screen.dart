import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/vfd_static_data.dart';
import '../widgets/app_card.dart';

class VFDComparisonScreen extends StatefulWidget {
  const VFDComparisonScreen({super.key});

  @override
  State<VFDComparisonScreen> createState() => _VFDComparisonScreenState();
}

class _VFDComparisonScreenState extends State<VFDComparisonScreen> {
  final List<VfdModelData?> _selectedModels = [null, null, null];
  final List<String?> _selectedVendors = [null, null, null];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare VFDs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearAll,
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppCard(
              title: 'Compare VFDs',
              subtitle: 'Choose up to 3 devices',
              accentColor: AppTheme.primary,
              child: Row(
                children: [
                  Expanded(child: _buildModelSelector(0)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildModelSelector(1)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildModelSelector(2)),
                ],
              ),
            ),

            if (_selectedModels.any((m) => m != null))
              AppCard(
                title: 'Comparison',
                subtitle: 'Model characteristics at a glance',
                accentColor: AppTheme.primary,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildComparisonTable(),
                ),
              )
            else
              _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildModelSelector(int index) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text('VFD ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Vendor'),
              value: _selectedVendors[index],
              items: VfdStaticData.vendorNames
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  _selectedVendors[index] = v;
                  _selectedModels[index] = null;
                });
              },
            ),
            if (_selectedVendors[index] != null) ...[
              const SizedBox(height: 8),
              DropdownButton<VfdModelData>(
                isExpanded: true,
                hint: const Text('Model'),
                value: _selectedModels[index],
                items: VfdStaticData.getModelsByVendor(_selectedVendors[index]!)
                    .map((m) => DropdownMenuItem(
                        value: m, child: Text(m.name, style: const TextStyle(fontSize: 12))))
                    .toList(),
                onChanged: (m) => setState(() => _selectedModels[index] = m),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        headingRowColor: WidgetStateProperty.all(Colors.blue.shade100),
        columns: [
          const DataColumn(label: Text('Feature', style: TextStyle(fontWeight: FontWeight.bold))),
          ..._selectedModels.map((m) => DataColumn(
              label: Text(m?.name ?? '-', style: const TextStyle(fontSize: 11)))),
        ],
        rows: [
          _buildRow('Vendor', (m) => _selectedVendors[_selectedModels.indexOf(m)] ?? '-'),
          _buildRow('Min Power', (m) => '${m.minKw} kW'),
          _buildRow('Max Power', (m) => '${m.maxKw} kW'),
          _buildRow('Application', (m) => m.app),
          _buildRow('Status', (m) => m.status, colorize: true),
          _buildRow('Comm Card', (m) => m.commCard),
          _buildRow('Protocol', (m) => m.defaultProto),
        ],
      ),
    );
  }

  DataRow _buildRow(String label, String Function(VfdModelData) getValue, {bool colorize = false}) {
    return DataRow(cells: [
      DataCell(Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
      ..._selectedModels.map((m) {
        if (m == null) return const DataCell(Text('-'));
        final value = getValue(m);
        return DataCell(
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: colorize && value == 'Current' ? Colors.green : null,
            ),
          ),
        );
      }),
    ]);
  }

  Widget _buildEmptyState() {
    return AppCard(
      icon: Icons.compare_arrows,
      title: 'No Comparison Yet',
      subtitle: 'Select VFD models to see differences',
      accentColor: Colors.indigo,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(Icons.compare_arrows, size: 64, color: Colors.indigo.shade200),
            const SizedBox(height: 16),
            Text('Select VFDs to compare',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _selectedModels.fillRange(0, 3, null);
      _selectedVendors.fillRange(0, 3, null);
    });
  }
}
