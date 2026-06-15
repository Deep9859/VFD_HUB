import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_card.dart';
import 'main_shell_screen.dart';
import 'privacy_policy_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppTheme.primaryDark,
                    AppTheme.primary,
                  ]
                : [
                    AppTheme.primaryLight,
                    AppTheme.primary,
                  ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 64),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Logo/Icon with Glassmorphism
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(isDark ? 0.1 : 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(isDark ? 0.05 : 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryBlue.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.precision_manufacturing,
                              size: 48,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // App Name with Better Typography
                        Text(
                          'VFD Hub',
                          style: GoogleFonts.inter(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Tagline with Better Styling
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(isDark ? 0.1 : 0.15),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Industrial VFD Platform — Configure, Commission & Collaborate',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 40),

                        AppCard(
                          backgroundColor:
                              Colors.white.withOpacity(isDark ? 0.08 : 0.12),
                          accentColor: Colors.white,
                          title: l10n.welcomeFlowTitle,
                          subtitle: l10n.welcomeFlowSubtitle,
                          titleColor: Colors.white,
                          subtitleColor: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(24),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              _buildFlowStep(
                                1,
                                l10n.configStep1Short,
                                Icons.factory_rounded,
                              ),
                              const SizedBox(height: 14),
                              _buildFlowStep(
                                2,
                                l10n.configStep2Short,
                                Icons.electric_bolt_rounded,
                              ),
                              const SizedBox(height: 14),
                              _buildFlowStep(
                                3,
                                l10n.configStep3Short,
                                Icons.cable_rounded,
                              ),
                              const SizedBox(height: 14),
                              _buildFlowStep(
                                4,
                                l10n.configStep4Short,
                                Icons.tune_rounded,
                              ),
                              const SizedBox(height: 14),
                              _buildFlowStep(
                                5,
                                l10n.configStep5Short,
                                Icons.library_books_rounded,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Features Card with Glassmorphism
                        AppCard(
                          backgroundColor: Colors.white.withOpacity(isDark ? 0.08 : 0.12),
                          accentColor: Colors.white,
                          title: 'Industrial Platform',
                          subtitle: 'Levels 1–4 — field tool to enterprise',
                          titleColor: Colors.white,
                          subtitleColor: Colors.white.withOpacity(0.8),
                          glassmorphism: true,
                          borderRadius: BorderRadius.circular(32),
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              _buildFeature(
                                Icons.factory_rounded,
                                '21 VFD Vendors',
                                'ABB, Siemens, Danfoss, Schneider, Yaskawa & more',
                                AppTheme.primary,
                              ),
                              const SizedBox(height: 20),
                              _buildFeature(
                                Icons.search_rounded,
                                'Smart Search & QR',
                                'Fuzzy catalog search, scan & generate QR configs',
                                AppTheme.accent,
                              ),
                              const SizedBox(height: 20),
                              _buildFeature(
                                Icons.lan_rounded,
                                'Modbus TCP',
                                'Read-only commissioning on live drives',
                                Colors.teal,
                              ),
                              const SizedBox(height: 20),
                              _buildFeature(
                                Icons.folder_shared_rounded,
                                'Projects & Backup',
                                'Save named configs, export & restore JSON',
                                Colors.indigo,
                              ),
                              const SizedBox(height: 20),
                              _buildFeature(
                                Icons.business_rounded,
                                'Enterprise RBAC',
                                'Teams, audit log, custom vendors & admin panel',
                                Colors.deepPurple,
                              ),
                              const SizedBox(height: 20),
                              _buildFeature(
                                Icons.document_scanner_outlined,
                                'Nameplate OCR',
                                'Scan motor plate to pre-fill power ratings',
                                AppTheme.warning,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 56),

                        // Continue as Guest
                        Container(
                          width: double.infinity,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryBlue.withOpacity(0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => _continueAsGuest(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Continue as Guest',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () => _openLogin(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white70),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Sign In',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpScreen(),
                            ),
                          ),
                          child: Text(
                            'Create Account',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PrivacyPolicyScreen(),
                            ),
                          ),
                          child: Text(
                            'Privacy Policy',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Version Info
                        Text(
                          'Version 2.0.0',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  static Future<void> _continueAsGuest(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      await auth.signInAsGuest();
    }
    if (!context.mounted || !auth.isAuthenticated) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShellScreen()),
    );
  }

  static void _openLogin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Widget _buildFlowStep(int number, String label, IconData icon) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.white.withOpacity(0.2),
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeature(IconData icon, String title, String subtitle, Color color) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
}
