import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/configuration_flow.dart';
import '../../core/config/supported_vendors.dart';
import '../../core/theme/app_theme.dart';
import 'vfd_comparison_screen.dart';
import '../../data/models/vendor_model.dart';
import '../../data/models/protocol_model.dart';
import '../providers/vfd_provider.dart';
import '../providers/enterprise_provider.dart';
import '../../core/enterprise/app_permission.dart';
import '../widgets/parameter_editor.dart';
import '../widgets/drawing_section.dart';
import '../widgets/manual_section.dart';
import '../widgets/vendor_avatar.dart';
import 'fault_lookup_screen.dart';
import 'manual_import_screen.dart';
import 'qr_scanner_screen.dart';
import 'smart_search_screen.dart';
import '../../data/models/vfd_search_hit.dart';
import '../../core/services/permissions_service.dart';
import 'calculation_tools_screen.dart';
import '../widgets/app_card.dart';
import '../widgets/configuration_progress.dart';
import '../widgets/setup_guide_sheet.dart';
import '../../core/services/nameplate_ocr_service.dart';
import '../../core/services/voice_command_service.dart';

class HomeScreen extends StatefulWidget {
  final bool embedInShell;

  const HomeScreen({super.key, this.embedInShell = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _lastDrawingPromptKey;
  bool _allowDrawingUpload = false;
  final VoiceCommandService _voiceService = VoiceCommandService();
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _stepKeys = {
    for (var i = 1; i <= 6; i++) i: GlobalKey(),
  };

  static const _guidePrefsKey = 'home_setup_guide_seen_v1';

  @override
  void initState() {
    super.initState();
    _voiceService.initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowSetupGuide());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _maybeShowSetupGuide() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_guidePrefsKey) == true) return;
    if (!mounted) return;
    await SetupGuideSheet.show(context);
    await prefs.setBool(_guidePrefsKey, true);
  }

  void _scrollToStep(int step) {
    final key = _stepKeys[step];
    if (key?.currentContext == null) return;
    Scrollable.ensureVisible(
      key!.currentContext!,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.08,
    );
  }

  void _onConnectionStepProgress(VfdProvider provider) {
    if (ConfigurationFlow.isStepComplete(provider, 5)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToStep(6);
      });
    }
  }

  String _stepGuideMessage(AppLocalizations l10n, int step) {
    switch (step) {
      case 1:
        return l10n.howToUseStep1;
      case 2:
        return l10n.selectModel;
      case 3:
        return l10n.selectPowerRating;
      case 4:
        return l10n.voltageStepSubtitle;
      case 5:
        return l10n.howToUseStep2;
      case 6:
        return l10n.howToUseStep4;
      default:
        return l10n.activeStepHint;
    }
  }

  // Determines if a voltage string is 3-phase
  bool _is3Phase(String voltage) {
    final v = voltage.toLowerCase();
    return v.contains('380') ||
        v.contains('400') ||
        v.contains('415') ||
        v.contains('440') ||
        v.contains('460') ||
        v.contains('480') ||
        v.contains('500') ||
        v.contains('3ph') ||
        v.contains('3-ph') ||
        v.contains('three');
  }

  String _phaseLabel(BuildContext context, String voltage) {
    final l10n = AppLocalizations.of(context)!;
    return _is3Phase(voltage) ? l10n.phase3 : l10n.phase1;
  }

  Color _phaseColor(String voltage) {
    return _is3Phase(voltage) ? Colors.deepOrange : Colors.indigo;
  }

  String? _drawingPromptKey(VfdProvider provider) {
    final model = provider.selectedModel;
    if (model == null) return null;
    return [
      model.id,
      provider.connectionType.name,
      provider.selectedProtocol?.id ?? 0,
      provider.selectedCommCard ?? '',
    ].join('|');
  }

  void _handleDrawingPromptIfNeeded(VfdProvider provider) {
    final key = _drawingPromptKey(provider);
    if (key == null) return;

    if (provider.parameters.isEmpty || key == _lastDrawingPromptKey) return;

    _lastDrawingPromptKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final allowUpload = await _askForDrawingUpload(context);
      if (!mounted) return;
      setState(() {
        _allowDrawingUpload = allowUpload;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final body = Consumer<VfdProvider>(
      builder: (context, provider, _) {
        _handleDrawingPromptIfNeeded(provider);
        return _buildBody(context, l10n, provider);
      },
    );

    if (widget.embedInShell) {
      return Scaffold(
        body: body,
        floatingActionButton: _buildVoiceFab(context),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: l10n.viewSetupGuide,
            onPressed: () => SetupGuideSheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Smart Search',
            onPressed: () => _openSmartSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan QR',
            onPressed: () => _openQRScanner(context),
          ),
        ],
      ),
      floatingActionButton: _buildVoiceFab(context),
      body: body,
    );
  }

  Widget _buildVoiceFab(BuildContext context) {
    return VoiceCommandButton(
        onCommand: (command) {
          if (command == null) return;
          final provider = context.read<VfdProvider>();
          switch (command.type) {
            case CommandType.showFaults:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FaultLookupScreen()));
              break;
            case CommandType.showCalculator:
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CalculationToolsScreen()));
              break;
            case CommandType.scanQR:
              _openQRScanner(context);
              break;
            case CommandType.selectVendor:
              if (command.data != null) {
                final v = provider.vendors.where((v) => v.name.toLowerCase().contains(command.data!)).toList();
                if (v.isNotEmpty) provider.selectVendor(v.first);
              }
              break;
            case CommandType.openSearch:
              _openSmartSearch(context);
              break;
            case CommandType.showManuals:
              if (provider.manuals.isNotEmpty) {
                provider.openManualFile(context, provider.manuals.first);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManualImportScreen()),
                );
              }
              break;
            case CommandType.compare:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VFDComparisonScreen()),
              );
              break;
            default:
              break;
          }
        },
      );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    VfdProvider provider,
  ) {
    final enterprise = context.watch<EnterpriseProvider>();
    final completed = ConfigurationFlow.completedSteps(provider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
          ],
        ),
      ),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: enterprise.isEnterpriseMode ? 148 : 128,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            actions: widget.embedInShell
                ? [
                    IconButton(
                      icon: const Icon(Icons.help_outline, color: Colors.white),
                      onPressed: () => SetupGuideSheet.show(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () => _openSmartSearch(context),
                    ),
                  ]
                : null,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: FlexibleSpaceBar(
                centerTitle: false,
                expandedTitleScale: 1.0,
                titlePadding:
                    const EdgeInsetsDirectional.only(start: 16, bottom: 14),
                title: Text(
                  l10n.configHubTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                background: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 52),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.configHubSubtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        if (enterprise.isEnterpriseMode) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${enterprise.profile!.orgName} • ${EnterprisePermissions.label(enterprise.profile!.role)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ConfigurationProgressHeader(
                  completedSteps: completed,
                  totalSteps: ConfigurationFlow.totalSteps,
                  activeStep: ConfigurationFlow.activeStep(provider),
                ),
                const SizedBox(height: 16),
                _buildQuickActionsRow(context),
                const SizedBox(height: 24),
                _buildConfigurationSteps(context, provider),
                const SizedBox(height: 24),
                _buildAdditionalSections(context, provider),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionTypeSection(BuildContext context, VfdProvider provider) {
    return Column(
      children: [
        _buildConnectionTypeCard(context, provider),
        if (provider.connectionType == ConnectionType.communication) ...[
          const SizedBox(height: 16),
          _buildProtocolSection(context, provider),
        ],
        if (provider.connectionType == ConnectionType.communication &&
            provider.selectedProtocol != null &&
            provider.selectedProtocol!.type != 'Direct') ...[
          const SizedBox(height: 16),
          _buildCommCardSection(context, provider),
        ],
      ],
    );
  }

  Future<bool> _askForDrawingUpload(BuildContext context) async {
    final shouldUpload = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Need Exact Parameters?'),
        content: const Text(
          'For exact parameters, please upload panel drawing PDF. Do you want to upload now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    return shouldUpload ?? false;
  }

  // ── Power Range Card ─────────────────────────────────────────────

  Widget _buildPowerRangeCard(BuildContext context, VfdProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final ratings = provider.powerRatings;
    if (ratings.isEmpty) return const SizedBox();

    final vendor = provider.selectedVendor?.name;
    final model = provider.selectedModelName;
    final range = vendor != null && model != null
        ? SupportedVendors.modelPowerRange(vendor, model, ratings)
        : null;
    final minKw = range?.minKw ?? ratings.first;
    final maxKw = range?.maxKw ?? ratings.last;
    final minHp = (minKw * 1.341).toStringAsFixed(2);
    final maxHp = (maxKw * 1.341).toStringAsFixed(2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepOrange.shade50,
            Colors.orange.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.deepOrange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.electric_bolt,
                  color: Colors.deepOrange.shade700, size: 18),
              const SizedBox(width: 6),
              Text(
                l10n.powerRange3Phase,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange.shade800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _powerBadge(
                  l10n.min, '$minKw kW', '$minHp HP', Colors.green.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.green.shade400,
                      Colors.deepOrange.shade400,
                    ]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _powerBadge(l10n.max, '$maxKw kW', '$maxHp HP',
                  Colors.deepOrange.shade700),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.powerOptionsAvailable(ratings.length),
            style: TextStyle(fontSize: 11, color: Colors.deepOrange.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            '${ratings.length} ratings from ${minKw.toStringAsFixed(minKw.truncateToDouble() == minKw ? 0 : 1)} kW to ${maxKw.toStringAsFixed(maxKw.truncateToDouble() == maxKw ? 0 : 1)} kW',
            style: TextStyle(fontSize: 11, color: Colors.deepOrange.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerRatingPicker(BuildContext context, VfdProvider provider) {
    final selected = provider.selectedPowerRating;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: provider.powerRatings.map((rating) {
        final isSelected = selected == rating;
        return ChoiceChip(
          label: Text('${rating.toStringAsFixed(1)} kW'),
          selected: isSelected,
          onSelected: (_) {
            provider.selectPowerRating(rating);
            _scrollToStep(4);
          },
          selectedColor: AppTheme.primary.withOpacity(0.2),
          labelStyle: GoogleFonts.inter(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
            color: isSelected ? AppTheme.primary : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _powerBadge(String label, String kw, String hp, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        Text(kw,
            style: TextStyle(
                fontSize: 15, color: color, fontWeight: FontWeight.bold)),
        Text(hp, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }

  // ── Connection Type Radio Card ────────────────────────────────────

  Widget _buildConnectionTypeCard(BuildContext context, VfdProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final isComm = provider.connectionType == ConnectionType.communication;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueGrey.shade700,
                  Colors.blueGrey.shade600,
                ],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.settings_input_component,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.controlWiringType,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _connectionOption(
                    icon: Icons.cable,
                    label: l10n.communication,
                    sublabel: l10n.communicationSub,
                    selected: isComm,
                    color: Colors.purple,
                    onTap: () {
                      provider.setConnectionType(ConnectionType.communication);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _connectionOption(
                    icon: Icons.settings_input_svideo,
                    label: l10n.hardWire,
                    sublabel: l10n.hardWireSub,
                    selected: !isComm,
                    color: Colors.teal,
                    onTap: () {
                      provider.setConnectionType(ConnectionType.hardWire);
                      _onConnectionStepProgress(provider);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _connectionOption({
    required IconData icon,
    required String label,
    required String sublabel,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  colors: [
                    color.withOpacity(0.15),
                    color.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2.5 : 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    selected ? color.withOpacity(0.15) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected ? color : Colors.grey.shade600,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? color : Colors.grey.shade700,
                fontSize: 14,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              sublabel,
              style: TextStyle(
                fontSize: 11,
                color: selected ? color.withOpacity(0.8) : Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            if (selected) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Selected',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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

  // ── Protocol Section ──────────────────────────────────────────────

  Widget _buildProtocolSection(BuildContext context, VfdProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
              : [Colors.white, Colors.purple.shade50.withOpacity(0.3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.purple.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade700, Colors.purple.shade800],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.cable, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Select Protocol / Connection Type',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: provider.protocols.isNotEmpty
                ? _buildDropdown<Protocol>(
                    context: context,
                    hint: l10n.selectCommProtocol,
                    value: provider.selectedProtocol,
                    items: provider.protocols,
                    onChanged: (p) {
                      if (p != null) {
                        provider.selectProtocol(p);
                        _onConnectionStepProgress(provider);
                      }
                    },
                    itemBuilder: (p) => DropdownMenuItem(
                      value: p,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _protocolColor(p.type).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              _protocolIcon(p.type),
                              size: 16,
                              color: _protocolColor(p.type),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(p.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                Text(p.type,
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: _protocolColor(p.type))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      l10n.noProtocols,
                      style: TextStyle(color: Colors.purple.shade400),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Color _protocolColor(String type) {
    switch (type) {
      case 'Ethernet':
        return Colors.blue.shade700;
      case 'Serial':
        return Colors.purple.shade700;
      case 'Direct':
        return Colors.teal.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  IconData _protocolIcon(String type) {
    switch (type) {
      case 'Ethernet':
        return Icons.wifi;
      case 'Serial':
        return Icons.cable;
      case 'Direct':
        return Icons.settings_input_svideo;
      default:
        return Icons.device_hub;
    }
  }

  // ── Comm Card Section ─────────────────────────────────────────────

  Widget _buildCommCardSection(BuildContext context, VfdProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final protocol = provider.selectedProtocol!;
    final cards = provider.commCardOptions;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.indigo.shade100,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.developer_board,
                    color: Colors.indigo.shade700, size: 18),
                const SizedBox(width: 8),
                Text(
                  l10n.step2SelectCommCard,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdown<String>(
                  context: context,
                  hint: l10n.selectCommCard,
                  value: provider.selectedCommCard,
                  items: cards,
                  onChanged: (c) {
                    if (c != null) {
                      provider.selectCommCard(c);
                      _onConnectionStepProgress(provider);
                    }
                  },
                  itemBuilder: (c) => DropdownMenuItem(
                    value: c,
                    child: Row(
                      children: [
                        Icon(
                          c.startsWith('Built-in')
                              ? Icons.check_circle_outline
                              : Icons.memory,
                          size: 18,
                          color: Colors.indigo.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(c,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                ),
                if (provider.selectedCommCard != null &&
                    !provider.selectedCommCard!.startsWith('Built-in')) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.tips_and_updates,
                            size: 16, color: Colors.amber.shade800),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.installCardTip(
                                provider.selectedCommCard ?? ''),
                            style: TextStyle(
                                fontSize: 11, color: Colors.amber.shade900),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (provider.selectedCommCard != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 14, color: Colors.indigo.shade400),
                      const SizedBox(width: 6),
                      Text(
                        l10n.protocolTypeInfo(protocol.name, protocol.type),
                        style: TextStyle(
                            fontSize: 11, color: Colors.indigo.shade600),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Parameter Section (shared by both flows) ──────────────────────

  Widget _buildParameterSection(BuildContext context, VfdProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final enterprise = context.watch<EnterpriseProvider>();
    final canEdit = enterprise.can(AppPermission.editParameters);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (provider.parameters.isNotEmpty) ...[
          _sectionHeader(l10n.vfdParameters, Icons.tune, Colors.green.shade700),
          const SizedBox(height: 4),
          Text(
            l10n.vfdParamsCount(
                provider.parameters.length, provider.parametersByGroup.length),
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          ParameterEditor(
            parametersByGroup: provider.parametersByGroup,
            readOnly: !canEdit,
            onValueChanged: (id, val) => provider.saveParameterValue(id, val),
          ),
          const SizedBox(height: 16),
          _buildExactParamsBanner(context, provider),
          const SizedBox(height: 24),
        ] else ...[
          _emptyCard(
            icon: Icons.tune,
            message: l10n.noParametersFound,
            sub: l10n.noParametersSub,
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildExactParamsBanner(BuildContext context, VfdProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.exactParamsTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.exactParamsSub,
                  style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 12),
            ),
            onPressed: () async {
              await provider.uploadDrawing();
              if (provider.drawings.isNotEmpty && context.mounted) {
                _showDrawingWizard(context, provider);
              }
            },
            child: Text(l10n.uploadDrawingAction),
          ),
        ],
      ),
    );
  }

  // ── Drawing Wizard ────────────────────────────────────────────────

  void _showDrawingWizard(BuildContext context, VfdProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final controllers = {
      'kwCtrl': TextEditingController(),
      'voltCtrl': TextEditingController(),
      'ampCtrl': TextEditingController(),
      'rpmCtrl': TextEditingController(),
      'hzCtrl': TextEditingController(text: '50'),
    };
    String connection = 'Star';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.architecture, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Text(
                      l10n.motorSpecsTitle,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.motorSpecsSub,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                if (NameplateOcrService.isSupported)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.document_scanner),
                      label: const Text('Scan nameplate (camera)'),
                      onPressed: () async {
                        final specs = await NameplateOcrService.scanFromCamera();
                        if (!ctx.mounted || specs == null) {
                          if (ctx.mounted && specs == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not read nameplate — enter manually'),
                              ),
                            );
                          }
                          return;
                        }
                        setS(() {
                          if (specs.powerKw != null) {
                            controllers['kwCtrl']!.text = specs.powerKw.toString();
                          }
                          if (specs.voltage != null) {
                            controllers['voltCtrl']!.text = specs.voltage.toString();
                          }
                          if (specs.current != null) {
                            controllers['ampCtrl']!.text = specs.current.toString();
                          }
                          if (specs.speedRpm != null) {
                            controllers['rpmCtrl']!.text = specs.speedRpm!.toInt().toString();
                          }
                          controllers['hzCtrl']!.text = specs.frequencyHz.toString();
                          connection = specs.connection;
                        });
                      },
                    ),
                  ),
                if (NameplateOcrService.isSupported) const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: _wizardField(
                            controllers['kwCtrl']!, l10n.motorPower, '7.5')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _wizardField(controllers['voltCtrl']!,
                            l10n.ratedVoltage, '415')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _wizardField(controllers['ampCtrl']!,
                            l10n.ratedCurrent, '15.2')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _wizardField(
                            controllers['rpmCtrl']!, l10n.ratedSpeed, '1450')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _wizardField(
                            controllers['hzCtrl']!, l10n.baseFrequency, '50')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.connection,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: connection,
                                items: [
                                  DropdownMenuItem(
                                      value: 'Star', child: Text(l10n.star)),
                                  DropdownMenuItem(
                                      value: 'Delta', child: Text(l10n.delta)),
                                ],
                                onChanged: (v) {
                                  if (v != null) setS(() => connection = v);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.auto_fix_high),
                    label: Text(l10n.autoFillParameters),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      final kw =
                          double.tryParse(controllers['kwCtrl']!.text) ?? 0;
                      final v =
                          double.tryParse(controllers['voltCtrl']!.text) ?? 0;
                      final a =
                          double.tryParse(controllers['ampCtrl']!.text) ?? 0;
                      final rpm =
                          double.tryParse(controllers['rpmCtrl']!.text) ?? 0;
                      final hz =
                          double.tryParse(controllers['hzCtrl']!.text) ?? 50;
                      for (var ctrl in controllers.values) {
                        ctrl.dispose();
                      }
                      Navigator.pop(ctx);
                      provider.autoFillMotorSpecs(
                        motorKw: kw,
                        motorVoltage: v,
                        motorCurrent: a,
                        motorSpeed: rpm,
                        motorFrequency: hz,
                        connection: connection,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.motorSpecsApplied),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      for (var ctrl in controllers.values) {
                        ctrl.dispose();
                      }
                      Navigator.pop(ctx);
                    },
                    child: Text(l10n.skip),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _wizardField(TextEditingController ctrl, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
          ),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(title,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildStepCard({
    required int step,
    required String title,
    required String subtitle,
    required Widget child,
    bool isCompleted = false,
    bool isActive = false,
    bool showGuide = false,
    String? guideMessage,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return KeyedSubtree(
      key: _stepKeys[step],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showGuide && guideMessage != null)
            StepGuideBanner(message: guideMessage),
          AppCard(
            title: title,
            subtitle: subtitle,
            icon: isCompleted
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked,
            accentColor: isCompleted ? AppTheme.success : AppTheme.primaryBlue,
            showGradient: isCompleted,
            stepNumber: step,
            stepTotal: ConfigurationFlow.totalSteps,
            isActiveStep: isActive,
            isCompletedStep: isCompleted,
            padding: const EdgeInsets.all(20),
            child: child,
          ),
          if (isActive && !isCompleted)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                l10n.activeStepHint,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.grey500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppCard(
      title: l10n.quickActionsTitle,
      subtitle: l10n.quickActionsSubtitle,
      icon: Icons.flash_on,
      accentColor: AppTheme.primaryBlue,
      showGradient: true,
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickActionButton(
            context,
            icon: Icons.calculate_rounded,
            label: 'Calculator',
            color: AppTheme.primary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CalculationToolsScreen()),
            ),
          ),
          _buildQuickActionButton(
            context,
            icon: Icons.qr_code_scanner_rounded,
            label: 'Scan QR',
            color: AppTheme.primary,
            onTap: () => _openQRScanner(context),
          ),
          _buildQuickActionButton(
            context,
            icon: Icons.compare_arrows_rounded,
            label: 'Compare',
            color: AppTheme.primary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VFDComparisonScreen()),
            ),
          ),
          _buildQuickActionButton(
            context,
            icon: Icons.library_books_rounded,
            label: 'Manuals',
            color: AppTheme.primary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ManualImportScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationSteps(BuildContext context, VfdProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final completed = ConfigurationFlow.completedSteps(provider);
    final active = ConfigurationFlow.activeStep(provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.settings_applications_rounded,
                      color: AppTheme.secondaryPurple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.configStepsTitle,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color:
                                Theme.of(context).textTheme.titleLarge?.color,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          l10n.configStepsSubtitle,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => SetupGuideSheet.show(context),
                  icon: const Icon(Icons.help_outline, size: 18),
                  label: Text(l10n.viewSetupGuide),
                ),
              ),
            ],
          ),
        ),
        ConfigurationProgressHeader(
          completedSteps: completed,
          totalSteps: ConfigurationFlow.totalSteps,
          activeStep: active,
        ),
        const SizedBox(height: 24),

        // Step 1: Vendor Selection
        _buildStepCard(
          step: 1,
          title: l10n.vendor,
          subtitle: l10n.selectVendor,
          isCompleted: provider.selectedVendor != null,
          isActive: active == 1,
          showGuide: active == 1,
          guideMessage: _stepGuideMessage(l10n, 1),
          child: _buildDropdown<Vendor>(
            context: context,
            hint: l10n.selectVendor,
            value: provider.selectedVendor,
            items: provider.vendors,
            onChanged: (v) {
              if (v != null) {
                provider.selectVendor(v);
                _scrollToStep(2);
              }
            },
            itemBuilder: (v) => DropdownMenuItem(
              value: v,
              child: Row(
                children: [
                  VendorAvatar(vendor: v, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    v.name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Step 2: Model Selection
        if (provider.selectedVendor != null) ...[
          const SizedBox(height: 20),
          _buildStepCard(
            step: 2,
            title: l10n.model,
            subtitle: l10n.selectModel,
            isCompleted: provider.selectedModelName != null,
            isActive: active == 2,
            showGuide: active == 2,
            guideMessage: _stepGuideMessage(l10n, 2),
            child: _buildDropdown<String>(
              context: context,
              hint: l10n.selectModel,
              value: provider.selectedModelName,
              items: provider.modelNames,
              onChanged: (name) {
                if (name != null) {
                  provider.selectModelName(name);
                  _scrollToStep(3);
                }
              },
              itemBuilder: (name) => DropdownMenuItem(
                value: name,
                child: Text(
                  name,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],

        // Step 3: Power Rating
        if (provider.selectedModelName != null && provider.powerRatings.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildStepCard(
            step: 3,
            title: l10n.powerRatingLabel,
            subtitle: l10n.selectPowerRating,
            isCompleted: provider.selectedPowerRating != null,
            isActive: active == 3,
            showGuide: active == 3,
            guideMessage: _stepGuideMessage(l10n, 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPowerRangeCard(context, provider),
                const SizedBox(height: 16),
                _buildPowerRatingPicker(context, provider),
                const SizedBox(height: 12),
                _buildDropdown<double>(
                  context: context,
                  hint: AppLocalizations.of(context)!.selectPowerRating,
                  value: provider.selectedPowerRating,
                  items: provider.powerRatings,
                  onChanged: (rating) {
                    if (rating != null) {
                      provider.selectPowerRating(rating);
                      _scrollToStep(4);
                    }
                  },
                  itemBuilder: (rating) => DropdownMenuItem(
                    value: rating,
                    child: Text(
                      '${rating.toStringAsFixed(1)} kW',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Step 4: Voltage Selection
        if (provider.selectedPowerRating != null && provider.voltages.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildStepCard(
            step: 4,
            title: l10n.voltageStepTitle,
            subtitle: l10n.voltageStepSubtitle,
            isCompleted: provider.selectedVoltage != null,
            isActive: active == 4,
            showGuide: active == 4,
            guideMessage: _stepGuideMessage(l10n, 4),
            child: _buildDropdown<String>(
              context: context,
              hint: l10n.voltageStepTitle,
              value: provider.selectedVoltage,
              items: provider.voltages,
              onChanged: (v) {
                if (v != null) {
                  provider.selectVoltage(v);
                  _scrollToStep(5);
                }
              },
              itemBuilder: (v) => DropdownMenuItem(
                value: v,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _phaseColor(v).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.bolt, size: 16, color: _phaseColor(v)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$v  •  ${_phaseLabel(context, v)}',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],

        // Step 5: Connection Type Selection (after voltage)
        if (provider.selectedVoltage != null) ...[
          const SizedBox(height: 20),
          _buildStepCard(
            step: 5,
            title: l10n.connectionStepTitle,
            subtitle: l10n.connectionStepSubtitle,
            isCompleted: ConfigurationFlow.isStepComplete(provider, 5),
            isActive: active == 5,
            showGuide: active == 5,
            guideMessage: l10n.howToUseStep3,
            child: _buildConnectionTypeSection(context, provider),
          ),
        ],
      ],
    );
  }

  Widget _buildAdditionalSections(BuildContext context, VfdProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final active = ConfigurationFlow.activeStep(provider);
    final paramsUnlocked = ConfigurationFlow.isStepComplete(provider, 5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step 6: Parameters Section
        if (paramsUnlocked) ...[
          const SizedBox(height: 32),
          _buildStepCard(
            step: 6,
            title: l10n.parametersStepTitle,
            subtitle: l10n.parametersStepSubtitle,
            isCompleted: provider.parameters.isNotEmpty,
            isActive: active == 6,
            showGuide: active == 6,
            guideMessage: l10n.howToUseStep4,
            child: _buildParameterSection(context, provider),
          ),
        ],

        // Drawings Section
        const SizedBox(height: 32),
        AppCard(
          title: AppLocalizations.of(context)!.drawings,
          subtitle: 'Technical diagrams and schematics',
          icon: Icons.architecture_rounded,
          accentColor: Colors.orange,
          padding: const EdgeInsets.all(24),
          child: DrawingSection(
            drawings: provider.drawings,
            canUpload: _allowDrawingUpload &&
                _drawingPromptKey(provider) == _lastDrawingPromptKey,
            onUpload: () async {
              final uploaded = await provider.uploadDrawing();
              if (uploaded && context.mounted) {
                _showDrawingWizard(context, provider);
              }
            },
            onDelete: (d) => provider.deleteDrawing(d),
            onOpen: (d) => provider.openDrawing(d),
          ),
        ),

        // Manuals Section
        const SizedBox(height: 32),
        AppCard(
          title: AppLocalizations.of(context)!.manuals,
          subtitle: 'Product documentation and guides',
          icon: Icons.library_books_rounded,
          accentColor: Colors.blue,
          padding: const EdgeInsets.all(24),
          child: provider.manuals.isNotEmpty
              ? ManualSection(
                  manuals: provider.manuals,
                  onManualTap: (manual) =>
                      provider.openManualFile(context, manual),
                )
              : _emptyCard(
                  icon: Icons.library_books,
                  message: AppLocalizations.of(context)!.noManuals,
                  sub: AppLocalizations.of(context)!.noManualsSub,
                ),
        ),

        // Fault Code Lookup
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 24),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FaultLookupScreen(),
              ),
            ),
            icon: const Icon(Icons.search_rounded),
            label: Text(AppLocalizations.of(context)!.faultCodeLookup),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: AppTheme.primaryBlue.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyCard(
      {required IconData icon, required String message, required String sub}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(sub,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required BuildContext context,
    required String hint,
    required T? value,
    required List<T> items,
    required Function(T?) onChanged,
    required DropdownMenuItem<T> Function(T) itemBuilder,
  }) {
    return DropdownButtonFormField<T>(
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      value: value,
      items: items.map(itemBuilder).toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _openSmartSearch(BuildContext context) async {
    final hit = await Navigator.push<VfdSearchHit>(
      context,
      MaterialPageRoute(builder: (_) => const SmartSearchScreen()),
    );
    if (!mounted || hit == null) return;
    await _applyVendorModelSelection(
      vendorName: hit.vendor,
      modelName: hit.model.name,
    );
  }

  Future<void> _applyVendorModelSelection({
    required String vendorName,
    required String modelName,
    double? powerKw,
  }) async {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<VfdProvider>();

    Vendor? vendorObj;
    for (final v in provider.vendors) {
      if (v.name.toLowerCase() == vendorName.toLowerCase()) {
        vendorObj = v;
        break;
      }
    }

    if (vendorObj == null) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Vendor "$vendorName" not found'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    await provider.selectVendor(vendorObj);

    if (!provider.modelNames.contains(modelName)) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Model "$modelName" not found for $vendorName'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    await provider.selectModelName(modelName);

    if (powerKw != null && provider.powerRatings.contains(powerKw)) {
      await provider.selectPowerRating(powerKw);
    }

    if (mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Loaded: $vendorName $modelName'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // QR Scanner
  Future<void> _openQRScanner(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (!await PermissionsService.ensureCamera()) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Camera permission is required to scan QR codes'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await navigator.push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );

    if (!mounted || result == null || result['success'] != true) return;
    await _applyVendorModelSelection(
      vendorName: result['vendor'] as String,
      modelName: result['model'] as String,
      powerKw: result['power'] as double?,
    );
  }
}
