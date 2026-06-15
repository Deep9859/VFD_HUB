import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/config/configuration_flow.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/saved_project_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/saved_project.dart';
import '../providers/vfd_provider.dart';
import '../widgets/app_card.dart';

class SavedProjectsScreen extends StatefulWidget {
  final bool embedInShell;

  const SavedProjectsScreen({super.key, this.embedInShell = false});

  @override
  State<SavedProjectsScreen> createState() => _SavedProjectsScreenState();
}

class _SavedProjectsScreenState extends State<SavedProjectsScreen> {
  List<SavedProject> _projects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final projects = await SavedProjectService.getAll();
    if (mounted) {
      setState(() {
        _projects = projects;
        _loading = false;
      });
    }
  }

  Future<void> _saveCurrent() async {
    final provider = context.read<VfdProvider>();
    if (provider.selectedVendor == null || provider.selectedModelName == null) {
      _showSnack('Select vendor and model first', isError: true);
      return;
    }

    final nameController = TextEditingController(
      text: '${provider.selectedVendor!.name} ${provider.selectedModelName}',
    );

    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Project'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Project name',
            hintText: 'e.g. Plant A - Pump 3',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, nameController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    nameController.dispose();

    if (name == null || name.isEmpty) return;

    await SavedProjectService.save(
      name: name,
      configuration: provider.exportConfiguration(),
    );
    await _load();
    _showSnack('Project "$name" saved');
  }

  Future<void> _loadProject(SavedProject project) async {
    final provider = context.read<VfdProvider>();
    final error = await provider.importConfiguration(project.configuration);
    if (!mounted) return;

    if (error != null) {
      _showSnack(error, isError: true);
      return;
    }

    if (!widget.embedInShell) {
      Navigator.pop(context, ConfigurationFlow.activeStep(provider));
    }
    _showSnack('Loaded "${project.name}"');
  }

  Future<void> _deleteProject(SavedProject project) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete project?'),
        content: Text('Remove "${project.name}" from saved projects?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await SavedProjectService.delete(project.id);
    await _load();
  }

  Future<void> _backupAll() async {
    await BackupService.shareBackup();
    _showSnack('Backup file ready to share');
  }

  Future<void> _restoreBackup() async {
    final error = await BackupService.restoreFromFile();
    if (!mounted) return;
    if (error != null) {
      _showSnack(error, isError: true);
      return;
    }
    await _load();
    _showSnack('Backup restored');
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _loading
        ? const Center(child: CircularProgressIndicator())
        : _projects.isEmpty
            ? _buildEmpty()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _projects.length,
                itemBuilder: (ctx, i) => _buildTile(_projects[i]),
              );

    if (widget.embedInShell) {
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Saved Projects'),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primary,
                        AppTheme.primary.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.backup),
                  tooltip: 'Export backup',
                  onPressed: _backupAll,
                ),
                IconButton(
                  icon: const Icon(Icons.restore),
                  tooltip: 'Restore backup',
                  onPressed: _restoreBackup,
                ),
              ],
            ),
            SliverFillRemaining(child: content),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _saveCurrent,
          icon: const Icon(Icons.save),
          label: const Text('Save Current'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.backup),
            tooltip: 'Export backup',
            onPressed: _backupAll,
          ),
          IconButton(
            icon: const Icon(Icons.restore),
            tooltip: 'Restore backup',
            onPressed: _restoreBackup,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveCurrent,
        icon: const Icon(Icons.save),
        label: const Text('Save Current'),
      ),
      body: content,
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: AppCard(
        icon: Icons.folder_open,
        title: 'No saved projects',
        subtitle: 'Save your current VFD setup as a named project',
        accentColor: AppTheme.primary,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                'Use "Save Current" after configuring a drive, or restore a full backup from the menu.',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile(SavedProject project) {
    final subtitle = [
      if (project.vendorName.isNotEmpty) project.vendorName,
      if (project.modelName.isNotEmpty) project.modelName,
      if (project.powerRating != null) '${project.powerRating} kW',
    ].join(' • ');

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withOpacity(0.15),
          child: const Icon(Icons.folder, color: AppTheme.primary),
        ),
        title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle.isEmpty ? 'Configuration snapshot' : subtitle,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'load') _loadProject(project);
            if (value == 'delete') _deleteProject(project);
          },
          itemBuilder: (ctx) => const [
            PopupMenuItem(value: 'load', child: Text('Load project')),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
        onTap: () => _loadProject(project),
      ),
    );
  }
}
