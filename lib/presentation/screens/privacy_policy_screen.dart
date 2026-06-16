import 'package:flutter/material.dart';

import '../../core/theme/theme_context.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String policyVersion = '1.0';
  static const String effectiveDate = 'May 2026';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'VFD Hub Privacy Policy',
            style: context.titleStyle?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Version $policyVersion • Effective $effectiveDate',
            style: context.bodyStyle?.copyWith(color: context.onSurfaceMuted),
          ),
          SizedBox(height: 24),
          _Section(
            title: 'Overview',
            body:
                'VFD Hub helps industrial users configure and reference Variable Frequency Drive (VFD) parameters. '
                'This app is designed to work primarily offline on your device.',
          ),
          _Section(
            title: 'Data we collect',
            body:
                'VFD Hub does not operate a cloud account server in this version. '
                'Account email, display name, and password hash are stored locally on your device using secure storage. '
                'VFD selections, parameter values, uploaded drawings, and imported manuals are stored locally in app storage.',
          ),
          _Section(
            title: 'Permissions',
            body:
                '• Camera — used only when you scan a VFD QR code.\n'
                '• Microphone — used only when you use voice commands.\n'
                '• Storage / files — used when you import manuals or upload drawings.\n'
                '• Internet — used when you open online manual links or external URLs.',
          ),
          _Section(
            title: 'Data sharing',
            body:
                'We do not sell your personal data. Data stays on your device unless you explicitly share files '
                'or links using Android system share features outside the app.',
          ),
          _Section(
            title: 'Security',
            body:
                'Passwords are hashed with PBKDF2 before storage. Session tokens and credentials use Android secure storage. '
                'You are responsible for securing your device with a screen lock.',
          ),
          _Section(
            title: 'Children',
            body:
                'VFD Hub is a professional industrial tool and is not directed at children under 13.',
          ),
          _Section(
            title: 'Your choices',
            body:
                'You can sign out to clear the active session, uninstall the app to remove local data, '
                'or clear app storage from Android Settings.',
          ),
          _Section(
            title: 'Contact',
            body:
                'For privacy questions about this app listing, use the developer contact email shown on the Google Play store page.',
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: context.titleStyle?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 8),
          Text(body, style: context.bodyStyle?.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}
