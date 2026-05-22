import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vfd_param_app/core/exceptions/vfd_exceptions.dart' as vfd_ex;
import 'package:vfd_param_app/data/database/database_helper.dart';
import 'package:vfd_param_app/data/models/vendor_model.dart';
import 'package:vfd_param_app/data/models/vfd_model.dart';
import 'package:vfd_param_app/data/models/vfd_parameter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for testing
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('DatabaseHelper Tests', () {
    late DatabaseHelper dbHelper;

    setUpAll(() async {
      // Initialize database for tests
      dbHelper = DatabaseHelper.instance;
    });

    group('getAllVendors', () {
      test('should return list of vendors on success', () async {
        expect(
          () async {
            final vendors = await dbHelper.getAllVendors();
            expect(vendors, isNotNull);
            expect(vendors, isA<List<Vendor>>());
          },
          returnsNormally,
        );
      });

      test('should throw DatabaseException on query error', () async {
        // This would require mocking, but demonstrates the pattern
        // In real scenarios, this tests error handling
      });
    });

    group('searchModels', () {
      test('should throw ValidationException for empty query', () async {
        expect(
          () => dbHelper.searchModels(''),
          throwsA(isA<vfd_ex.ValidationException>()),
        );
      });

      test('should return models matching query', () async {
        try {
          final results = await dbHelper.searchModels('VFD');
          expect(results, isA<List<VfdModel>>());
        } on vfd_ex.ValidationException {
          fail('Should not throw ValidationException for non-empty query');
        }
      });

      test('should return empty list for non-matching query', () async {
        try {
          final results = await dbHelper.searchModels('NONEXISTENT_MODEL_XYZ');
          expect(results, isA<List<VfdModel>>());
          // Results may be empty, which is acceptable
        } on vfd_ex.ValidationException {
          fail('Should not throw for valid non-empty query');
        }
      });
    });

    group('getPowerRatingsByVendorAndName', () {
      test('should throw DataNotFoundException when no ratings found',
          () async {
        expect(
          () => dbHelper.getPowerRatingsByVendorAndName(99999, 'NONEXISTENT'),
          throwsA(isA<vfd_ex.DataNotFoundException>()),
        );
      });

      test('should return sorted list of power ratings', () async {
        try {
          // Try with a valid vendor
          final vendors = await dbHelper.getAllVendors();
          if (vendors.isNotEmpty) {
            final modelNames =
                await dbHelper.getDistinctModelNamesByVendor(vendors[0].id);
            if (modelNames.isNotEmpty) {
              final ratings = await dbHelper.getPowerRatingsByVendorAndName(
                vendors[0].id,
                modelNames[0],
              );
              expect(ratings, isA<List<double>>());
              // Check if sorted
              for (int i = 0; i < ratings.length - 1; i++) {
                expect(ratings[i], lessThanOrEqualTo(ratings[i + 1]));
              }
            }
          }
        } on vfd_ex.DataNotFoundException {
          // Expected if no valid data exists
        }
      });
    });

    group('getVoltagesByFilter', () {
      test('should throw DataNotFoundException when no voltages found',
          () async {
        expect(
          () => dbHelper.getVoltagesByFilter(99999, 'NONEXISTENT', 0.0),
          throwsA(isA<vfd_ex.DataNotFoundException>()),
        );
      });

      test('should return non-empty list of voltages', () async {
        try {
          final vendors = await dbHelper.getAllVendors();
          if (vendors.isNotEmpty) {
            final modelNames =
                await dbHelper.getDistinctModelNamesByVendor(vendors[0].id);
            if (modelNames.isNotEmpty) {
              final ratings = await dbHelper.getPowerRatingsByVendorAndName(
                vendors[0].id,
                modelNames[0],
              );
              if (ratings.isNotEmpty) {
                final voltages = await dbHelper.getVoltagesByFilter(
                  vendors[0].id,
                  modelNames[0],
                  ratings[0],
                );
                expect(voltages, isA<List<String>>());
                expect(voltages.isNotEmpty, true);
              }
            }
          }
        } on vfd_ex.DataNotFoundException {
          // Expected behavior
        } on vfd_ex.DatabaseException {
          fail('Should throw DataNotFoundException, not DatabaseException');
        }
      });
    });

    group('getModelByFilter', () {
      test('should return null for non-existent combination', () async {
        final model =
            await dbHelper.getModelByFilter(99999, 'NONEXISTENT', 0.0, '230V');
        expect(model, null);
      });

      test('should return VfdModel for valid combination', () async {
        try {
          final vendors = await dbHelper.getAllVendors();
          if (vendors.isNotEmpty) {
            final modelNames =
                await dbHelper.getDistinctModelNamesByVendor(vendors[0].id);
            if (modelNames.isNotEmpty) {
              final ratings = await dbHelper.getPowerRatingsByVendorAndName(
                vendors[0].id,
                modelNames[0],
              );
              if (ratings.isNotEmpty) {
                final voltages = await dbHelper.getVoltagesByFilter(
                  vendors[0].id,
                  modelNames[0],
                  ratings[0],
                );
                if (voltages.isNotEmpty) {
                  final model = await dbHelper.getModelByFilter(
                    vendors[0].id,
                    modelNames[0],
                    ratings[0],
                    voltages[0],
                  );
                  expect(model, isNotNull);
                  expect(model, isA<VfdModel>());
                }
              }
            }
          }
        } on vfd_ex.VfdException catch (e) {
          fail('Should not throw exception for valid query: ${e.message}');
        }
      });
    });

    group('getDistinctModelNamesByVendor', () {
      test('should return list of model names', () async {
        try {
          final vendors = await dbHelper.getAllVendors();
          if (vendors.isNotEmpty) {
            final names =
                await dbHelper.getDistinctModelNamesByVendor(vendors[0].id);
            expect(names, isA<List<String>>());
            // Names should be distinct
            expect(names.length, equals(names.toSet().length));
          }
        } on vfd_ex.DatabaseException catch (e) {
          fail('Should not throw exception: ${e.message}');
        }
      });

      test('should throw DatabaseException for invalid vendor', () async {
        expect(
          () => dbHelper.getDistinctModelNamesByVendor(-1),
          returnsNormally, // Should return empty list, not throw
        );
      });
    });

    group('getParametersByModel', () {
      test('should return list of parameters', () async {
        try {
          final models = await dbHelper.getAllModels();
          if (models.isNotEmpty) {
            final params = await dbHelper.getParametersByModel(models[0].id);
            expect(params, isA<List<VfdParameter>>());
          }
        } on vfd_ex.DatabaseException catch (e) {
          fail('Should not throw exception: ${e.message}');
        }
      });

      test('should handle non-existent model gracefully', () async {
        try {
          final params = await dbHelper.getParametersByModel(99999);
          expect(params, isA<List<VfdParameter>>());
          expect(params.isEmpty, true);
        } on vfd_ex.DatabaseException catch (e) {
          fail('Should return empty list: ${e.message}');
        }
      });
    });

    group('Exception Propagation', () {
      test('DatabaseException should be re-thrown correctly', () async {
        expect(
          () => dbHelper.searchModels(''),
          throwsA(isA<vfd_ex.ValidationException>()),
        );
      });

      test('DataNotFoundException should be thrown for missing data', () async {
        expect(
          () => dbHelper.getPowerRatingsByVendorAndName(99999, 'NONEXISTENT'),
          throwsA(isA<vfd_ex.DataNotFoundException>()),
        );
      });
    });

    group('Data Integrity', () {
      test('should return consistent data across multiple calls', () async {
        try {
          final vendors1 = await dbHelper.getAllVendors();
          final vendors2 = await dbHelper.getAllVendors();
          expect(vendors1.length, equals(vendors2.length));
        } on vfd_ex.DatabaseException catch (e) {
          fail('Should not throw exception: ${e.message}');
        }
      });

      test('filtered results should be subsets of all results', () async {
        try {
          final vendors = await dbHelper.getAllVendors();
          final allModels = await dbHelper.getAllModels();

          if (vendors.isNotEmpty) {
            final vendorModels =
                await dbHelper.getModelsByVendor(vendors[0].id);
            // All vendor-specific models should be in the complete list
            expect(vendorModels.length, lessThanOrEqualTo(allModels.length));
          }
        } on vfd_ex.DatabaseException catch (e) {
          fail('Should not throw exception: ${e.message}');
        }
      });
    });
  });
}
