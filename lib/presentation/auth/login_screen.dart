import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/security/input_validation_service.dart';
import '../../core/theme/app_form_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_context.dart';
import '../providers/auth_provider.dart';
import 'signup_screen.dart';
import '../screens/main_shell_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 56),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildCard(context),
                const SizedBox(height: 24),
                _buildSignUpRow(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.electrical_services, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 20),
        Text('Welcome back', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(
          'Sign in to VFD Parameter Hub',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.onSurfaceMuted,
              ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context) {
    final cs = context.cs;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: AppFormStyles.decoration(
              context,
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined, size: 20),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email required';
              if (!InputValidationService.isValidEmail(v)) return 'Invalid email';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _signIn(),
            decoration: AppFormStyles.decoration(
              context,
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outlined, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password required';
              if (v.length < 12) return 'Min 12 characters';
              return null;
            },
          ),
          const SizedBox(height: 8),
          Consumer<AuthProvider>(
            builder: (_, auth, __) => auth.errorMessage != null
                ? Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.error, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(auth.errorMessage!,
                              style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),
          Consumer<AuthProvider>(
            builder: (_, auth, __) => ElevatedButton(
              onPressed: auth.isLoading ? null : _signIn,
              child: auth.isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.cs.onPrimary,
                      ),
                    )
                  : const Text('Sign In'),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or',
                  style: context.captionStyle?.copyWith(
                    color: context.onSurfaceSubtle,
                    fontSize: 13,
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              await auth.signInAsGuest();
              if (auth.isAuthenticated && mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainShellScreen()),
                  (_) => false,
                );
              }
            },
            icon: const Icon(Icons.person_outline, size: 18),
            label: const Text('Continue as Guest'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: context.bodyStyle?.copyWith(color: context.onSurfaceMuted),
        ),
        TextButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SignUpScreen())),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      final auth = context.read<AuthProvider>();
      final ok = await auth.signIn(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (ok && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShellScreen()),
          (_) => false,
        );
      }
    }
  }
}
