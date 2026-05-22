import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure local storage for authentication and sensitive profile data.
class SecurityService {
  static const String _legacyKeyStorageKey = 'sec_encryption_key';
  static const String _legacyIvStorageKey = 'sec_encryption_iv';
  static const String _legacyPrefix = 'sec_';

  static const String _authTokenKey = 'sec_auth_token';
  static const String _userIdKey = 'sec_user_id';
  static const String _userEmailKey = 'sec_user_email';
  static const String _userNameKey = 'sec_user_name';
  static const String _passwordHashKey = 'sec_user_password_hash';
  static const String _passwordSaltKey = 'sec_user_password_salt';
  static const String _guestModeKey = 'sec_guest_mode';
  static const String _tokenCreatedAtKey = 'sec_auth_token_created_at';

  static const Duration _tokenLifetime = Duration(hours: 12);

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    await _migrateLegacySensitiveData();
    _initialized = true;
  }

  static Future<void> _migrateLegacySensitiveData() async {
    final prefs = await SharedPreferences.getInstance();

    final legacyEmail = prefs.getString('${_legacyPrefix}user_email');
    final legacyName = prefs.getString('${_legacyPrefix}user_name');
    final legacyPassword = prefs.getString('${_legacyPrefix}user_password');
    final legacyToken = prefs.getString('sec_auth_token');
    final legacyUserId = prefs.getString('sec_user_id');

    if (legacyEmail != null) {
      await _secureStorage.write(key: _userEmailKey, value: legacyEmail);
      await prefs.remove('${_legacyPrefix}user_email');
    }

    if (legacyName != null) {
      await _secureStorage.write(key: _userNameKey, value: legacyName);
      await prefs.remove('${_legacyPrefix}user_name');
    }

    if (legacyPassword != null) {
      await _secureStorage.write(key: _passwordHashKey, value: legacyPassword);
      await prefs.remove('${_legacyPrefix}user_password');
    }

    if (legacyToken != null) {
      await _secureStorage.write(key: _authTokenKey, value: legacyToken);
      await prefs.remove('sec_auth_token');
    }

    if (legacyUserId != null) {
      await _secureStorage.write(key: _userIdKey, value: legacyUserId);
      await prefs.remove('sec_user_id');
    }

    await prefs.remove(_legacyKeyStorageKey);
    await prefs.remove(_legacyIvStorageKey);
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      throw Exception('SecurityService not initialized');
    }
  }

  static List<int> _generateSecureKey(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }

  static String generateSalt() {
    return base64Encode(_generateSecureKey(16));
  }

  static String hashPassword(String password, String salt) {
    final derivator = PBKDF2KeyDerivator(
      HMac(SHA256Digest(), 64),
    );

    derivator.init(
      Pbkdf2Parameters(
        Uint8List.fromList(base64Decode(salt)),
        100000,
        32,
      ),
    );

    final key = derivator.process(Uint8List.fromList(utf8.encode(password)));
    return base64Encode(key);
  }

  static String generateToken(String userId) {
    _ensureInitialized();

    final randomBytes = _generateSecureKey(32);
    final createdAt = DateTime.now().millisecondsSinceEpoch;

    return base64UrlEncode(
      utf8.encode(
        jsonEncode({
          'sub': userId,
          'iat': createdAt,
          'nonce': base64UrlEncode(randomBytes),
        }),
      ),
    );
  }

  static bool _isTokenExpired(DateTime createdAt) {
    return DateTime.now().difference(createdAt) > _tokenLifetime;
  }

  static Future<void> saveAuthToken(String token) async {
    _ensureInitialized();
    await _secureStorage.write(key: _authTokenKey, value: token);
    await _secureStorage.write(
      key: _tokenCreatedAtKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  static Future<String?> _getAuthToken() async {
    _ensureInitialized();
    return _secureStorage.read(key: _authTokenKey);
  }

  static Future<void> saveUserId(String userId) async {
    _ensureInitialized();
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  static Future<String?> getUserId() async {
    _ensureInitialized();
    return _secureStorage.read(key: _userIdKey);
  }

  static Future<bool> hasValidAuthSession() async {
    _ensureInitialized();

    final token = await _getAuthToken();
    final createdAtRaw = await _secureStorage.read(key: _tokenCreatedAtKey);

    if (token == null || token.isEmpty || createdAtRaw == null) {
      return false;
    }

    final createdAt = DateTime.tryParse(createdAtRaw);
    if (createdAt == null || _isTokenExpired(createdAt)) {
      await clearAuth();
      return false;
    }

    return true;
  }

  static Future<void> clearAuth() async {
    _ensureInitialized();

    await _secureStorage.delete(key: _authTokenKey);
    await _secureStorage.delete(key: _userIdKey);
    await _secureStorage.delete(key: _guestModeKey);
    await _secureStorage.delete(key: _tokenCreatedAtKey);
  }

  static Future<void> saveUserProfile({
    required String userId,
    required String email,
    required String name,
    required String passwordHash,
    required String passwordSalt,
  }) async {
    _ensureInitialized();

    await saveUserId(userId);
    await _secureStorage.write(key: _userEmailKey, value: email);
    await _secureStorage.write(key: _userNameKey, value: name);
    await _secureStorage.write(key: _passwordHashKey, value: passwordHash);
    await _secureStorage.write(key: _passwordSaltKey, value: passwordSalt);
  }

  static Future<String?> getStoredUserEmail() async {
    _ensureInitialized();
    return _secureStorage.read(key: _userEmailKey);
  }

  static Future<String?> getStoredPasswordHash() async {
    _ensureInitialized();
    return _secureStorage.read(key: _passwordHashKey);
  }

  static Future<String?> getStoredPasswordSalt() async {
    _ensureInitialized();
    return _secureStorage.read(key: _passwordSaltKey);
  }

  static Future<void> enableGuestMode() async {
    _ensureInitialized();
    await _secureStorage.write(key: _guestModeKey, value: 'true');
  }
}
