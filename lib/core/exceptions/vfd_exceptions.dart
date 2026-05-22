import 'dart:developer' as developer;
abstract class VfdException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  VfdException({
    required this.message,
    this.code,
    this.originalException,
  });

  @override
  String toString() => message;
}

/// Database-related exceptions
class DatabaseException extends VfdException {
  DatabaseException({
    required super.message,
    String? code,
    super.originalException,
  }) : super(code: code ?? 'DB_ERROR');
}

/// Data not found exception
class DataNotFoundException extends VfdException {
  DataNotFoundException({
    required super.message,
    String? code,
    super.originalException,
  }) : super(code: code ?? 'NOT_FOUND');
}

/// Authentication/Security exception
class SecurityException extends VfdException {
  SecurityException({
    required super.message,
    String? code,
    super.originalException,
  }) : super(code: code ?? 'SECURITY_ERROR');
}

/// File operation exception
class FileException extends VfdException {
  FileException({
    required super.message,
    String? code,
    super.originalException,
  }) : super(code: code ?? 'FILE_ERROR');
}

/// Validation exception
class ValidationException extends VfdException {
  ValidationException({
    required super.message,
    String? code,
    super.originalException,
  }) : super(code: code ?? 'VALIDATION_ERROR');
}

/// Network/API exception
class NetworkException extends VfdException {
  NetworkException({
    required super.message,
    String? code,
    super.originalException,
  }) : super(code: code ?? 'NETWORK_ERROR');
}

/// Generic application exception
class AppException extends VfdException {
  AppException({
    required super.message,
    String? code,
    super.originalException,
  }) : super(code: code ?? 'APP_ERROR');
}

/// Exception helper extension
extension VfdExceptionHelper on VfdException {
  /// Get user-friendly error message
  String get userMessage {
    switch (code) {
      case 'NOT_FOUND':
        return 'Item not found. Please try again.';
      case 'DB_ERROR':
        return 'Database error occurred. Please restart the app.';
      case 'FILE_ERROR':
        return 'Could not process the file. Please check file format.';
      case 'VALIDATION_ERROR':
        return 'Invalid input. Please check and try again.';
      case 'SECURITY_ERROR':
        return 'Security error. Please log in again.';
      case 'NETWORK_ERROR':
        return 'Network error. Please check your connection.';
      default:
        return message;
    }
  }

  /// Log exception for debugging
  void log() {
    developer.log(
      message,
      name: runtimeType.toString(),
      error: originalException,
    );
  }
}
