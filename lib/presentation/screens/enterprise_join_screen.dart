import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enterprise/app_permission.dart';
import '../../core/services/enterprise_sso_service.dart';
import '../../core/theme/theme_context.dart';
import '../providers/enterprise_provider.dart';
import '../widgets/app_card.dart';
import '../../core/theme/app_theme.dart';

class EnterpriseJoinScreen extends StatefulWidget {
  const EnterpriseJoinScreen({super.key});

  @override
  State<EnterpriseJoinScreen> createState() => _EnterpriseJoinScreenState();
}

class _EnterpriseJoinScreenState extends State<EnterpriseJoinScreen> {
  final _orgCtrl = TextEditingController(text: 'My Plant');
  final _codeCtrl = TextEditingController();
  final _teamCtrl = TextEditingController(text: 'team_default');
  final _ssoTokenCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _orgCtrl.dispose();
    _codeCtrl.dispose();
    _teamCtrl.dispose();
    _ssoTokenCtrl.dispose();
    super.dispose();
  }

  Future<void> _joinInvite() async {
    setState(() => _busy = true);
    final enterprise = context.read<EnterpriseProvider>();
    final result = await enterprise.joinWithInviteCode(
      code: _codeCtrl.text,
      orgName: _orgCtrl.text.trim(),
      teamId: _teamCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.ok ? context.successColor : context.errorColor,
      ),
    );
    if (result.ok) Navigator.pop(context, true);
  }

  Future<void> _joinSso() async {
    setState(() => _busy = true);
    final enterprise = context.read<EnterpriseProvider>();
    final result = await enterprise.joinWithSsoToken(_ssoTokenCtrl.text.trim());
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.ok ? context.successColor : context.errorColor,
      ),
    );
    if (result.ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Organization')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            icon: Icons.business,
            title: 'Enterprise mode',
            subtitle: 'Role-based access, team sharing, admin tools',
            accentColor: AppTheme.primary,
            child: const Text(
              'Without joining, the app runs in full-access personal mode.',
              style: TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _orgCtrl,
            decoration: const InputDecoration(
              labelText: 'Organization name',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _teamCtrl,
            decoration: const InputDecoration(
              labelText: 'Team ID',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _codeCtrl,
            decoration: const InputDecoration(
              labelText: 'Invite code',
              hintText: 'VFDHUB-ADMIN / VFDHUB-ENGINEER / VFDHUB-VIEWER',
            ),
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _busy ? null : _joinInvite,
              child: const Text('Join with invite code'),
            ),
          ),
          const Divider(height: 32),
          const Text(
            'SSO (server required)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _ssoTokenCtrl,
            decoration: const InputDecoration(
              labelText: 'OIDC id_token',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _busy ? null : _joinSso,
            child: const Text('Exchange SSO token'),
          ),
          const SizedBox(height: 24),
          ExpansionTile(
            title: const Text('Demo invite codes'),
            children: EnterpriseSsoService.demoInviteCodes.entries
                .map(
                  (e) => ListTile(
                    dense: true,
                    title: Text(e.key),
                    trailing: Text(
                      EnterprisePermissions.label(e.value),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
