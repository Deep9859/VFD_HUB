import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/audit_event.dart';

class AuditLogService {
  AuditLogService._();

  static const _storageKey = 'audit_log_v1';
  static const _maxEntries = 500;
  static final _random = Random();
  static String? _activeUserEmail;

  static void setActiveUser(String? email) {
    _activeUserEmail = email;
  }

  static Future<void> log({
    required AuditCategory category,
    required String action,
    required String detail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getAll();
    events.insert(
      0,
      AuditEvent(
        id: 'audit_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(9999)}',
        category: category,
        action: action,
        detail: detail,
        timestamp: DateTime.now(),
        userEmail: _activeUserEmail,
      ),
    );
    final trimmed = events.take(_maxEntries).toList();
    await prefs.setStringList(
      _storageKey,
      trimmed.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  static Future<List<AuditEvent>> getAll({AuditCategory? filter}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    final events = <AuditEvent>[];
    for (final entry in raw) {
      try {
        events.add(AuditEvent.fromJson(
          jsonDecode(entry) as Map<String, dynamic>,
        ));
      } catch (_) {
        continue;
      }
    }
    if (filter != null) {
      return events.where((e) => e.category == filter).toList();
    }
    return events;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
