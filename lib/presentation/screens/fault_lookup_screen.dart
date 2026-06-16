import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_context.dart';
import '../../data/models/vfd_fault.dart';
import '../providers/vfd_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/vendor_avatar.dart';

class FaultLookupScreen extends StatefulWidget {
  const FaultLookupScreen({super.key});

  @override
  State<FaultLookupScreen> createState() => _FaultLookupScreenState();
}

class _FaultLookupScreenState extends State<FaultLookupScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedVendorId;
  String _selectedSeverity = 'All';
  final TextEditingController _searchController = TextEditingController();
  List<VfdFault> _faultCodes = [];
  List<VfdFault> _filteredFaultCodes = [];
  bool _isLoading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  static const _severities = ['All', 'Critical', 'High', 'Medium', 'Low'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFaultCodes = _faultCodes.where((f) {
        final matchesQuery = query.isEmpty ||
            f.errorCode.toLowerCase().contains(query) ||
            f.description.toLowerCase().contains(query) ||
            f.solution.toLowerCase().contains(query);
        final matchesSeverity =
            _selectedSeverity == 'All' || f.severity == _selectedSeverity;
        return matchesQuery && matchesSeverity;
      }).toList();
    });
  }

  Future<void> _loadFaultCodes(String vendorId) async {
    setState(() => _isLoading = true);
    _animController.reset();
    final codes = await context.read<VfdProvider>().getFaultCodesByVendor(vendorId);
    setState(() {
      _faultCodes = codes;
      _filteredFaultCodes = codes;
      _isLoading = false;
    });
    _applyFilters();
    _animController.forward();
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical': return Colors.red.shade700;
      case 'high':     return Colors.orange.shade700;
      case 'medium':   return Colors.amber.shade700;
      case 'low':      return Colors.green.shade700;
      default:         return context.onSurfaceMuted;
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical': return Icons.dangerous;
      case 'high':     return Icons.warning_rounded;
      case 'medium':   return Icons.info_rounded;
      case 'low':      return Icons.check_circle_rounded;
      default:         return Icons.help_rounded;
    }
  }

  Map<String, int> get _severityCounts {
    final counts = <String, int>{'All': _faultCodes.length};
    for (final s in ['Critical', 'High', 'Medium', 'Low']) {
      counts[s] = _faultCodes.where((f) => f.severity == s).length;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vendors = context.watch<VfdProvider>().vendors;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.faultCodeLookup),
        elevation: 0,
      ),
      body: Column(
        children: [
          AppCard(
            icon: Icons.search,
            title: l10n.faultCodeLookup,
            subtitle: l10n.searchByCodeOrDescription,
            backgroundColor: context.infoBg,
            accentColor: AppTheme.primaryBlue,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: l10n.selectVendor,
                    prefixIcon: const Icon(Icons.business),
                  ),
                  dropdownColor: context.surfaceCard,
                  value: _selectedVendorId,
                  items: vendors.map((v) {
                    return DropdownMenuItem(
                      value: v.name,
                      child: Row(
                        children: [
                          VendorAvatar(vendor: v, size: 28),
                          const SizedBox(width: 10),
                          Text(v.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: context.onSurface)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedVendorId = val;
                        _selectedSeverity = 'All';
                        _searchController.clear();
                      });
                      _loadFaultCodes(val);
                    }
                  },
                ),
                if (_selectedVendorId != null) ...[
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: l10n.searchByCodeOrDescription,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Severity Filter Chips ─────────────────────────────────
          if (_selectedVendorId != null && !_isLoading && _faultCodes.isNotEmpty)
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _severities.map((s) {
                  final isSelected = _selectedSeverity == s;
                  final color = s == 'All' ? Colors.blueGrey : _severityColor(s);
                  final count = _severityCounts[s] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedSeverity = s);
                        _applyFilters();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? color : color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? color : color.withOpacity(0.4),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
                              : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (s != 'All') ...[
                              Icon(
                                _severityIcon(s),
                                size: 14,
                                color: isSelected ? context.onPrimaryBg : color,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              '$s ($count)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? context.onPrimaryBg : color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          // ── Results ───────────────────────────────────────────────
          Expanded(child: _buildBody(l10n, isDark)),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n, bool isDark) {
    if (_selectedVendorId == null) {
      return _buildEmptyState(
        icon: Icons.search,
        color: Colors.red.shade700,
        title: l10n.selectVendorPrompt,
        subtitle: 'Select a VFD vendor to view fault codes',
      );
    }

    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.red.shade700),
            const SizedBox(height: 16),
            Text('Loading fault codes...', style: context.bodyStyle?.copyWith(color: context.onSurfaceMuted)),
          ],
        ),
      );
    }

    if (_filteredFaultCodes.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        color: context.onSurfaceMuted,
        title: _searchController.text.isNotEmpty ? l10n.noSearchResults : l10n.noFaultCodes,
        subtitle: _searchController.text.isNotEmpty
            ? 'Try different keywords or clear the search'
            : 'No fault codes available for this vendor',
      );
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: Column(
        children: [
          // Results count bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: context.surfaceMuted,
            child: Row(
              children: [
                Icon(Icons.list_alt, size: 16, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text(
                  '${_filteredFaultCodes.length} fault${_filteredFaultCodes.length != 1 ? 's' : ''} found',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredFaultCodes.length,
              itemBuilder: (context, index) =>
                  _buildFaultCard(_filteredFaultCodes[index], isDark, l10n),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaultCard(VfdFault fault, bool isDark, AppLocalizations l10n) {
    final color = _severityColor(fault.severity);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.4), width: 1.5),
            ),
            child: Icon(_severityIcon(fault.severity), color: color, size: 24),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Text(
                  fault.errorCode,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  fault.severity,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              fault.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: context.onSurfaceMuted,
                height: 1.4,
              ),
            ),
          ),
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.successBg,
                    context.successColor.withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.tintedBorder(context.successColor), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [context.successColor, context.successColor.withOpacity(0.85)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.build_circle, color: context.onPrimaryBg, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${l10n.solution}:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.successColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    fault.solution,
                    style: TextStyle(
                      color: context.onSurface,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: color),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.onSurfaceMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: context.captionStyle?.copyWith(color: context.onSurfaceSubtle),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
