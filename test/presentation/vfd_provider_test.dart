import 'package:flutter_test/flutter_test.dart';
import 'package:vfd_param_app/data/database/database_helper.dart';
import 'package:vfd_param_app/presentation/providers/vfd_provider.dart';

void main() {
  late VfdProvider provider;

  setUpAll(() async {
    await DatabaseHelper.instance.database;
  });

  setUp(() {
    provider = VfdProvider();
  });

  tearDown(() {
    provider.dispose();
  });

  group('VfdProvider', () {
    group('Initialization', () {
      test('should initialize with empty state', () {
        expect(provider.vendors, isEmpty);
        expect(provider.selectedVendor, isNull);
        expect(provider.selectedModelName, isNull);
        expect(provider.selectedPowerRating, isNull);
        expect(provider.connectionType, ConnectionType.hardWire);
      });

      test('should load vendors', () async {
        await provider.loadVendors();
        expect(provider.vendors, isNotEmpty);
        expect(provider.vendors.length, lessThanOrEqualTo(21));
        for (final v in provider.vendors) {
          expect(v.name, isNotEmpty);
        }
      });
    });

    group('Connection Type', () {
      test('should default to hardWire', () {
        expect(provider.connectionType, equals(ConnectionType.hardWire));
      });

      test('should change connection type', () {
        provider.setConnectionType(ConnectionType.communication);
        expect(provider.connectionType, equals(ConnectionType.communication));

        provider.setConnectionType(ConnectionType.hardWire);
        expect(provider.connectionType, equals(ConnectionType.hardWire));
      });

      test('should clear protocol when switching to hardWire', () {
        provider.setConnectionType(ConnectionType.communication);
        provider.setConnectionType(ConnectionType.hardWire);
        expect(provider.selectedProtocol, isNull);
        expect(provider.selectedCommCard, isNull);
      });
    });

    group('Data Persistence', () {
      test('should clear all parameter values', () async {
        await provider.loadVendors();
        // clearAllParameterValues is a no-op when no model selected
        await provider.clearAllParameterValues();
        expect(provider.parameters, isEmpty);
      });

      test('should export configuration', () async {
        await provider.loadVendors();
        final config = provider.exportConfiguration();
        expect(config, isNotNull);
        expect(config.containsKey('vendor'), isTrue);
        expect(config.containsKey('model'), isTrue);
        expect(config.containsKey('powerRating'), isTrue);
        expect(config.containsKey('connectionType'), isTrue);
      });
    });

    group('File Operations', () {
      test('should handle drawing upload when no model selected', () async {
        final result = await provider.uploadDrawing();
        expect(result, isFalse);
      });
    });

    group('Error Handling', () {
      test('should clear error message', () {
        provider.clearError();
        expect(provider.errorMessage, isNull);
      });

      test('should clear selection', () {
        provider.clearSelection();
        expect(provider.selectedVendor, isNull);
        expect(provider.selectedModelName, isNull);
        expect(provider.selectedPowerRating, isNull);
        expect(provider.selectedVoltage, isNull);
        expect(provider.selectedModel, isNull);
        expect(provider.selectedProtocol, isNull);
      });
    });
  });
}
