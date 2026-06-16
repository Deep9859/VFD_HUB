import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enterprise/app_permission.dart';
import '../../core/services/team_sharing_service.dart';
import '../../data/models/team_member.dart';
import '../../core/theme/theme_context.dart';
import '../providers/auth_provider.dart';
import '../providers/enterprise_provider.dart';
import '../providers/vfd_provider.dart';

class TeamWorkspaceScreen extends StatefulWidget {
  const TeamWorkspaceScreen({super.key});

  @override
  State<TeamWorkspaceScreen> createState() => _TeamWorkspaceScreenState();
}

class _TeamWorkspaceScreenState extends State<TeamWorkspaceScreen> {
  List<SharedTeamProject> _projects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _projects = await TeamSharingService.getSharedProjects();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _shareCurrent() async {
    final enterprise = context.read<EnterpriseProvider>();
    if (!enterprise.guard(context, AppPermission.manageProjects)) return;

    final provider = context.read<VfdProvider>();
    final auth = context.read<AuthProvider>();
    if (provider.selectedVendor == null || provider.selectedModelName == null) {
      _snack('Configure a VFD first', error: true);
      return;
    }

    final teamId = enterprise.profile?.teamId ?? 'team_default';
    final name =
        '${provider.selectedVendor!.name} ${provider.selectedModelName}';

    final project = await TeamSharingService.shareProjectLocally(
      teamId: teamId,
      sharedBy: auth.userEmail ?? 'unknown',
      projectName: name,
      configuration: provider.exportConfiguration(),
    );

    final push = await TeamSharingService.pushToServer(project);
    _snack(push.message, error: !push.ok);
    await _load();
  }

  Future<void> _pullRemote() async {
    final teamId =
        context.read<EnterpriseProvider>().profile?.teamId ?? 'team_default';
    final result = await TeamSharingService.pullFromServer(teamId);
    _snack(result.message, error: !result.ok);
    await _load();
  }

  Future<void> _importProject(SharedTeamProject project) async {
    final enterprise = context.read<EnterpriseProvider>();
    if (!enterprise.guard(context, AppPermission.importConfiguration)) return;

    final error = await context
        .read<VfdProvider>()
        .importConfiguration(project.configuration);
    if (!mounted) return;
    if (error != null) {
      _snack(error, error: true);
      return;
    }
    _snack('Imported "${project.projectName}"');
    Navigator.pop(context);
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? context.errorColor : context.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final enterprise = context.watch<EnterpriseProvider>();
    final org = enterprise.profile?.orgName ?? 'Personal';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Workspace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download),
            tooltip: 'Pull from server',
            onPressed: _pullRemote,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _shareCurrent,
        icon: const Icon(Icons.share),
        label: const Text('Share current'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Organization: $org • Team: ${enterprise.profile?.teamId ?? "—"}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: _projects.isEmpty
                      ? const Center(
                          child: Text('No shared projects yet'),
                        )
                      : ListView.builder(
                          itemCount: _projects.length,
                          itemBuilder: (ctx, i) {
                            final p = _projects[i];
                            return ListTile(
                              leading: const Icon(Icons.folder_shared),
                              title: Text(p.projectName),
                              subtitle: Text(
                                'By ${p.sharedBy} • ${p.sharedAt.toLocal()}',
                              ),
                              trailing: const Icon(Icons.download),
                              onTap: () => _importProject(p),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
