import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../widgets/app_card.dart';
import 'privacy_policy_screen.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutTitle),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Icon with Gradient
            const SizedBox(height: 20),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(
                Icons.electrical_services,
                size: 60,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // App Title
            Text(
              _packageInfo.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontSize: 28,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Version Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade100,
                    Colors.green.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade300, width: 1.5),
              ),
              child: Text(
                l10n.versionLabel(_packageInfo.version, _packageInfo.buildNumber),
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 32),

            AppCard(
              icon: Icons.description,
              title: l10n.appSubtitle,
              subtitle: l10n.appDescription,
              accentColor: Theme.of(context).primaryColor,
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade600, Colors.blue.shade700],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade600.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.description,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            AppCard(
              icon: Icons.star,
              title: l10n.keyFeatures,
              subtitle: 'What makes VFD Hub valuable',
              accentColor: Colors.orange.shade700,
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _buildFeatureItem(l10n.featureMultiVendor, Icons.business),
                  _buildFeatureItem(l10n.featureParamConfig, Icons.tune),
                  _buildFeatureItem(l10n.featureFaultLookup, Icons.search),
                  _buildFeatureItem(l10n.featurePdfViewer, Icons.picture_as_pdf),
                  _buildFeatureItem(l10n.featureProtocolSetup, Icons.cable),
                  _buildFeatureItem(l10n.featureTheme, Icons.dark_mode),
                  _buildFeatureItem(l10n.featureMultiLanguage, Icons.language),
                ],
              ),
            ),

            const SizedBox(height: 24),

            AppCard(
              icon: Icons.help_outline,
              title: l10n.howToUseTitle,
              subtitle: l10n.appGuideNote,
              accentColor: Colors.blue.shade700,
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildGuideItem(l10n.howToUseStep1),
                  _buildGuideItem(l10n.howToUseStep2),
                  _buildGuideItem(l10n.howToUseStep3),
                  _buildGuideItem(l10n.howToUseStep4),
                  _buildGuideItem(l10n.howToUseStep5),
                ],
              ),
            ),

            const SizedBox(height: 24),

            AppCard(
              icon: Icons.person,
              title: l10n.developer,
              subtitle: l10n.developerName,
              accentColor: Colors.green.shade700,
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.favorite, color: Colors.red, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        l10n.builtWithLove,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            AppCard(
              icon: Icons.storage,
              title: l10n.database,
              subtitle: l10n.databaseInfo,
              accentColor: Colors.purple.shade700,
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    l10n.databaseStats,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Footer
            Text(
              l10n.copyright,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),

            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrivacyPolicyScreen(),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade600, Colors.orange.shade700],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
            ),
          ),
          Icon(
            Icons.check_circle,
            size: 20,
            color: Colors.green.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.arrow_right, size: 18, color: Colors.blueAccent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
