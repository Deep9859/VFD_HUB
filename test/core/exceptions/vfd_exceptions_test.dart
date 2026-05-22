import 'package:flutter_test/flutter_test.dart';
import 'package:vfd_param_app/core/exceptions/vfd_exceptions.dart';

void main() {
  group('VfdExceptions', () {
    group('DatabaseException', () {
      test('should create with message and code', () {
        final exception = DatabaseException(
          message: 'Connection failed',
          code: 'DB_ERROR',
        );

        expect(exception.message, 'Connection failed');
        expect(exception.code, 'DB_ERROR');
        expect(exception.toString(), 'Connection failed');
      });

      test('should have correct userMessage', () {
        final exception = DatabaseException(
          message: 'Table not found',
          code: 'DB_ERROR',
        );

        expect(exception.userMessage,
            'Database error occurred. Please restart the app.');
      });

      test('should store original exception', () {
        final originalError = Exception('Original error');
        final exception = DatabaseException(
          message: 'Database error',
          originalException: originalError,
        );

        expect(exception.originalException, originalError);
      });
    });

    group('DataNotFoundException', () {
      test('should create with message', () {
        final exception = DataNotFoundException(
          message: 'Vendor not found',
        );

        expect(exception.message, 'Vendor not found');
        expect(exception.code, 'NOT_FOUND');
      });

      test('should have correct userMessage', () {
        final exception = DataNotFoundException(
          message: 'Item not in database',
        );

        expect(exception.userMessage, 'Item not found. Please try again.');
      });
    });

    group('ValidationException', () {
      test('should create with message', () {
        final exception = ValidationException(
          message: 'Invalid input',
        );

        expect(exception.message, 'Invalid input');
        expect(exception.code, 'VALIDATION_ERROR');
      });

      test('should have correct userMessage', () {
        final exception = ValidationException(
          message: 'Name cannot be empty',
        );

        expect(exception.userMessage,
            'Invalid input. Please check and try again.');
      });
    });

    group('FileException', () {
      test('should create with message', () {
        final exception = FileException(
          message: 'File not found',
        );

        expect(exception.message, 'File not found');
        expect(exception.code, 'FILE_ERROR');
      });

      test('should have correct userMessage', () {
        final exception = FileException(
          message: 'Cannot read file',
        );

        expect(exception.userMessage,
            'Could not process the file. Please check file format.');
      });
    });

    group('SecurityException', () {
      test('should create with message', () {
        final exception = SecurityException(
          message: 'Unauthorized access',
        );

        expect(exception.message, 'Unauthorized access');
        expect(exception.code, 'SECURITY_ERROR');
      });

      test('should have correct userMessage', () {
        final exception = SecurityException(
          message: 'Invalid token',
        );

        expect(exception.userMessage, 'Security error. Please log in again.');
      });
    });

    group('NetworkException', () {
      test('should create with message', () {
        final exception = NetworkException(
          message: 'Connection timeout',
        );

        expect(exception.message, 'Connection timeout');
        expect(exception.code, 'NETWORK_ERROR');
      });

      test('should have correct userMessage', () {
        final exception = NetworkException(
          message: 'No internet',
        );

        expect(exception.userMessage,
            'Network error. Please check your connection.');
      });
    });

    group('AppException', () {
      test('should create with message', () {
        final exception = AppException(
          message: 'Unknown error',
        );

        expect(exception.message, 'Unknown error');
        expect(exception.code, 'APP_ERROR');
      });

      test('should have correct default userMessage', () {
        final exception = AppException(
          message: 'Something went wrong',
          code: 'UNKNOWN_CODE',
        );

        expect(exception.userMessage, 'Something went wrong');
      });
    });

    group('VfdExceptionHelper', () {
      test('log should print exception details', () {
        final exception = DatabaseException(
          message: 'Test error',
          code: 'TEST_ERROR',
        );

        // Should not throw
        exception.log();
      });

      test('should handle exceptions hierarchy', () {
        final vfdException = ValidationException(
          message: 'Validation failed',
        );

        expect(vfdException, isA<VfdException>());
        expect(vfdException.code, 'VALIDATION_ERROR');
      });
    });

    group('Exception Hierarchy', () {
      test('all exceptions should be VfdException', () {
        expect(DatabaseException(message: 'test'), isA<VfdException>());
        expect(DataNotFoundException(message: 'test'), isA<VfdException>());
        expect(ValidationException(message: 'test'), isA<VfdException>());
        expect(FileException(message: 'test'), isA<VfdException>());
        expect(SecurityException(message: 'test'), isA<VfdException>());
        expect(NetworkException(message: 'test'), isA<VfdException>());
        expect(AppException(message: 'test'), isA<VfdException>());
      });

      test('all exceptions should be Exception', () {
        expect(DatabaseException(message: 'test'), isA<Exception>());
        expect(ValidationException(message: 'test'), isA<Exception>());
      });
    });

    group('Exception with Original Exception', () {
      test('should preserve original exception details', () {
        final originalError = Exception('Original database error');
        final exception = DatabaseException(
          message: 'Wrapped error',
          originalException: originalError,
        );

        expect(exception.originalException.toString(),
            contains('Original database error'));
      });

      test('should handle null original exception', () {
        final exception = DatabaseException(
          message: 'Error without original',
          originalException: null,
        );

        expect(exception.originalException, null);
      });
    });

    group('Custom Exception Messages', () {
      test('should preserve custom message over code', () {
        final exception = DatabaseException(
          message: 'Custom database error message',
          code: 'DB_ERROR',
        );

        expect(exception.message, 'Custom database error message');
      });

      test('should support all error codes', () {
        const codes = [
          'NOT_FOUND',
          'DB_ERROR',
          'FILE_ERROR',
          'VALIDATION_ERROR',
          'SECURITY_ERROR',
          'NETWORK_ERROR',
        ];

        for (final code in codes) {
          final exception = DataNotFoundException(
            message: 'Test message',
            code: code,
          );
          expect(() => exception.userMessage, returnsNormally);
        }
      });
    });
  });
}
