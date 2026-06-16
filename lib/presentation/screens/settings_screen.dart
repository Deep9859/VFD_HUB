import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../core/services/audit_log_service.dart';
import '../../core/services/cloud_sync_service.dart';
import '../../core/services/platform_settings_service.dart';
import '../../core/services/remote_catalog_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_context.dart';
import '../../data/models/audit_event.dart';
import '../providers/enterprise_provider.dart';
import '../../core/enterprise/app_permission.dart';
import 'audit_log_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _catalogUrlCtrl = TextEditingController();
  final _syncUrlCtrl = TextEditingController();
  final _apiKeyCtrl = TextEditingController();
  bool _syncEnabled = false;
  bool _loading = true;
  String? _catalogUpdated;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _catalogUrlCtrl.dispose();
    _syncUrlCtrl.dispose();
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    _catalogUrlCtrl.text = await PlatformSettingsService.catalogUrl ?? '';
    _syncUrlCtrl.text = await PlatformSettingsService.syncUrl ?? '';
    _apiKeyCtrl.text = await PlatformSettingsService.syncApiKey ?? '';
    _syncEnabled = await PlatformSettingsService.syncEnabled;
    _catalogUpdated = await RemoteCatalogService.lastUpdatedLabel();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveSettings() async {
    await PlatformSettingsService.setCatalogUrl(_catalogUrlCtrl.text);
    await PlatformSettingsService.setSyncUrl(_syncUrlCtrl.text);
    await PlatformSettingsService.setSyncApiKey(_apiKeyCtrl.text);
    await PlatformSettingsService.setSyncEnabled(_syncEnabled);
    await AuditLogService.log(
      category: AuditCategory.system,
      action: 'Settings saved',
      detail: 'Platform URLs and sync preferences updated',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  void _showResult(({bool ok, String message}) result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.ok ? context.successColor : context.errorColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Settings'),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Remote catalog'),
          Text(
            'Host a JSON catalog file (same schema as Excel import). '
            'Updates merge over built-in vendor data.',
            style: context.captionStyle?.copyWith(color: context.onSurfaceMuted),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _catalogUrlCtrl,
            decoration: const InputDecoration(
              labelText: 'Catalog URL',
              hintText: 'https://your-server.com/vfd-catalog.json',
            ),
          ),
          if (_catalogUpdated != null) ...[
            const SizedBox(height: 4),
            Text(
              'Last cached: $_catalogUpdated',
              style: context.captionStyle?.copyWith(
                fontSize: 11,
                color: context.onSurfaceMuted,
              ),
            ),
          ],
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () async {
              await _saveSettings();
              final result = await RemoteCatalogService.refreshFromServer();
              _catalogUpdated = await RemoteCatalogService.lastUpdatedLabel();
              setState(() {});
              _showResult(result);
            },
            icon: const Icon(Icons.cloud_download),
            label: const Text('Refresh catalog now'),
          ),
          const Divider(height: 32),
          _sectionTitle('Cloud sync (optional)'),
          Text(
            'REST API: GET/POST /api/v1/backup, GET /api/v1/health. '
            'Bearer token optional.',
            style: context.captionStyle?.copyWith(color: context.onSurfaceMuted),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Enable cloud sync'),
            value: _syncEnabled,
            onChanged: (v) => setState(() => _syncEnabled = v),
          ),
          TextField(
            controller: _syncUrlCtrl,
            decoration: const InputDecoration(
              labelText: 'Sync server base URL',
              hintText: 'https://your-server.com',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _apiKeyCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'API key (Bearer)',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: () async {
                  await _saveSettings();
                  _showResult(await CloudSyncService.testConnection());
                },
                child: const Text('Test connection'),
              ),
              OutlinedButton(
                onPressed: () async {
                  await _saveSettings();
                  _showResult(await CloudSyncService.uploadBackup());
                },
                child: const Text('Upload backup'),
              ),
              OutlinedButton(
                onPressed: () async {
                  await _saveSettings();
                  _showResult(await CloudSyncService.downloadBackup());
                },
                child: const Text('Download backup'),
              ),
            ],
          ),
          const Divider(height: 32),
          _sectionTitle('Enterprise'),
          Consumer<EnterpriseProvider>(
            builder: (context, enterprise, _) {
              if (!enterprise.isEnterpriseMode) {
                return const ListTile(
                  leading: Icon(Icons.business),
                  title: Text('Not in organization'),
                  subtitle: Text('Use menu -> Join Organization'),
                );
              }
              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.verified_user),
                    title: Text(enterprise.profile!.orgName),
                    subtitle: Text(
                      'Role: ${EnterprisePermissions.label(enterprise.profile!.role)}',
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      await enterprise.leaveOrganization();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Left organization')),
                        );
                      }
                    },
                    child: const Text('Leave organization'),
                  ),
                ],
              );
            },
          ),
          const Divider(height: 32),
          _sectionTitle('Compliance'),
          ListTile(
            leading: const Icon(Icons.history, color: AppTheme.primary),
            title: const Text('Audit log'),
            subtitle: const Text('Parameter changes, imports, sync events'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AuditLogScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
}
