import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/enterprise_profile.dart';

class EnterpriseProfileService {
  EnterpriseProfileService._();

  static const _profileKey = 'enterprise_profile_v1';
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<EnterpriseProfile?> load() async {
    final raw = await _secure.read(key: _profileKey);
    if (raw == null) return null;
    try {
      return EnterpriseProfile.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(EnterpriseProfile profile) async {
    await _secure.write(
      key: _profileKey,
      value: jsonEncode(profile.toJson()),
    );
  }

  static Future<void> clear() async {
    await _secure.delete(key: _profileKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('enterprise_invite_used');
  }
}
