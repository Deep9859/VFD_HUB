import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/security/input_validation_service.dart';
import '../../core/theme/app_form_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_context.dart';
import '../providers/auth_provider.dart';
import '../screens/main_shell_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: context.cs.surface,
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                _buildHeader(),
                const SizedBox(height: 28),
                _buildCard(isDark),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ',
                        style: context.bodyStyle?.copyWith(color: context.onSurfaceMuted)),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Sign In',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
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
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
          ),
          child: const Icon(Icons.person_add_outlined, color: AppTheme.primary, size: 26),
        ),
        const SizedBox(height: 16),
        Text('Join VFD Hub', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('Create your account to get started',
            style: context.bodyStyle?.copyWith(color: context.onSurfaceMuted)),
      ],
    );
  }

  Widget _buildCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameCtrl,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            decoration: AppFormStyles.decoration(
              context,
              labelText: 'Full Name',
              prefixIcon: const Icon(Icons.person_outline, size: 20),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Name required';
              if (v.length < 2) return 'Min 2 characters';
              return null;
            },
          ),
          const SizedBox(height: 14),
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
          const SizedBox(height: 14),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscurePass,
            textInputAction: TextInputAction.next,
            decoration: AppFormStyles.decoration(
              context,
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outlined, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                onPressed: () => setState(() => _obscurePass = !_obscurePass),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password required';
              if (v.length < 12) return 'Min 12 characters';
              if (!v.contains(RegExp(r'[A-Z]'))) return 'Need uppercase letter';
              if (!v.contains(RegExp(r'[0-9]'))) return 'Need a number';
              if (!v.contains(RegExp(r'[!@#\$%^&*]'))) return 'Need special character';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _confirmCtrl,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _signUp(),
            decoration: AppFormStyles.decoration(
              context,
              labelText: 'Confirm Password',
              prefixIcon: const Icon(Icons.lock_outlined, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please confirm password';
              if (v != _passCtrl.text) return 'Passwords do not match';
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
                        Expanded(child: Text(auth.errorMessage!,
                            style: const TextStyle(color: AppTheme.error, fontSize: 13))),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),
          Consumer<AuthProvider>(
            builder: (_, auth, __) => ElevatedButton(
              onPressed: auth.isLoading ? null : _signUp,
              child: auth.isLoading
                  ? SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: context.onPrimaryBg))
                  : const Text('Create Account'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      final auth = context.read<AuthProvider>();
      final ok = await auth.signUp(
        name: _nameCtrl.text.trim(),
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
