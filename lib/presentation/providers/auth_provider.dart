import 'package:flutter/material.dart';
import '../../core/security/input_validation_service.dart';
import '../../core/security/security_service.dart';
import '../../core/services/audit_log_service.dart';

enum AuthState { unknown, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  AuthState _state = AuthState.unknown;
  String? _userId;
  String? _userEmail;
  String? _errorMessage;
  bool _isLoading = false;

  AuthState get state => _state;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthState.authenticated;

  void _syncAuditUser() => AuditLogService.setActiveUser(_userEmail);

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final hasValidSession = await SecurityService.hasValidAuthSession();
      final storedUserId = await SecurityService.getUserId();
      final storedUserEmail = await SecurityService.getStoredUserEmail();

      if (hasValidSession && storedUserId != null) {
        _userId = storedUserId;
        _userEmail = storedUserEmail;
        _state = AuthState.authenticated;
        _syncAuditUser();
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      _errorMessage = 'Failed to check auth status: $e';
      _state = AuthState.unauthenticated;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!InputValidationService.isValidEmail(email)) {
        _errorMessage = 'Invalid email format';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final existingEmail = await SecurityService.getStoredUserEmail();
      final existingPasswordHash =
          await SecurityService.getStoredPasswordHash();
      if (existingEmail != null && existingPasswordHash != null) {
        _errorMessage = existingEmail.toLowerCase() == email.toLowerCase()
            ? 'An account with this email already exists. Please sign in.'
            : 'This device already has a registered account. Please sign in.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // OWASP compliant password: 12+ chars with uppercase, lowercase, digits, special chars
      if (password.length < 12) {
        _errorMessage = 'Password must be at least 12 characters';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!password.contains(RegExp(r'[A-Z]'))) {
        _errorMessage = 'Password must contain an uppercase letter';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!password.contains(RegExp(r'[a-z]'))) {
        _errorMessage = 'Password must contain a lowercase letter';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!password.contains(RegExp(r'[0-9]'))) {
        _errorMessage = 'Password must contain a number';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        _errorMessage =
            'Password must contain a special character (!@#\$%^&* etc)';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final salt = SecurityService.generateSalt();
      final hashedPassword = SecurityService.hashPassword(password, salt);
      final userId = DateTime.now().millisecondsSinceEpoch.toString();

      await SecurityService.saveUserProfile(
        userId: userId,
        email: email,
        name: name,
        passwordHash: hashedPassword,
        passwordSalt: salt,
      );

      final token = SecurityService.generateToken(userId);
      await SecurityService.saveAuthToken(token);

      _userId = userId;
      _userEmail = email;
      _state = AuthState.authenticated;
      _syncAuditUser();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Sign up failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (!InputValidationService.isValidEmail(email)) {
        _errorMessage = 'Invalid email format';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final storedPassword = await SecurityService.getStoredPasswordHash();
      final storedSalt = await SecurityService.getStoredPasswordSalt();
      final storedEmail = await SecurityService.getStoredUserEmail();
      final storedUserId = await SecurityService.getUserId();

      if (storedEmail == null || storedPassword == null || storedSalt == null) {
        _errorMessage = 'User not found. Please sign up first.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final hashedInput = SecurityService.hashPassword(password, storedSalt);

      if (hashedInput == storedPassword &&
          email.toLowerCase() == storedEmail.toLowerCase()) {
        final token = SecurityService.generateToken(storedUserId!);
        await SecurityService.saveAuthToken(token);

        _userId = storedUserId;
        _userEmail = email;
        _state = AuthState.authenticated;
        _syncAuditUser();

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Sign in failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await SecurityService.clearAuth();
      _userId = null;
      _userEmail = null;
      _state = AuthState.unauthenticated;
      _syncAuditUser();
    } catch (e) {
      _errorMessage = 'Sign out failed: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> signInAsGuest() async {
    _isLoading = true;
    notifyListeners();

    try {
      final guestUserId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      _userId = guestUserId;
      _userEmail = 'guest@example.com';
      _state = AuthState.authenticated;
      _syncAuditUser();
      await SecurityService.enableGuestMode();
      await SecurityService.saveUserId(guestUserId);
      await SecurityService.saveAuthToken(
        SecurityService.generateToken(guestUserId),
      );
    } catch (e) {
      _errorMessage = 'Guest login failed: $e';
    }

    _isLoading = false;
    if (hasListeners) notifyListeners();
  }
}
