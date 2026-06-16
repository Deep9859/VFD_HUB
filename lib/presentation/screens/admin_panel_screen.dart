import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enterprise/app_permission.dart';
import '../../core/services/custom_vendor_service.dart';
import '../../core/services/team_sharing_service.dart';
import '../../data/models/custom_vendor_entry.dart';
import '../../data/models/team_member.dart';
import '../providers/enterprise_provider.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  List<CustomVendorEntry> _vendors = [];
  List<TeamMember> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _vendors = await CustomVendorService.getAll();
    _members = await TeamSharingService.getMembers();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _addVendor() async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add custom vendor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Vendor name'),
            ),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
        ],
      ),
    );
    if (ok != true || nameCtrl.text.trim().isEmpty) return;
    await CustomVendorService.addVendor(CustomVendorEntry(
      name: nameCtrl.text.trim(),
      description: descCtrl.text.trim(),
    ));
    nameCtrl.dispose();
    descCtrl.dispose();
    await _load();
  }

  Future<void> _addMember() async {
    final emailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    var role = EnterpriseRole.commissioningEngineer;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add team member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Display name'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<EnterpriseRole>(
                value: role,
                items: EnterpriseRole.values
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(EnterprisePermissions.label(r)),
                        ))
                    .toList(),
                onChanged: (v) => setS(() => role = v ?? role),
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
          ],
        ),
      ),
    );
    if (ok != true || emailCtrl.text.trim().isEmpty) return;
    await TeamSharingService.addMember(TeamMember(
      email: emailCtrl.text.trim(),
      displayName: nameCtrl.text.trim(),
      role: role,
      joinedAt: DateTime.now(),
    ));
    emailCtrl.dispose();
    nameCtrl.dispose();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final enterprise = context.watch<EnterpriseProvider>();
    if (!enterprise.can(AppPermission.adminPanel)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Panel')),
        body: const Center(child: Text('Administrator role required')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Custom Vendors'),
            Tab(text: 'Team'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'admin-panel-fab',
        onPressed: _tabs.index == 0 ? _addVendor : _addMember,
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _vendorTab(),
                _teamTab(),
              ],
            ),
    );
  }

  Widget _vendorTab() {
    if (_vendors.isEmpty) {
      return const Center(child: Text('No custom vendors — tap + to add'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vendors.length,
      itemBuilder: (ctx, i) {
        final v = _vendors[i];
        return Card(
          child: ListTile(
            title: Text(v.name),
            subtitle: Text('${v.models.length} models • ${v.description}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await CustomVendorService.deleteVendor(v.name);
                await _load();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _teamTab() {
    if (_members.isEmpty) {
      return const Center(child: Text('No team members — tap + to add'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _members.length,
      itemBuilder: (ctx, i) {
        final m = _members[i];
        return Card(
          child: ListTile(
            title: Text(m.displayName.isEmpty ? m.email : m.displayName),
            subtitle: Text('${m.email} • ${EnterprisePermissions.label(m.role)}'),
            trailing: IconButton(
              icon: const Icon(Icons.person_remove, color: Colors.red),
              onPressed: () async {
                await TeamSharingService.removeMember(m.email);
                await _load();
              },
            ),
          ),
        );
      },
    );
  }
}
