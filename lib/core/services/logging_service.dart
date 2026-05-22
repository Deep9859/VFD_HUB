import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Log levels for the application
enum LogLevel { debug, info, warning, error, critical }

/// Centralized logging service for the entire application
/// Replaces print() statements and provides structured logging
class LoggingService {
  static const String _appName = 'VFD_HUB';
  static LogLevel _minLogLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// Set minimum log level for filtering
  static void setMinLogLevel(LogLevel level) {
    _minLogLevel = level;
  }

  /// Log debug message
  static void debug(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log info message
  static void info(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log warning message
  static void warning(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log error message
  static void error(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log critical error
  static void critical(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.critical, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  static void _log(
    LogLevel level, 
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    // Skip if below minimum log level
    if (level.index < _minLogLevel.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final logTag = tag ?? 'APP';
    final levelName = _getLevelName(level);
    final formattedMessage = '[$timestamp] [$levelName] [$logTag] $message';

    // Output to developer logs
    developer.log(
      formattedMessage,
      name: _appName,
      error: error,
      stackTrace: stackTrace,
    );

    // In debug mode, also print to console
    if (kDebugMode) {
      final emoji = _getLevelEmoji(level);
      final debugMessage = '$emoji $formattedMessage';
      if (error != null) {
        debugPrint('$debugMessage\nError: $error');
      } else {
        debugPrint(debugMessage);
      }
    }
  }

  static String _getLevelName(LogLevel level) {
    return level.toString().split('.').last.toUpperCase();
  }

  static String _getLevelEmoji(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🔍';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.critical:
        return '🔴';
    }
  }
}
