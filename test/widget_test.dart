import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:vfd_param_app/main.dart';
import 'package:vfd_param_app/presentation/providers/vfd_provider.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('VfdParamApp smoke test', () {
    testWidgets('App launches and shows auth loading state',
        (WidgetTester tester) async {
      await tester.pumpWidget(const VfdParamApp());
      expect(find.text('VFD Hub'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('App shows loading indicator or vendor grid on launch',
        (WidgetTester tester) async {
      await tester.pumpWidget(const VfdParamApp());
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('VfdProvider', () {
    test('starts with empty visible state', () {
      final provider = VfdProvider();
      expect(provider.vendors, isEmpty);
      expect(provider.modelNames, isEmpty);
      expect(provider.powerRatings, isEmpty);
      expect(provider.voltages, isEmpty);
      expect(provider.parameters, isEmpty);
      expect(provider.manuals, isEmpty);
      expect(provider.protocols, isEmpty);
      expect(provider.protocolParameters, isEmpty);
      expect(provider.drawings, isEmpty);
      expect(provider.selectedVendor, isNull);
      expect(provider.selectedModel, isNull);
      expect(provider.selectedProtocol, isNull);
      expect(provider.errorMessage, isNull);
    });

    test('clearSelection resets all state', () {
      final provider = VfdProvider();
      provider.clearSelection();
      expect(provider.selectedVendor, isNull);
      expect(provider.selectedModelName, isNull);
      expect(provider.selectedPowerRating, isNull);
      expect(provider.selectedVoltage, isNull);
      expect(provider.selectedModel, isNull);
      expect(provider.selectedProtocol, isNull);
      expect(provider.modelNames, isEmpty);
      expect(provider.powerRatings, isEmpty);
      expect(provider.voltages, isEmpty);
      expect(provider.parameters, isEmpty);
      expect(provider.manuals, isEmpty);
      expect(provider.protocols, isEmpty);
      expect(provider.protocolParameters, isEmpty);
      expect(provider.drawings, isEmpty);
      expect(provider.errorMessage, isNull);
    });

    test('parametersByGroup returns empty map when no parameters', () {
      final provider = VfdProvider();
      expect(provider.parametersByGroup, isEmpty);
    });

    test(
        'protocolParametersByGroup returns empty map when no protocol parameters',
        () {
      final provider = VfdProvider();
      expect(provider.protocolParametersByGroup, isEmpty);
    });
  });
}
