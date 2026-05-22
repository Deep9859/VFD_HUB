import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vfd_param_app/data/models/vfd_manual.dart';
import 'package:vfd_param_app/presentation/providers/vfd_provider.dart';
import 'package:vfd_param_app/presentation/screens/fault_lookup_screen.dart';
import 'package:vfd_param_app/presentation/screens/about_screen.dart';
import 'package:vfd_param_app/presentation/screens/pdf_viewer_screen.dart';

Widget _wrap(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => VfdProvider()),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: child,
    ),
  );
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  // ── FaultLookupScreen ─────────────────────────────────────────────
  group('FaultLookupScreen', () {
    testWidgets('renders scaffold with appbar', (tester) async {
      await tester.pumpWidget(_wrap(const FaultLookupScreen()));
      // Only check immediately - VfdProvider.loadVendors is async
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });

  // ── AboutScreen ───────────────────────────────────────────────────
  group('AboutScreen', () {
    testWidgets('renders scaffold', (tester) async {
      await tester.pumpWidget(_wrap(const AboutScreen()));
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows app icon', (tester) async {
      await tester.pumpWidget(_wrap(const AboutScreen()));
      await tester.pump();
      expect(find.byIcon(Icons.electrical_services), findsOneWidget);
    });

    testWidgets('shows feature icons', (tester) async {
      await tester.pumpWidget(_wrap(const AboutScreen()));
      await tester.pump();
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('shows developer section icon', (tester) async {
      await tester.pumpWidget(_wrap(const AboutScreen()));
      await tester.pump();
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows database section icon', (tester) async {
      await tester.pumpWidget(_wrap(const AboutScreen()));
      await tester.pump();
      expect(find.byIcon(Icons.storage), findsOneWidget);
    });

    testWidgets('shows scrollable content', (tester) async {
      await tester.pumpWidget(_wrap(const AboutScreen()));
      await tester.pump();
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  // ── PdfViewerScreen ───────────────────────────────────────────────
  group('PdfViewerScreen', () {
    VfdManual makeManual({
      String filePath = '',
      String manualType = 'User Manual',
    }) {
      return VfdManual(
        id: 1,
        modelId: 1,
        title: 'Test Manual',
        manualType: manualType,
        filePath: filePath,
        language: 'EN',
        version: 1,
      );
    }

    testWidgets('shows title in appbar', (tester) async {
      await tester.pumpWidget(
        _wrap(PdfViewerScreen(manual: makeManual())),
      );
      await tester.pump();
      expect(find.text('Test Manual'), findsOneWidget);
    });

    testWidgets('shows manual type subtitle', (tester) async {
      await tester.pumpWidget(
        _wrap(PdfViewerScreen(manual: makeManual())),
      );
      await tester.pump();
      expect(find.text('User Manual'), findsOneWidget);
    });

    testWidgets('shows file-not-found screen for missing local file',
        (tester) async {
      await tester.pumpWidget(
        _wrap(PdfViewerScreen(manual: makeManual(filePath: '/nonexistent/file.pdf'))),
      );
      await tester.pump();
      expect(find.text('PDF Not Found'), findsOneWidget);
    });

    testWidgets('shows go-back button on error screen', (tester) async {
      await tester.pumpWidget(
        _wrap(PdfViewerScreen(manual: makeManual(filePath: '/nonexistent/file.pdf'))),
      );
      await tester.pump();
      expect(find.text('Go Back'), findsOneWidget);
    });

    testWidgets('shows URL screen for http link', (tester) async {
      await tester.pumpWidget(
        _wrap(PdfViewerScreen(
          manual: makeManual(filePath: 'https://example.com/manual.pdf'),
        )),
      );
      await tester.pump();
      expect(find.text('Open in Browser'), findsOneWidget);
    });

    testWidgets('shows copy link button for URL manual', (tester) async {
      await tester.pumpWidget(
        _wrap(PdfViewerScreen(
          manual: makeManual(filePath: 'https://example.com/manual.pdf'),
        )),
      );
      await tester.pump();
      expect(find.text('Copy Link'), findsOneWidget);
    });

    testWidgets('shows URL in link box for URL manual', (tester) async {
      await tester.pumpWidget(
        _wrap(PdfViewerScreen(
          manual: makeManual(filePath: 'https://example.com/manual.pdf'),
        )),
      );
      await tester.pump();
      expect(find.text('https://example.com/manual.pdf'), findsOneWidget);
    });

    testWidgets('shows copy icon in appbar for URL manual', (tester) async {
      await tester.pumpWidget(
        _wrap(PdfViewerScreen(
          manual: makeManual(filePath: 'https://example.com/manual.pdf'),
        )),
      );
      await tester.pump();
      // copy_rounded appears in both appbar and URL screen body
      expect(find.byIcon(Icons.copy_rounded), findsWidgets);
    });
  });
}
