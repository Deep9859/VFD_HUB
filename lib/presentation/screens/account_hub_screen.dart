import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enterprise/app_permission.dart';
import '../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/enterprise_provider.dart';
import '../providers/vfd_provider.dart';
import '../widgets/app_card.dart';
import 'about_screen.dart';
import 'admin_panel_screen.dart';
import 'enterprise_join_screen.dart';
import 'privacy_policy_screen.dart';
import 'saved_projects_screen.dart';
import 'settings_screen.dart';
import 'team_workspace_screen.dart';
import 'welcome_screen.dart';

class AccountHubScreen extends StatelessWidget {
  const AccountHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final enterprise = context.watch<EnterpriseProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Account'),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 64),
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.userEmail ?? 'Guest user',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (enterprise.isEnterpriseMode) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${enterprise.profile!.orgName} • ${EnterprisePermissions.label(enterprise.profile!.role)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _sectionTitle(context, 'Workspace'),
                _tile(
                  context,
                  icon: Icons.folder_shared_rounded,
                  title: 'Saved projects',
                  subtitle: 'Named configurations & backup',
                  enabled: enterprise.can(AppPermission.manageProjects),
                  onTap: () {
                    if (!enterprise.guard(
                        context, AppPermission.manageProjects)) {
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SavedProjectsScreen(),
                      ),
                    );
                  },
                ),
                _tile(
                  context,
                  icon: Icons.groups_rounded,
                  title: 'Team workspace',
                  subtitle: 'Share configs with your team',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TeamWorkspaceScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _sectionTitle(context, 'Enterprise'),
                _tile(
                  context,
                  icon: Icons.business_rounded,
                  title: enterprise.isEnterpriseMode
                      ? 'Organization joined'
                      : 'Join organization',
                  subtitle: enterprise.isEnterpriseMode
                      ? 'RBAC active on this device'
                      : 'Admin, engineer, or viewer roles',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EnterpriseJoinScreen(),
                    ),
                  ),
                ),
                if (enterprise.can(AppPermission.adminPanel))
                  _tile(
                    context,
                    icon: Icons.admin_panel_settings_rounded,
                    title: 'Admin panel',
                    subtitle: 'Custom vendors & team members',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminPanelScreen(),
                      ),
                    ),
                  ),
                if (enterprise.isEnterpriseMode)
                  _tile(
                    context,
                    icon: Icons.logout_rounded,
                    title: 'Leave organization',
                    subtitle: 'Return to personal full access',
                    color: Colors.orange,
                    onTap: () async {
                      await enterprise.leaveOrganization();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Left organization')),
                        );
                      }
                    },
                  ),
                const SizedBox(height: 20),
                _sectionTitle(context, 'Preferences'),
                Consumer<ThemeProvider>(
                  builder: (context, theme, _) => _tile(
                    context,
                    icon: theme.isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    title: theme.isDarkMode ? 'Light mode' : 'Dark mode',
                    subtitle: 'Toggle app theme',
                    onTap: () => theme.toggleTheme(),
                  ),
                ),
                Consumer<LocaleProvider>(
                  builder: (context, locale, _) => _tile(
                    context,
                    icon: Icons.language_rounded,
                    title: 'Language',
                    subtitle: locale.locale.languageCode == 'hi'
                        ? 'हिंदी'
                        : 'English',
                    onTap: () => _showLanguagePicker(context, locale),
                  ),
                ),
                const SizedBox(height: 20),
                _sectionTitle(context, 'App'),
                _tile(
                  context,
                  icon: Icons.settings_rounded,
                  title: 'Platform settings',
                  subtitle: 'Catalog, cloud sync, audit',
                  enabled: enterprise.can(AppPermission.platformSettings),
                  onTap: () {
                    if (!enterprise.guard(
                        context, AppPermission.platformSettings)) {
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                _tile(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: 'About VFD Hub',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  ),
                ),
                _tile(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy policy',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AppCard(
                  icon: Icons.precision_manufacturing,
                  title: 'VFD Hub Industrial',
                  subtitle: '21 vendors • Modbus • Enterprise RBAC',
                  accentColor: AppTheme.primary,
                  backgroundColor:
                      isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  child: Text(
                    'Levels 1–4 enabled on this build.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : AppTheme.grey500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _signOut(context),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Sign out',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool enabled = true,
    Color? color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        enabled: enabled,
        leading: CircleAvatar(
          backgroundColor: (color ?? AppTheme.primary).withOpacity(0.12),
          child: Icon(icon, color: color ?? AppTheme.primary, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: enabled ? onTap : null,
      ),
    );
  }

  Future<void> _showLanguagePicker(
    BuildContext context,
    LocaleProvider localeProvider,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('English'),
              trailing: localeProvider.locale.languageCode == 'en'
                  ? const Icon(Icons.check, color: AppTheme.primary)
                  : null,
              onTap: () {
                localeProvider.setLocale(const Locale('en'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('हिंदी'),
              trailing: localeProvider.locale.languageCode == 'hi'
                  ? const Icon(Icons.check, color: AppTheme.primary)
                  : null,
              onTap: () {
                localeProvider.setLocale(const Locale('hi'));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;
    await context.read<AuthProvider>().signOut();
    context.read<VfdProvider>().clearSelection();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }
}
