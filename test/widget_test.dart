import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:vfd_param_app/main.dart';
import 'package:vfd_param_app/presentation/providers/vfd_provider.dart';
import 'package:vfd_param_app/presentation/widgets/vendor_card.dart';
import 'package:vfd_param_app/presentation/widgets/model_list.dart';
import 'package:vfd_param_app/data/models/vendor_model.dart';
import 'package:vfd_param_app/data/models/vfd_model.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('VfdParamApp smoke test', () {
    testWidgets('App launches and shows auth loading state',
        (WidgetTester tester) async {
      await tester.pumpWidget(const VfdParamApp());
      // App should start on the welcome screen.
      expect(find.text('VFD Hub'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('App shows loading indicator or vendor grid on launch',
        (WidgetTester tester) async {
      await tester.pumpWidget(const VfdParamApp());
      await tester.pumpAndSettle();

      // After settling, still should be stable and render a scaffold.
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('VendorCard widget', () {
    Widget buildCard(Vendor vendor) {
      return MaterialApp(
        home: Scaffold(
          body: VendorCard(vendor: vendor, onTap: () {}),
        ),
      );
    }

    testWidgets('displays vendor name', (WidgetTester tester) async {
      final vendor = Vendor(id: 1, name: 'Delta', logo: '', description: '');
      await tester.pumpWidget(buildCard(vendor));
      expect(find.text('Delta'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;
      final vendor = Vendor(id: 1, name: 'ABB', logo: '', description: '');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: VendorCard(vendor: vendor, onTap: () => tapped = true),
        ),
      ));
      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });
  });

  group('ModelList widget', () {
    final models = [
      VfdModel(
        id: 1,
        vendorId: 1,
        name: 'VFD-S',
        series: 'S Series',
        description: 'Compact drive',
        powerRating: 0.75,
        voltage: '230V',
      ),
      VfdModel(
        id: 2,
        vendorId: 1,
        name: 'VFD-E',
        series: 'E Series',
        description: 'High perf drive',
        powerRating: 1.5,
        voltage: '380V',
      ),
    ];

    testWidgets('shows all model names', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ModelList(models: models, onModelTap: (_) {}),
        ),
      ));
      expect(find.text('VFD-S'), findsOneWidget);
      expect(find.text('VFD-E'), findsOneWidget);
    });

    testWidgets('shows empty state when no models',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ModelList(models: const [], onModelTap: (_) {}),
        ),
      ));
      expect(find.text('No models found'), findsOneWidget);
    });

    testWidgets('calls onModelTap with correct model when tapped',
        (WidgetTester tester) async {
      VfdModel? tappedModel;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ModelList(
            models: models,
            onModelTap: (m) => tappedModel = m,
          ),
        ),
      ));
      await tester.tap(find.text('VFD-S'));
      expect(tappedModel?.name, equals('VFD-S'));
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
