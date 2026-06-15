import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'main_shell_screen.dart';
import 'welcome_screen.dart';

/// Resolves saved session on cold start before routing to welcome or home.
class AppGateScreen extends StatefulWidget {
  const AppGateScreen({super.key});

  @override
  State<AppGateScreen> createState() => _AppGateScreenState();
}

class _AppGateScreenState extends State<AppGateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveRoute());
  }

  Future<void> _resolveRoute() async {
    final auth = context.read<AuthProvider>();
    await auth.checkAuthStatus();

    if (!mounted) return;

    final next = auth.isAuthenticated
        ? const MainShellScreen()
        : const WelcomeScreen();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => next),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.precision_manufacturing,
                size: 56, color: AppTheme.primary),
            SizedBox(height: 24),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading VFD Hub...'),
          ],
        ),
      ),
    );
  }
}
