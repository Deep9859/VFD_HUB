import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/vfd_static_data.dart';
import '../../data/models/vfd_search_hit.dart';
import '../widgets/app_card.dart';

class SmartSearchScreen extends StatefulWidget {
  const SmartSearchScreen({super.key});

  @override
  State<SmartSearchScreen> createState() => _SmartSearchScreenState();
}

class _SmartSearchScreenState extends State<SmartSearchScreen> {
  final _searchController = TextEditingController();
  List<VfdSearchHit> _results = [];
  String? _selectedVendor;
  String? _selectedStatus;
  String? _selectedApp;
  final double _minPower = 0;
  final double _maxPower = 1000;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    final List<VfdSearchHit> results = [];

    for (var vendor in VfdStaticData.vendorNames) {
      final models = VfdStaticData.getModelsByVendor(vendor);
      for (var model in models) {
        // Apply filters
        if (_selectedVendor != null && vendor != _selectedVendor) continue;
        if (_selectedStatus != null && model.status != _selectedStatus) continue;
        if (_selectedApp != null && !model.app.contains(_selectedApp!)) continue;
        if (model.minKw < _minPower || model.maxKw > _maxPower) continue;

        // Search in name, vendor, app
        if (query.isNotEmpty) {
          if (!model.name.toLowerCase().contains(query) &&
              !vendor.toLowerCase().contains(query) &&
              !model.app.toLowerCase().contains(query)) continue;
        }

        results.add(VfdSearchHit(vendor: vendor, model: model));
      }
    }

    setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          AppCard(
            icon: Icons.search,
            title: 'Smart Search',
            subtitle: 'Find VFD models quickly with filters and search',
            backgroundColor: Theme.of(context).cardColor,
            accentColor: AppTheme.primary,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search VFD models...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch();
                        },
                      )
                    : null,
              ),
              onChanged: (_) => _performSearch(),
            ),
          ),

          // Active Filters
          if (_hasActiveFilters()) _buildActiveFilters(),

          // Results
          Expanded(
            child: _results.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (ctx, i) => _buildResultCard(_results[i], i),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(VfdSearchHit hit, int index) {
    final model = hit.model;
    final statusPrimary = model.status == 'Current' ? Colors.green : Colors.orange;
    return InkWell(
      onTap: () => Navigator.pop(context, hit),
      borderRadius: BorderRadius.circular(16),
      child: AppCard(
      icon: Icons.devices,
      title: model.name,
      subtitle: '${hit.vendor} • ${model.minKw}-${model.maxKw} kW',
      backgroundColor: statusPrimary.withOpacity(0.08),
      accentColor: statusPrimary,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: model.status == 'Current' ? Colors.green : Colors.orange,
            child: Text(model.name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(model.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(model.app, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
          Chip(
            label: Text(model.status, style: const TextStyle(fontSize: 11)),
            backgroundColor: model.status == 'Current' ? Colors.green.shade100 : Colors.orange.shade100,
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 18),
            onPressed: () => Navigator.pop(context, hit),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No results found', style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedVendor != null ||
        _selectedStatus != null ||
        _selectedApp != null ||
        _minPower > 0 ||
        _maxPower < 1000;
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (_selectedVendor != null)
            Chip(
              label: Text(_selectedVendor!),
              onDeleted: () {
                setState(() => _selectedVendor = null);
                _performSearch();
              },
            ),
          if (_selectedStatus != null)
            Chip(
              label: Text(_selectedStatus!),
              onDeleted: () {
                setState(() => _selectedStatus = null);
                _performSearch();
              },
            ),
        ],
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Vendor'),
                value: _selectedVendor,
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ...VfdStaticData.vendorNames
                      .map((v) => DropdownMenuItem(value: v, child: Text(v))),
                ],
                onChanged: (v) => setModalState(() => _selectedVendor = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Status'),
                value: _selectedStatus,
                items: const [
                  DropdownMenuItem(value: null, child: Text('All')),
                  DropdownMenuItem(value: 'Current', child: Text('Current')),
                  DropdownMenuItem(value: 'Legacy', child: Text('Legacy')),
                ],
                onChanged: (v) => setModalState(() => _selectedStatus = v),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {});
                  _performSearch();
                },
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
