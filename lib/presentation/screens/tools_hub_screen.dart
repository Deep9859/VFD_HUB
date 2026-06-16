import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enterprise/app_permission.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_context.dart';
import '../providers/enterprise_provider.dart';
import '../providers/vfd_provider.dart';
import '../widgets/app_card.dart';
import '../widgets/feature_tile.dart';
import 'audit_log_screen.dart';
import 'calculation_tools_screen.dart';
import 'commissioning_screen.dart';
import 'fault_lookup_screen.dart';
import 'manual_import_screen.dart';
import 'qr_generator_screen.dart';
import 'qr_scanner_screen.dart';
import 'settings_screen.dart';
import 'smart_search_screen.dart';
import 'unit_converter_screen.dart';
import 'vfd_comparison_screen.dart';

/// Central hub for all VFD Hub tools — matches Level 1–4 feature set.
class ToolsHubScreen extends StatelessWidget {
  const ToolsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final enterprise = context.watch<EnterpriseProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Tools Hub'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 56),
                child: Text(
                  'Search, compare, commission & calculate',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FeatureSection(
                  title: 'Find & identify',
                  subtitle: 'Catalog search and QR workflows',
                  children: [
                    FeatureTile(
                      icon: Icons.search_rounded,
                      label: 'Smart Search',
                      subtitle: 'Fuzzy + filters',
                      color: AppTheme.primary,
                      onTap: () => _push(context, const SmartSearchScreen()),
                    ),
                    FeatureTile(
                      icon: Icons.qr_code_scanner_rounded,
                      label: 'Scan QR',
                      subtitle: 'Load VFD config',
                      color: Colors.teal,
                      onTap: () => _push(context, const QRScannerScreen()),
                    ),
                    FeatureTile(
                      icon: Icons.qr_code_2_rounded,
                      label: 'Generate QR',
                      subtitle: 'Nameplate codes',
                      color: Colors.indigo,
                      onTap: () => _push(context, const QRGeneratorScreen()),
                    ),
                    FeatureTile(
                      icon: Icons.compare_arrows_rounded,
                      label: 'Compare VFDs',
                      subtitle: 'Params & protocols',
                      color: Colors.deepPurple,
                      onTap: () => _push(context, const VFDComparisonScreen()),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FeatureSection(
                  title: 'Field engineering',
                  subtitle: 'Calculators, faults, manuals',
                  children: [
                    FeatureTile(
                      icon: Icons.calculate_rounded,
                      label: 'Calculators',
                      subtitle: '9 motor tools',
                      color: AppTheme.accent,
                      onTap: () =>
                          _push(context, const CalculationToolsScreen()),
                    ),
                    FeatureTile(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Unit converter',
                      subtitle: 'kW, °C, bar…',
                      color: Colors.blueGrey,
                      onTap: () => _push(context, const UnitConverterScreen()),
                    ),
                    FeatureTile(
                      icon: Icons.warning_amber_rounded,
                      label: 'Fault codes',
                      subtitle: 'Vendor lookup',
                      color: AppTheme.warning,
                      onTap: () => _push(context, const FaultLookupScreen()),
                    ),
                    FeatureTile(
                      icon: Icons.picture_as_pdf_rounded,
                      label: 'Manuals',
                      subtitle: 'Import PDFs',
                      color: Colors.red.shade400,
                      onTap: () => _push(context, const ManualImportScreen()),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FeatureSection(
                  title: 'Industrial platform',
                  subtitle: 'Live drive & platform ops',
                  children: [
                    FeatureTile(
                      icon: Icons.lan_rounded,
                      label: 'Modbus TCP',
                      subtitle: 'Read-only FC03',
                      color: Colors.teal.shade700,
                      enabled: enterprise.can(AppPermission.runCommissioning),
                      onTap: () {
                        if (!enterprise.guard(
                            context, AppPermission.runCommissioning)) {
                          return;
                        }
                        _push(context, const CommissioningScreen());
                      },
                    ),
                    FeatureTile(
                      icon: Icons.settings_rounded,
                      label: 'Platform',
                      subtitle: 'Catalog & cloud',
                      color: AppTheme.primary,
                      enabled: enterprise.can(AppPermission.platformSettings),
                      onTap: () {
                        if (!enterprise.guard(
                            context, AppPermission.platformSettings)) {
                          return;
                        }
                        _push(context, const SettingsScreen());
                      },
                    ),
                    FeatureTile(
                      icon: Icons.history_rounded,
                      label: 'Audit log',
                      subtitle: 'Compliance trail',
                      color: Colors.brown,
                      onTap: () => _push(context, const AuditLogScreen()),
                    ),
                    FeatureTile(
                      icon: Icons.upload_file_rounded,
                      label: 'Export config',
                      subtitle: 'Share JSON',
                      color: Colors.green.shade700,
                      enabled:
                          enterprise.can(AppPermission.exportConfiguration),
                      onTap: () => _exportConfig(context, enterprise),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppCard(
                  icon: Icons.tips_and_updates_outlined,
                  title: 'Pro tip',
                  subtitle: 'Configure on the Configure tab, then use Modbus to verify on the drive.',
                  accentColor: AppTheme.accent,
                  child: const SizedBox.shrink(),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _exportConfig(
    BuildContext context,
    EnterpriseProvider enterprise,
  ) async {
    if (!enterprise.guard(context, AppPermission.exportConfiguration)) return;
    final provider = context.read<VfdProvider>();
    if (provider.selectedVendor == null || provider.selectedModelName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Select vendor and model on Configure tab first'),
          backgroundColor: context.warningColor,
        ),
      );
      return;
    }
    final ok = await provider.shareConfigurationExport();
    if (context.mounted && ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Configuration ready to share'),
          backgroundColor: context.successColor,
        ),
      );
    }
  }
}
