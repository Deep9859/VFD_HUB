import 'package:flutter/material.dart';
import '../../core/config/supported_vendors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/search_utils.dart';
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
  double _minPower = 0;
  double _maxPower = 1000;

  static const _applicationOptions = [
    'General Purpose',
    'Pump',
    'Fan',
    'HVAC',
    'Conveyor',
    'Crane',
    'Machine Tool',
  ];

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text;
    final List<VfdSearchHit> results = [];

    for (final vendor in VfdStaticData.vendorNames) {
      final catalog = SupportedVendors.catalogModelNames(vendor).toSet();
      final models = VfdStaticData.getModelsByVendor(vendor)
          .where((m) => catalog.contains(m.name));
      for (final model in models) {
        if (_selectedVendor != null && vendor != _selectedVendor) continue;
        if (_selectedStatus != null && model.status != _selectedStatus) {
          continue;
        }
        if (_selectedApp != null &&
            !model.app.toLowerCase().contains(_selectedApp!.toLowerCase())) {
          continue;
        }
        // Overlap: model range intersects filter range
        if (model.maxKw < _minPower || model.minKw > _maxPower) continue;

        if (!SearchUtils.matchesAnyField(
          query,
          [model.name, vendor, model.app],
        )) {
          continue;
        }

        results.add(VfdSearchHit(vendor: vendor, model: model));
      }
    }

    results.sort((a, b) {
      final vendorCmp =
          SupportedVendors.sortIndex(a.vendor).compareTo(SupportedVendors.sortIndex(b.vendor));
      if (vendorCmp != 0) return vendorCmp;
      return a.model.name.compareTo(b.model.name);
    });

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
            subtitle:
                '${_results.length} models • fuzzy match, power range & filters',
            backgroundColor: Theme.of(context).cardColor,
            accentColor: AppTheme.primary,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by model, vendor, application…',
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

          if (_hasActiveFilters()) _buildActiveFilters(),

          Expanded(
            child: _results.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (ctx, i) => _buildResultCard(_results[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(VfdSearchHit hit) {
    final model = hit.model;
    final statusPrimary =
        model.status == 'Current' ? Colors.green : Colors.orange;
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
              backgroundColor:
                  model.status == 'Current' ? Colors.green : Colors.orange,
              child: Text(
                model.name[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    model.app,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Chip(
              label: Text(model.status, style: const TextStyle(fontSize: 11)),
              backgroundColor: model.status == 'Current'
                  ? Colors.green.shade100
                  : Colors.orange.shade100,
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_ios, size: 18),
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
          Text(
            'No results found',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Try fewer filters or a shorter search term',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
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
        runSpacing: 4,
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
          if (_selectedApp != null)
            Chip(
              label: Text(_selectedApp!),
              onDeleted: () {
                setState(() => _selectedApp = null);
                _performSearch();
              },
            ),
          if (_minPower > 0 || _maxPower < 1000)
            Chip(
              label: Text('${_minPower.round()}-${_maxPower.round()} kW'),
              onDeleted: () {
                setState(() {
                  _minPower = 0;
                  _maxPower = 1000;
                });
                _performSearch();
              },
            ),
        ],
      ),
    );
  }

  void _showFilters() {
    var minP = _minPower;
    var maxP = _maxPower;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Application'),
                value: _selectedApp,
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ..._applicationOptions.map(
                    (a) => DropdownMenuItem(value: a, child: Text(a)),
                  ),
                ],
                onChanged: (v) => setModalState(() => _selectedApp = v),
              ),
              const SizedBox(height: 16),
              Text(
                'Power range: ${minP.round()} – ${maxP.round()} kW',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              RangeSlider(
                values: RangeValues(minP, maxP),
                min: 0,
                max: 1000,
                divisions: 100,
                labels: RangeLabels('${minP.round()}', '${maxP.round()}'),
                onChanged: (range) =>
                    setModalState(() {
                      minP = range.start;
                      maxP = range.end;
                    }),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedVendor = null;
                          _selectedStatus = null;
                          _selectedApp = null;
                          minP = 0;
                          maxP = 1000;
                        });
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _minPower = minP;
                          _maxPower = maxP;
                        });
                        Navigator.pop(ctx);
                        _performSearch();
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
