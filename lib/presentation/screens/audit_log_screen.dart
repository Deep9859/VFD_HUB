import 'package:flutter/material.dart';

import '../../core/services/audit_log_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/audit_event.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  List<AuditEvent> _events = [];
  AuditCategory? _filter;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final events = await AuditLogService.getAll(filter: _filter);
    if (mounted) {
      setState(() {
        _events = events;
        _loading = false;
      });
    }
  }

  IconData _iconFor(AuditCategory c) {
    switch (c) {
      case AuditCategory.configuration:
        return Icons.tune;
      case AuditCategory.parameter:
        return Icons.edit;
      case AuditCategory.project:
        return Icons.folder;
      case AuditCategory.sync:
        return Icons.cloud;
      case AuditCategory.catalog:
        return Icons.cloud_download;
      case AuditCategory.commissioning:
        return Icons.lan;
      case AuditCategory.system:
        return Icons.info;
    }
  }

  Color _colorFor(AuditCategory c) {
    switch (c) {
      case AuditCategory.parameter:
        return Colors.orange;
      case AuditCategory.commissioning:
        return Colors.teal;
      case AuditCategory.sync:
        return Colors.blue;
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear log',
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear audit log?'),
                  content: const Text('This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await AuditLogService.clear();
                await _load();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filter == null,
                  onSelected: (_) {
                    setState(() => _filter = null);
                    _load();
                  },
                ),
                const SizedBox(width: 8),
                ...AuditCategory.values.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(c.name),
                      selected: _filter == c,
                      onSelected: (_) {
                        setState(() => _filter = c);
                        _load();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _events.isEmpty
                    ? const Center(child: Text('No audit events yet'))
                    : ListView.builder(
                        itemCount: _events.length,
                        itemBuilder: (ctx, i) {
                          final e = _events[i];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  _colorFor(e.category).withOpacity(0.15),
                              child: Icon(
                                _iconFor(e.category),
                                color: _colorFor(e.category),
                                size: 20,
                              ),
                            ),
                            title: Text(e.action),
                            subtitle: Text(
                              '${e.detail}\n${_formatTime(e.timestamp)}'
                              '${e.userEmail != null ? ' • ${e.userEmail}' : ''}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            isThreeLine: true,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
