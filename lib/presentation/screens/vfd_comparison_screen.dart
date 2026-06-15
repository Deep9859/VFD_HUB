import 'package:flutter/material.dart';
import '../../core/config/supported_vendors.dart';
import '../../core/services/vfd_comparison_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/vfd_static_data.dart';
import '../../data/models/protocol_model.dart';
import '../../data/models/vfd_parameter.dart';
import '../widgets/app_card.dart';

class VFDComparisonScreen extends StatefulWidget {
  const VFDComparisonScreen({super.key});

  @override
  State<VFDComparisonScreen> createState() => _VFDComparisonScreenState();
}

class _Slot {
  String? vendor;
  VfdModelData? model;
  ModelComparisonData? detail;
  bool loading = false;
}

class _VFDComparisonScreenState extends State<VFDComparisonScreen>
    with SingleTickerProviderStateMixin {
  final List<_Slot> _slots = [_Slot(), _Slot(), _Slot()];
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail(int index) async {
    final slot = _slots[index];
    if (slot.vendor == null || slot.model == null) {
      setState(() => slot.detail = null);
      return;
    }
    setState(() => slot.loading = true);
    final detail = await VfdComparisonService.loadDetail(
      slot.vendor!,
      slot.model!,
    );
    if (mounted) {
      setState(() {
        slot.detail = detail;
        slot.loading = false;
      });
    }
  }

  List<_Slot> get _activeSlots =>
      _slots.where((s) => s.model != null).toList();

  @override
  Widget build(BuildContext context) {
    final hasSelection = _activeSlots.isNotEmpty;

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
        bottom: hasSelection
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Parameters'),
                  Tab(text: 'Protocols'),
                ],
              )
            : null,
      ),
      body: Column(
        children: [
          AppCard(
            title: 'Compare VFDs',
            subtitle: 'Up to 3 models — catalog + database parameters',
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
          if (_slots.any((s) => s.loading))
            const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: !hasSelection
                ? _buildEmptyState()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildParametersTab(),
                      _buildProtocolsTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelSelector(int index) {
    final slot = _slots[index];
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
              value: slot.vendor,
              items: VfdStaticData.vendorNames
                  .map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 12))))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  slot.vendor = v;
                  slot.model = null;
                  slot.detail = null;
                });
              },
            ),
            if (slot.vendor != null) ...[
              const SizedBox(height: 8),
              DropdownButton<VfdModelData>(
                isExpanded: true,
                hint: const Text('Model'),
                value: slot.model,
                items: VfdStaticData.getModelsByVendor(slot.vendor!)
                    .where((m) => SupportedVendors.catalogModelNames(
                          slot.vendor!,
                        ).contains(m.name))
                    .map((m) => DropdownMenuItem(
                          value: m,
                          child: Text(m.name, style: const TextStyle(fontSize: 11)),
                        ))
                    .toList(),
                onChanged: (m) {
                  setState(() => slot.model = m);
                  _loadDetail(index);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20,
          headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
          columns: [
            const DataColumn(
              label: Text('Feature', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ..._activeSlots.map(
              (s) => DataColumn(
                label: Text(s.model!.name, style: const TextStyle(fontSize: 11)),
              ),
            ),
          ],
          rows: [
            _overviewRow('Vendor', (s) => s.vendor ?? '-'),
            _overviewRow('Min Power', (s) => '${s.model!.minKw} kW'),
            _overviewRow('Max Power', (s) => '${s.model!.maxKw} kW'),
            _overviewRow('Application', (s) => s.model!.app),
            _overviewRow('Status', (s) => s.model!.status),
            _overviewRow('Comm Card', (s) => s.model!.commCard),
            _overviewRow('Default Protocol', (s) => s.model!.defaultProto),
            _overviewRow(
              'DB Parameters',
              (s) => '${s.detail?.parameters.length ?? 0} params',
            ),
            _overviewRow(
              'DB Protocols',
              (s) => '${s.detail?.protocols.length ?? 0} options',
            ),
            _overviewRow(
              'Sample config',
              (s) {
                final d = s.detail;
                if (d?.samplePowerKw == null) return '-';
                return '${d!.samplePowerKw} kW @ ${d.sampleVoltage ?? '?'}';
              },
            ),
          ],
        ),
      ),
    );
  }

  DataRow _overviewRow(String label, String Function(_Slot) getValue) {
    return DataRow(cells: [
      DataCell(Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
      ..._activeSlots.map((s) => DataCell(Text(getValue(s), style: const TextStyle(fontSize: 11)))),
    ]);
  }

  Widget _buildParametersTab() {
    final allNames = <String>{};
    for (final slot in _activeSlots) {
      for (final p in slot.detail?.parameters ?? const <VfdParameter>[]) {
        allNames.add(p.paramName);
      }
    }
    final sorted = allNames.toList()..sort();

    if (sorted.isEmpty) {
      return const Center(child: Text('No parameter data in database for selected models'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (ctx, i) {
        final name = sorted[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            children: _activeSlots.map((slot) {
              final param = slot.detail?.parameters
                  .where((p) => p.paramName == name)
                  .firstOrNull;
              return ListTile(
                dense: true,
                title: Text(slot.model!.name, style: const TextStyle(fontSize: 12)),
                subtitle: Text(
                  param != null
                      ? 'Default: ${param.defaultValue} • Group: ${param.groupName}'
                      : 'Not in database',
                  style: const TextStyle(fontSize: 11),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildProtocolsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: _activeSlots.map((slot) {
        final protocols = slot.detail?.protocols ?? const <Protocol>[];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${slot.vendor} ${slot.model!.name}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (protocols.isEmpty)
                  Text('No protocols in DB', style: TextStyle(color: Colors.grey.shade600))
                else
                  ...protocols.map(
                    (p) => ListTile(
                      dense: true,
                      leading: Icon(
                        p.type.toLowerCase().contains('ethernet')
                            ? Icons.lan
                            : Icons.cable,
                        size: 20,
                      ),
                      title: Text(p.name, style: const TextStyle(fontSize: 13)),
                      subtitle: Text(
                        '${p.type}${(p.commCard ?? '').isNotEmpty ? ' • ${p.commCard}' : ''}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return AppCard(
      icon: Icons.compare_arrows,
      title: 'No Comparison Yet',
      subtitle: 'Select models to compare catalog, parameters and protocols',
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
      for (final slot in _slots) {
        slot.vendor = null;
        slot.model = null;
        slot.detail = null;
        slot.loading = false;
      }
    });
  }
}
